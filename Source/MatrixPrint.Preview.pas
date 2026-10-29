unit MatrixPrint.Preview;

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
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Clipbrd,
  MatrixPrint.Types, MatrixPrint.Engine, MatrixPrint.Setup;

type
  TFormMatrixPreview = class(TForm)
    PanelTop: TPanel;
    btnFirst: TSpeedButton;
    btnPrior: TSpeedButton;
    btnNext: TSpeedButton;
    btnLast: TSpeedButton;
    lblPageIndicator: TLabel;
    btnZoomIn: TSpeedButton;
    btnZoomOut: TSpeedButton;
    btnZoom100: TSpeedButton;
    btnZoomFitWidth: TSpeedButton;
    btnFind: TSpeedButton;
    btnCopy: TSpeedButton;
    btnExportTxt: TSpeedButton;
    btnExportPdf: TSpeedButton;
    btnPrint: TSpeedButton;
    btnSetup: TSpeedButton;
    btnClose: TSpeedButton;
    cbZoom: TComboBox;
    Sep1: TBevel;
    Sep2: TBevel;
    Sep3: TBevel;
    Sep4: TBevel;
    Sep5: TBevel;
    ScrollBox: TScrollBox;
    PaintBoxCanvas: TPaintBox;
    SaveDialogTxt: TSaveDialog;
    SaveDialogPdf: TSaveDialog;
    FindDialog: TFindDialog;
    StatusBar: TStatusBar;

    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaintBoxCanvasPaint(Sender: TObject);
    procedure btnFirstClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnZoom100Click(Sender: TObject);
    procedure btnZoomFitWidthClick(Sender: TObject);
    procedure cbZoomChange(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnExportTxtClick(Sender: TObject);
    procedure btnExportPdfClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnSetupClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FDocument: TMatrixDocument;
    FOptions: TMatrixPreviewOptions;
    FSettings: TMatrixPrintSettings;
    FCurrentPage: Integer;
    FZoomScale: Double;
    FSearchText: string;

    procedure SetCurrentPage(const Value: Integer);
    procedure SetZoomScale(const Value: Double);
    procedure UpdateLayout;
    procedure UpdateNavButtons;
    procedure DrawTractorFeedHoles(ACanvas: TCanvas; LeftSide: Boolean; PageTop, PageH, Scale: Double);
  public
    class procedure Execute(ADoc: TMatrixDocument; AOptions: TMatrixPreviewOptions;
      var ASettings: TMatrixPrintSettings);
  end;

implementation

{$R *.dfm}

{ TFormMatrixPreview }

class procedure TFormMatrixPreview.Execute(ADoc: TMatrixDocument; AOptions: TMatrixPreviewOptions;
  var ASettings: TMatrixPrintSettings);
var
  Form: TFormMatrixPreview;
begin
  if not Assigned(ADoc) or (ADoc.PageCount = 0) then
    Exit;

  Form := TFormMatrixPreview.Create(Application);
  try
    Form.FDocument := ADoc;
    Form.FOptions  := AOptions;
    Form.FSettings := ASettings;

    if Trim(AOptions.Title) <> '' then
      Form.Caption := AOptions.Title;

    if AOptions.Maximized then
      Form.WindowState := wsMaximized;

    Form.SetZoomScale(AOptions.ZoomPercent / 100.0);
    Form.SetCurrentPage(1);

    Form.ShowModal;
    ASettings := Form.FSettings;
  finally
    Form.Free;
  end;
end;

procedure TFormMatrixPreview.FormCreate(Sender: TObject);
begin
  FCurrentPage := 1;
  FZoomScale   := 1.0;
  FSearchText  := '';

  cbZoom.Items.Clear;
  cbZoom.Items.Add('50%');
  cbZoom.Items.Add('75%');
  cbZoom.Items.Add('100%');
  cbZoom.Items.Add('125%');
  cbZoom.Items.Add('150%');
  cbZoom.Items.Add('200%');
  cbZoom.ItemIndex := 2; // 100%
end;

procedure TFormMatrixPreview.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin ModalResult := mrCancel; Close; end;
    VK_PRIOR:  btnPriorClick(nil);
    VK_NEXT:   btnNextClick(nil);
    VK_HOME:   btnFirstClick(nil);
    VK_END:    btnLastClick(nil);
    Ord('F'):  if ssCtrl in Shift then btnFindClick(nil);
    Ord('P'):  if ssCtrl in Shift then btnPrintClick(nil);
    Ord('S'):  if ssCtrl in Shift then btnExportPdfClick(nil);
  end;
end;

procedure TFormMatrixPreview.SetCurrentPage(const Value: Integer);
begin
  if not Assigned(FDocument) or (FDocument.PageCount = 0) then
    Exit;

  if Value < 1 then
    FCurrentPage := 1
  else if Value > FDocument.PageCount then
    FCurrentPage := FDocument.PageCount
  else
    FCurrentPage := Value;

  lblPageIndicator.Caption := Format('Página %d de %d', [FCurrentPage, FDocument.PageCount]);
  StatusBar.Panels[0].Text := Format('Página %d/%d', [FCurrentPage, FDocument.PageCount]);
  if Assigned(FDocument[FCurrentPage - 1]) then
    StatusBar.Panels[1].Text := Format('Tamanho: %d Linhas x %d Colunas',
      [FDocument[FCurrentPage - 1].Rows, FDocument[FCurrentPage - 1].Columns]);

  UpdateNavButtons;
  PaintBoxCanvas.Invalidate;
end;

procedure TFormMatrixPreview.SetZoomScale(const Value: Double);
begin
  FZoomScale := Value;
  if FZoomScale < 0.25 then FZoomScale := 0.25;
  if FZoomScale > 3.00 then FZoomScale := 3.00;

  cbZoom.Text := Format('%d%%', [Round(FZoomScale * 100)]);
  UpdateLayout;
end;

procedure TFormMatrixPreview.UpdateNavButtons;
var
  TotalP: Integer;
begin
  TotalP := 0;
  if Assigned(FDocument) then
    TotalP := FDocument.PageCount;

  btnFirst.Enabled := (FCurrentPage > 1);
  btnPrior.Enabled := (FCurrentPage > 1);
  btnNext.Enabled  := (FCurrentPage < TotalP);
  btnLast.Enabled  := (FCurrentPage < TotalP);
end;

procedure TFormMatrixPreview.UpdateLayout;
var
  Page: TMatrixPage;
  BaseW, BaseH: Integer;
  MarginW: Integer;
begin
  if not Assigned(FDocument) or (FDocument.PageCount = 0) then
    Exit;

  Page := FDocument[FCurrentPage - 1];
  if not Assigned(Page) then
    Exit;

  // Tamanho base de caracteres: largura ~ 9px, altura ~ 16px em 100%
  MarginW := 0;
  if FOptions.TractorFeedMargin then
    MarginW := 40; // margem para os furinhos laterais

  BaseW := (Page.Columns * 9) + (MarginW * 2) + 40;
  if Page.LinesPerInch = lpi8 then
    BaseH := (Page.Rows * 13) + 60
  else
    BaseH := (Page.Rows * 16) + 60;

  PaintBoxCanvas.Width  := Round(BaseW * FZoomScale);
  PaintBoxCanvas.Height := Round(BaseH * FZoomScale);

  // Centralizar na tela de scroll se for menor que a viewport
  if PaintBoxCanvas.Width < ScrollBox.ClientWidth then
    PaintBoxCanvas.Left := (ScrollBox.ClientWidth - PaintBoxCanvas.Width) div 2
  else
    PaintBoxCanvas.Left := 10;

  PaintBoxCanvas.Top := 10;
  PaintBoxCanvas.Invalidate;
end;

procedure TFormMatrixPreview.DrawTractorFeedHoles(ACanvas: TCanvas; LeftSide: Boolean;
  PageTop, PageH, Scale: Double);
var
  XCenter, YHole, StepY, HoleRadius: Double;
  HoleRInt: Integer;
begin
  if LeftSide then
    XCenter := 20.0 * Scale
  else
    XCenter := PaintBoxCanvas.Width - (20.0 * Scale);

  StepY := 36.0 * Scale; // Espaçamento entre furos de meia polegada
  HoleRadius := 4.5 * Scale;
  HoleRInt := Round(HoleRadius);
  if HoleRInt < 2 then HoleRInt := 2;

  YHole := PageTop + (StepY / 2.0);
  ACanvas.Brush.Color := $00E0E0E0;
  ACanvas.Pen.Color   := $00B0B0B0;
  ACanvas.Pen.Width   := 1;

  while YHole < (PageTop + PageH - HoleRadius) do
  begin
    ACanvas.Ellipse(
      Round(XCenter - HoleRInt),
      Round(YHole - HoleRInt),
      Round(XCenter + HoleRInt),
      Round(YHole + HoleRInt)
    );
    YHole := YHole + StepY;
  end;
end;

procedure TFormMatrixPreview.PaintBoxCanvasPaint(Sender: TObject);
var
  Page: TMatrixPage;
  Canvas: TCanvas;
  PaperRect: TRect;
  MarginW, TextLeftOffset, TextTopOffset: Double;
  CharW, LineH: Double;
  R, C: Integer;
  LineText: string;
  LineRect: TRect;
  Cell: TMatrixCell;
  X, Y: Double;
  FontH: Integer;
begin
  if not Assigned(FDocument) or (FDocument.PageCount = 0) then
    Exit;

  Page := FDocument[FCurrentPage - 1];
  if not Assigned(Page) then
    Exit;

  Canvas := PaintBoxCanvas.Canvas;

  // Fundo cinza do scroller
  PaperRect := Rect(0, 0, PaintBoxCanvas.Width, PaintBoxCanvas.Height);

  // Sombra suave da folha
  Canvas.Brush.Color := $00D0D0D0;
  Canvas.FillRect(Rect(4, 4, PaintBoxCanvas.Width, PaintBoxCanvas.Height));

  // Desenhar a folha de papel
  Canvas.Brush.Color := FOptions.PaperColor;
  Canvas.Pen.Color   := $00BFBFBF;
  Canvas.Pen.Width   := 1;
  Canvas.Rectangle(0, 0, PaintBoxCanvas.Width - 4, PaintBoxCanvas.Height - 4);

  // Furinhos da remalina (papel contínuo)
  if FOptions.TractorFeedMargin then
  begin
    MarginW := 38.0 * FZoomScale;
    DrawTractorFeedHoles(Canvas, True, 0, PaintBoxCanvas.Height, FZoomScale);
    DrawTractorFeedHoles(Canvas, False, 0, PaintBoxCanvas.Height, FZoomScale);

    // Linha pontilhada de destaque da serrilha lateral
    Canvas.Pen.Style := psDot;
    Canvas.Pen.Color := $00D0D0D0;
    Canvas.MoveTo(Round(MarginW), 0);
    Canvas.LineTo(Round(MarginW), PaintBoxCanvas.Height - 4);
    Canvas.MoveTo(PaintBoxCanvas.Width - 4 - Round(MarginW), 0);
    Canvas.LineTo(PaintBoxCanvas.Width - 4 - Round(MarginW), PaintBoxCanvas.Height - 4);
    Canvas.Pen.Style := psSolid;
  end
  else
    MarginW := 15.0 * FZoomScale;

  TextLeftOffset := MarginW + (12.0 * FZoomScale);
  TextTopOffset  := 20.0 * FZoomScale;

  CharW := 8.8 * FZoomScale;
  if Page.LinesPerInch = lpi8 then
    LineH := 13.0 * FZoomScale
  else
    LineH := 16.0 * FZoomScale;

  FontH := Round(LineH * 0.95);
  if FontH < 6 then FontH := 6;

  Canvas.Font.Name := 'Courier New';
  Canvas.Font.Height := -FontH;

  // Renderizar linhas
  for R := 1 to Page.Rows do
  begin
    Y := TextTopOffset + ((R - 1) * LineH);

    // Efeito Zebrado
    if FOptions.ZebraLines and (R mod 2 = 0) then
    begin
      LineRect := Rect(
        Round(TextLeftOffset - 2),
        Round(Y),
        Round(TextLeftOffset + (Page.Columns * CharW) + 2),
        Round(Y + LineH)
      );
      Canvas.Brush.Color := FOptions.ZebraColor;
      Canvas.FillRect(LineRect);
    end;

    // Renderizar caracteres
    Canvas.Brush.Style := bsClear;
    for C := 1 to Page.Columns do
    begin
      Cell := Page.GetCell(R, C);
      if Cell.CharVal <> ' ' then
      begin
        X := TextLeftOffset + ((C - 1) * CharW);

        // Estilos
        Canvas.Font.Style := [];
        if mteBold in Cell.Effects then
          Canvas.Font.Style := Canvas.Font.Style + [fsBold];
        if mteItalic in Cell.Effects then
          Canvas.Font.Style := Canvas.Font.Style + [fsItalic];
        if mteUnderline in Cell.Effects then
          Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];

        Canvas.Font.Color := Cell.TextColor;

        Canvas.TextOut(Round(X), Round(Y), Cell.CharVal);
      end;
    end;
  end;

  // Realce de texto pesquisado (se houver)
  if Trim(FSearchText) <> '' then
  begin
    for R := 1 to Page.Rows do
    begin
      LineText := Page.GetRowText(R);
      if Pos(UpperCase(FSearchText), UpperCase(LineText)) > 0 then
      begin
        // Destaque visual suave na linha encontrada
        Canvas.Brush.Color := $00AAFFFF;
        Canvas.FrameRect(Rect(
          Round(TextLeftOffset),
          Round(TextTopOffset + ((R - 1) * LineH)),
          Round(TextLeftOffset + (Length(LineText) * CharW)),
          Round(TextTopOffset + (R * LineH))
        ));
      end;
    end;
  end;
end;

{ Ações de Navegação }

procedure TFormMatrixPreview.btnFirstClick(Sender: TObject);
begin
  SetCurrentPage(1);
end;

procedure TFormMatrixPreview.btnPriorClick(Sender: TObject);
begin
  SetCurrentPage(FCurrentPage - 1);
end;

procedure TFormMatrixPreview.btnNextClick(Sender: TObject);
begin
  SetCurrentPage(FCurrentPage + 1);
end;

procedure TFormMatrixPreview.btnLastClick(Sender: TObject);
begin
  if Assigned(FDocument) then
    SetCurrentPage(FDocument.PageCount);
end;

{ Ações de Zoom }

procedure TFormMatrixPreview.btnZoomInClick(Sender: TObject);
begin
  SetZoomScale(FZoomScale + 0.25);
end;

procedure TFormMatrixPreview.btnZoomOutClick(Sender: TObject);
begin
  SetZoomScale(FZoomScale - 0.25);
end;

procedure TFormMatrixPreview.btnZoom100Click(Sender: TObject);
begin
  SetZoomScale(1.0);
end;

procedure TFormMatrixPreview.btnZoomFitWidthClick(Sender: TObject);
var
  Page: TMatrixPage;
  CalculatedScale: Double;
begin
  if not Assigned(FDocument) or (FDocument.PageCount = 0) then
    Exit;

  Page := FDocument[FCurrentPage - 1];
  if Assigned(Page) and (Page.Columns > 0) then
  begin
    CalculatedScale := (ScrollBox.ClientWidth - 80) / (Page.Columns * 9.0 + 80.0);
    SetZoomScale(CalculatedScale);
  end;
end;

procedure TFormMatrixPreview.cbZoomChange(Sender: TObject);
var
  CleanText: string;
  Val: Integer;
begin
  CleanText := StringReplace(cbZoom.Text, '%', '', [rfReplaceAll]);
  Val := StrToIntDef(Trim(CleanText), 100);
  SetZoomScale(Val / 100.0);
end;

{ Ações de Pesquisa }

procedure TFormMatrixPreview.btnFindClick(Sender: TObject);
begin
  FindDialog.Execute;
end;

procedure TFormMatrixPreview.FindDialogFind(Sender: TObject);
var
  I, R: Integer;
  Found: Boolean;
  LineText: string;
begin
  FSearchText := FindDialog.FindText;
  Found := False;

  // Procurar a partir da página atual até o fim
  for I := FCurrentPage - 1 to FDocument.PageCount - 1 do
  begin
    for R := 1 to FDocument[I].Rows do
    begin
      LineText := FDocument[I].GetRowText(R);
      if Pos(UpperCase(FSearchText), UpperCase(LineText)) > 0 then
      begin
        SetCurrentPage(I + 1);
        Found := True;
        Break;
      end;
    end;
    if Found then Break;
  end;

  if not Found then
    MessageDlg(Format('Texto "%s" não encontrado no relatório.', [FSearchText]), mtInformation, [mbOK], 0);

  PaintBoxCanvas.Invalidate;
end;

{ Área de Transferência }

procedure TFormMatrixPreview.btnCopyClick(Sender: TObject);
begin
  if Assigned(FDocument) and (FCurrentPage <= FDocument.PageCount) then
  begin
    Clipboard.AsText := FDocument[FCurrentPage - 1].ExportToPlainText;
    MessageDlg('Conteúdo da página atual copiado para a Área de Transferência.', mtInformation, [mbOK], 0);
  end;
end;

{ Exportações }

procedure TFormMatrixPreview.btnExportTxtClick(Sender: TObject);
begin
  SaveDialogTxt.FileName := 'Relatorio.txt';
  if SaveDialogTxt.Execute then
  begin
    TMatrixEngine.ExportToTextFile(FDocument, SaveDialogTxt.FileName);
    MessageDlg(Format('Relatório exportado com sucesso para "%s".', [SaveDialogTxt.FileName]),
      mtInformation, [mbOK], 0);
  end;
end;

procedure TFormMatrixPreview.btnExportPdfClick(Sender: TObject);
begin
  SaveDialogPdf.FileName := 'Relatorio.pdf';
  if SaveDialogPdf.Execute then
  begin
    TMatrixEngine.ExportToPDFFile(FDocument, SaveDialogPdf.FileName);
    MessageDlg(Format('Relatório PDF exportado com sucesso para "%s".', [SaveDialogPdf.FileName]),
      mtInformation, [mbOK], 0);
  end;
end;

{ Impressão e Configuração }

procedure TFormMatrixPreview.btnSetupClick(Sender: TObject);
begin
  TFormMatrixSetup.Execute(FSettings, FDocument.PageCount);
end;

procedure TFormMatrixPreview.btnPrintClick(Sender: TObject);
begin
  if TFormMatrixSetup.Execute(FSettings, FDocument.PageCount) then
  begin
    if FSettings.Driver = mdWindowsGDI then
      TMatrixEngine.PrintGDI(FDocument, FSettings.PrinterName, FOptions.Title,
        FSettings.Copies, FSettings.FromPage, FSettings.ToPage)
    else
      TMatrixEngine.PrintRaw(FDocument, FSettings.PrinterName, FOptions.Title,
        FSettings.Driver, FSettings.Copies, FSettings.FromPage, FSettings.ToPage);

    MessageDlg('Trabalho de impressão enviado com sucesso.', mtInformation, [mbOK], 0);
  end;
end;

procedure TFormMatrixPreview.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

end.
