unit MatrixPrint;

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
  System.Classes, System.SysUtils, Vcl.Graphics, Vcl.Forms, Vcl.Dialogs,
  MatrixPrint.Types, MatrixPrint.Engine, MatrixPrint.Preview, MatrixPrint.Setup;

type
  { Re-exportação de tipos essenciais para conveniência do desenvolvedor }
  TMatrixTextEffect   = MatrixPrint.Types.TMatrixTextEffect;
  TMatrixTextEffects  = MatrixPrint.Types.TMatrixTextEffects;
  TMatrixLinesPerInch = MatrixPrint.Types.TMatrixLinesPerInch;
  TMatrixDriver       = MatrixPrint.Types.TMatrixDriver;
  TMatrixPreviewOptions = MatrixPrint.Types.TMatrixPreviewOptions;

  { Componente Principal TMatrixPrint }
  TMatrixPrint = class(TComponent)
  private
    FColumns: Integer;
    FRows: Integer;
    FLinesPerInch: TMatrixLinesPerInch;
    FDriver: TMatrixDriver;
    FCopies: Integer;
    FTitle: string;
    FPreviewOptions: TMatrixPreviewOptions;
    FPrintSettings: TMatrixPrintSettings;

    FDocument: TMatrixDocument;
    FCurrentPage: TMatrixPage;
    FCurrentPageNumber: Integer;
    FIsActive: Boolean;

    FOnBeforeNewPage: TNotifyEvent;
    FOnNewPage: TNotifyEvent;
    FOnAfterPrint: TNotifyEvent;

    function GetPageCount: Integer;
    procedure EnsureActive;
  protected
    procedure DoBeforeNewPage; virtual;
    procedure DoNewPage; virtual;
    procedure DoAfterPrint; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Controle do Ciclo de Vida do Relatório }
    procedure BeginDoc;
    procedure EndDoc;
    procedure NewPage;

    { Escrita na Matriz de Texto }
    procedure Print(Row, Col: Integer; const Text: string); overload;
    procedure Print(Row, Col: Integer; const Text: string; Effects: TMatrixTextEffects); overload;

    { Métodos Utilitários de Formatação }
    procedure PrintCenter(Row: Integer; const Text: string; Effects: TMatrixTextEffects = []);
    procedure PrintRight(Row, Col: Integer; const Text: string; Effects: TMatrixTextEffects = []); overload;
    procedure PrintRight(Row: Integer; const Text: string; Effects: TMatrixTextEffects = []); overload;
    procedure PrintLine(Row: Integer; LineChar: Char = '-'); overload;
    procedure PrintLine(Row, StartCol, EndCol: Integer; LineChar: Char = '-'); overload;
    procedure PrintBox(Top, Left, Bottom, Right: Integer);

    { Interação e Ações }
    function ShowSetupDialog: Boolean;
    procedure ShowPreview;
    procedure PrintDirect;
    procedure ExportToPDF(const FileName: string);
    procedure ExportToText(const FileName: string);

    { Propriedades em Runtime }
    property Document: TMatrixDocument read FDocument;
    property CurrentPageNumber: Integer read FCurrentPageNumber;
    property PageCount: Integer read GetPageCount;
    property PrintSettings: TMatrixPrintSettings read FPrintSettings write FPrintSettings;
  published
    property Columns: Integer read FColumns write FColumns default DEFAULT_COLUMNS;
    property Rows: Integer read FRows write FRows default DEFAULT_ROWS;
    property TotalColumns: Integer read FColumns write FColumns default DEFAULT_COLUMNS;
    property TotalLines: Integer read FRows write FRows default DEFAULT_ROWS;
    property LinesPerInch: TMatrixLinesPerInch read FLinesPerInch write FLinesPerInch default lpi6;
    property Driver: TMatrixDriver read FDriver write FDriver default mdEpsonEscP;
    property Copies: Integer read FCopies write FCopies default 1;
    property Title: string read FTitle write FTitle;
    property PreviewOptions: TMatrixPreviewOptions read FPreviewOptions write FPreviewOptions;

    property OnBeforeNewPage: TNotifyEvent read FOnBeforeNewPage write FOnBeforeNewPage;
    property OnNewPage: TNotifyEvent read FOnNewPage write FOnNewPage;
    property OnAfterPrint: TNotifyEvent read FOnAfterPrint write FOnAfterPrint;
  end;

implementation

{ TMatrixPrint }

constructor TMatrixPrint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColumns        := DEFAULT_COLUMNS;
  FRows           := DEFAULT_ROWS;
  FLinesPerInch   := lpi6;
  FDriver         := mdEpsonEscP;
  FCopies         := 1;
  FTitle          := 'Relatório Matricial';
  FPreviewOptions := TMatrixPreviewOptions.Create;

  FDocument          := TMatrixDocument.Create;
  FCurrentPage       := nil;
  FCurrentPageNumber := 0;
  FIsActive          := False;

  // Configurações padrão de impressão
  FillChar(FPrintSettings, SizeOf(FPrintSettings), 0);
  FPrintSettings.Copies        := 1;
  FPrintSettings.Collate       := True;
  FPrintSettings.PrintRangeAll := True;
  FPrintSettings.Driver        := FDriver;
  FPrintSettings.FromPage      := 1;
  FPrintSettings.ToPage        := 1;
end;

destructor TMatrixPrint.Destroy;
begin
  FDocument.Free;
  FPreviewOptions.Free;
  inherited Destroy;
end;

function TMatrixPrint.GetPageCount: Integer;
begin
  Result := FDocument.PageCount;
end;

procedure TMatrixPrint.EnsureActive;
begin
  if not FIsActive then
    raise Exception.Create('Operação inválida: chame BeginDoc antes de imprimir na matriz.');
end;

procedure TMatrixPrint.DoBeforeNewPage;
begin
  if Assigned(FOnBeforeNewPage) then
    FOnBeforeNewPage(Self);
end;

procedure TMatrixPrint.DoNewPage;
begin
  if Assigned(FOnNewPage) then
    FOnNewPage(Self);
end;

procedure TMatrixPrint.DoAfterPrint;
begin
  if Assigned(FOnAfterPrint) then
    FOnAfterPrint(Self);
end;

procedure TMatrixPrint.BeginDoc;
begin
  FDocument.Clear;
  FCurrentPageNumber := 0;
  FIsActive          := True;
  NewPage;
end;

procedure TMatrixPrint.NewPage;
begin
  EnsureActive;
  DoBeforeNewPage;

  FCurrentPage := FDocument.AddPage(FRows, FColumns, FLinesPerInch);
  Inc(FCurrentPageNumber);

  DoNewPage;
end;

procedure TMatrixPrint.Print(Row, Col: Integer; const Text: string);
begin
  Print(Row, Col, Text, []);
end;

procedure TMatrixPrint.Print(Row, Col: Integer; const Text: string; Effects: TMatrixTextEffects);
var
  I, MaxLen, TargetCol: Integer;
begin
  EnsureActive;
  if not Assigned(FCurrentPage) then
    Exit;

  MaxLen := Length(Text);
  for I := 1 to MaxLen do
  begin
    TargetCol := Col + (I - 1);
    if TargetCol > FColumns then
      Break;

    FCurrentPage.SetCell(Row, TargetCol, Text[I], Effects, clBlack, clWhite);
  end;
end;

procedure TMatrixPrint.PrintCenter(Row: Integer; const Text: string; Effects: TMatrixTextEffects);
var
  StartCol: Integer;
begin
  StartCol := (FColumns - Length(Text)) div 2;
  if StartCol < 1 then StartCol := 1;
  Print(Row, StartCol, Text, Effects);
end;

procedure TMatrixPrint.PrintRight(Row, Col: Integer; const Text: string; Effects: TMatrixTextEffects);
var
  StartCol: Integer;
begin
  StartCol := Col - Length(Text) + 1;
  if StartCol < 1 then StartCol := 1;
  Print(Row, StartCol, Text, Effects);
end;

procedure TMatrixPrint.PrintRight(Row: Integer; const Text: string; Effects: TMatrixTextEffects);
begin
  PrintRight(Row, FColumns, Text, Effects);
end;

procedure TMatrixPrint.PrintLine(Row: Integer; LineChar: Char);
var
  S: string;
begin
  S := StringOfChar(LineChar, FColumns);
  Print(Row, 1, S, []);
end;

procedure TMatrixPrint.PrintLine(Row, StartCol, EndCol: Integer; LineChar: Char);
var
  S: string;
  Len: Integer;
begin
  if StartCol < 1 then StartCol := 1;
  if EndCol > FColumns then EndCol := FColumns;
  Len := EndCol - StartCol + 1;
  if Len > 0 then
  begin
    S := StringOfChar(LineChar, Len);
    Print(Row, StartCol, S, []);
  end;
end;

procedure TMatrixPrint.PrintBox(Top, Left, Bottom, Right: Integer);
var
  R, C: Integer;
begin
  EnsureActive;
  if (Top >= Bottom) or (Left >= Right) then Exit;

  // Cantos
  Print(Top, Left, '+');
  Print(Top, Right, '+');
  Print(Bottom, Left, '+');
  Print(Bottom, Right, '+');

  // Linhas horizontais
  for C := Left + 1 to Right - 1 do
  begin
    Print(Top, C, '-');
    Print(Bottom, C, '-');
  end;

  // Linhas verticais
  for R := Top + 1 to Bottom - 1 do
  begin
    Print(R, Left, '|');
    Print(R, Right, '|');
  end;
end;

function TMatrixPrint.ShowSetupDialog: Boolean;
begin
  FPrintSettings.Driver := FDriver;
  FPrintSettings.Copies := FCopies;
  Result := TFormMatrixSetup.Execute(FPrintSettings, PageCount);
  if Result then
  begin
    FDriver := FPrintSettings.Driver;
    FCopies := FPrintSettings.Copies;
  end;
end;

procedure TMatrixPrint.ShowPreview;
begin
  if FDocument.PageCount = 0 then
    Exit;

  TFormMatrixPreview.Execute(FDocument, FPreviewOptions, FPrintSettings);
end;

procedure TMatrixPrint.PrintDirect;
begin
  if FDocument.PageCount = 0 then
    Exit;

  if Trim(FPrintSettings.PrinterName) = '' then
  begin
    if not ShowSetupDialog then
      Exit;
  end;

  if FPrintSettings.Driver = mdWindowsGDI then
    TMatrixEngine.PrintGDI(FDocument, FPrintSettings.PrinterName, FTitle,
      FPrintSettings.Copies, FPrintSettings.FromPage, FPrintSettings.ToPage)
  else
    TMatrixEngine.PrintRaw(FDocument, FPrintSettings.PrinterName, FTitle,
      FPrintSettings.Driver, FPrintSettings.Copies, FPrintSettings.FromPage, FPrintSettings.ToPage);

  DoAfterPrint;
end;

procedure TMatrixPrint.EndDoc;
begin
  EnsureActive;
  FIsActive := False;
end;

procedure TMatrixPrint.ExportToPDF(const FileName: string);
begin
  TMatrixEngine.ExportToPDFFile(FDocument, FileName, FLinesPerInch);
end;

procedure TMatrixPrint.ExportToText(const FileName: string);
begin
  TMatrixEngine.ExportToTextFile(FDocument, FileName);
end;

end.
