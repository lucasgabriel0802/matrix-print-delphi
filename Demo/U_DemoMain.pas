unit U_DemoMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  MatrixPrint.Types,
  MatrixPrint;

type
  TFormDemoMain = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    grpConfig: TGroupBox;
    lblColumns: TLabel;
    lblLines: TLabel;
    cboColumns: TComboBox;
    edtLines: TEdit;
    chkZebra: TCheckBox;
    chkTractorFeed: TCheckBox;
    chkSampleData: TCheckBox;
    grpActions: TGroupBox;
    btnPreview: TButton;
    btnSetup: TButton;
    btnPrintDirect: TButton;
    btnExportPDF: TButton;
    btnExportTXT: TButton;
    pnlStatus: TPanel;
    lblInfo: TLabel;
    dlgSave: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnSetupClick(Sender: TObject);
    procedure btnPrintDirectClick(Sender: TObject);
    procedure btnExportPDFClick(Sender: TObject);
    procedure btnExportTXTClick(Sender: TObject);
  private
    FMatrix: TMatrixPrint;
    procedure BuildSampleReport;
  public
    destructor Destroy; override;
  end;

var
  FormDemoMain: TFormDemoMain;

implementation

{$R *.dfm}

{ TFormDemoMain }

procedure TFormDemoMain.FormCreate(Sender: TObject);
begin
  FMatrix := TMatrixPrint.Create(Self);
  FMatrix.Title := 'Demonstração de Relatório Matricial';
end;

destructor TFormDemoMain.Destroy;
begin
  FreeAndNil(FMatrix);
  inherited;
end;

procedure TFormDemoMain.BuildSampleReport;
var
  LCols, LLines: Integer;
  I: Integer;
  LTotal: Double;
  LVal: Double;
begin
  if cboColumns.ItemIndex = 1 then
    LCols := 132
  else
    LCols := 80;

  LLines := StrToIntDef(edtLines.Text, 66);
  if LLines < 10 then
    LLines := 66;

  FMatrix.TotalColumns := LCols;
  FMatrix.TotalLines := LLines;
  FMatrix.PreviewOptions.ZebraLines := chkZebra.Checked;
  FMatrix.PreviewOptions.TractorFeedMargin := chkTractorFeed.Checked;

  FMatrix.BeginDoc;
  try
    // Cabeçalho da Empresa
    FMatrix.PrintCenter(1, 'EMPRESA EXEMPLO DE MATERIAIS E SERVIÇOS S/A', [mteBold]);
    FMatrix.PrintCenter(2, 'SISTEMA DE GESTÃO INTEGRADA - RELATÓRIO OPERACIONAL');
    FMatrix.Print(3, 1, 'Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now));
    FMatrix.PrintRight(3, 'Página: 1 de ' + IfThen(chkSampleData.Checked, '2', '1'));
    FMatrix.PrintLine(4, 1, LCols, '=');

    // Cabeçalho da Tabela
    FMatrix.Print(5, 1, 'CÓDIGO', [mteBold]);
    FMatrix.Print(5, 10, 'DESCRIÇÃO DO PRODUTO / SERVIÇO', [mteBold]);
    FMatrix.Print(5, 45, 'UNID', [mteBold]);
    FMatrix.PrintRight(5, 'VALOR UNIT (R$)', [mteBold]);
    FMatrix.PrintLine(6, 1, LCols, '-');

    // Linhas de Detalhe
    LTotal := 0.0;
    for I := 1 to 20 do
    begin
      LVal := (I * 17.50) + 12.30;
      LTotal := LTotal + LVal;

      FMatrix.Print(6 + I, 1, Format('%.4d', [I]));
      FMatrix.Print(6 + I, 10, 'ITEM OPERACIONAL ' + Chr(64 + (I mod 26)) + ' - LOTE PADRÃO 2026');
      FMatrix.Print(6 + I, 45, 'UN');
      FMatrix.Print(6 + I, 65, Format('%12.2f', [LVal]));
    end;

    FMatrix.PrintLine(27, 1, LCols, '-');
    FMatrix.Print(28, 10, 'TOTAL GERAL DESTA PÁGINA:', [mteBold]);
    FMatrix.Print(28, 65, Format('%12.2f', [LTotal]), [mteBold, mteExpanded]);
    FMatrix.PrintBox(30, 1, 33, LCols);
    FMatrix.PrintCenter(31, 'Observação: Documento processado pelo motor MatrixPrint 1.0.');
    FMatrix.PrintCenter(32, 'Compatível com ESC/P Epson, PCL HP e GDI Windows.', [mteItalic]);

    // Página 2 (se marcado)
    if chkSampleData.Checked then
    begin
      FMatrix.NewPage;

      FMatrix.PrintCenter(1, 'EMPRESA EXEMPLO DE MATERIAIS E SERVIÇOS S/A', [mteBold]);
      FMatrix.PrintCenter(2, 'ANEXO DE RESUMO GERENCIAL - SEGUNDA PÁGINA');
      FMatrix.Print(3, 1, 'Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now));
      FMatrix.PrintRight(3, 'Página: 2 de 2');
      FMatrix.PrintLine(4, 1, LCols, '=');

      FMatrix.Print(6, 1, 'RESUMO CONSOLIDADO POR DEPARTAMENTO:', [mteBold, mteExpanded]);

      FMatrix.Print(8, 5, '01 - ADMINISTRAÇÃO GERAL ........................... R$  15.420,00');
      FMatrix.Print(9, 5, '02 - TECNOLOGIA DA INFORMAÇÃO ...................... R$  28.900,00');
      FMatrix.Print(10, 5, '03 - SAÚDE E SEGURANÇA OCUPACIONAL ................. R$  42.150,00');
      FMatrix.Print(11, 5, '04 - LOGÍSTICA E SUPRIMENTOS ....................... R$  19.340,00');
      FMatrix.PrintLine(12, 5, 70, '-');
      FMatrix.Print(13, 5, 'TOTAL CONSOLIDADO .................................. R$ 105.810,00', [mteBold]);

      FMatrix.PrintBox(16, 5, 22, 70);
      FMatrix.PrintCenter(18, 'ASSINATURA DO RESPONSÁVEL TÉCNICO', [mteBold]);
      FMatrix.PrintCenter(20, '_______________________________________________');
      FMatrix.PrintCenter(21, 'DEPARTAMENTO DE CONTROLE INTERNO');
    end;

  finally
    FMatrix.EndDoc;
  end;
end;

procedure TFormDemoMain.btnPreviewClick(Sender: TObject);
begin
  BuildSampleReport;
  FMatrix.ShowPreview;
end;

procedure TFormDemoMain.btnSetupClick(Sender: TObject);
begin
  if FMatrix.ShowSetupDialog then
    ShowMessage('Configurações de impressão atualizadas com sucesso.'#13#10 +
      'Impressora: ' + FMatrix.PrintSettings.PrinterName + #13#10 +
      'Driver: ' + MatrixDriverToStr(FMatrix.PrintSettings.Driver));
end;

procedure TFormDemoMain.btnPrintDirectClick(Sender: TObject);
begin
  if MessageDlg('Deseja enviar o documento diretamente para o Spooler de impressão (' +
    FMatrix.PrintSettings.PrinterName + ')?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    BuildSampleReport;
    FMatrix.PrintDirect;
    ShowMessage('Documento enviado com sucesso para a fila de impressão!');
  end;
end;

procedure TFormDemoMain.btnExportPDFClick(Sender: TObject);
begin
  dlgSave.Title := 'Salvar Relatório como PDF';
  dlgSave.Filter := 'Documento PDF (*.pdf)|*.pdf';
  dlgSave.DefaultExt := 'pdf';
  dlgSave.FileName := 'Relatorio_Matricial.pdf';

  if dlgSave.Execute then
  begin
    BuildSampleReport;
    FMatrix.ExportToPDF(dlgSave.FileName);
    ShowMessage('Arquivo PDF gerado com sucesso em:'#13#10 + dlgSave.FileName);
  end;
end;

procedure TFormDemoMain.btnExportTXTClick(Sender: TObject);
begin
  dlgSave.Title := 'Salvar Relatório como Texto Puro';
  dlgSave.Filter := 'Arquivo de Texto (*.txt)|*.txt';
  dlgSave.DefaultExt := 'txt';
  dlgSave.FileName := 'Relatorio_Matricial.txt';

  if dlgSave.Execute then
  begin
    BuildSampleReport;
    FMatrix.ExportToText(dlgSave.FileName);
    ShowMessage('Arquivo TXT gerado com sucesso em:'#13#10 + dlgSave.FileName);
  end;
end;

end.
