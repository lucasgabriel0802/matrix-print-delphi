unit MatrixPrint.Engine;

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
  System.Classes, System.SysUtils, System.Generics.Collections,
  Vcl.Graphics, Vcl.Printers, Winapi.Windows, Winapi.WinSpool,
  MatrixPrint.Types;

type
  { Representa uma única página matricial (linhas x colunas de células) }
  TMatrixPage = class
  private
    FRows: Integer;
    FColumns: Integer;
    FLPI: TMatrixLinesPerInch;
    FGrid: array of array of TMatrixCell;
    function IsValidCoord(Row, Col: Integer): Boolean;
  public
    constructor Create(ARows, AColumns: Integer; ALPI: TMatrixLinesPerInch);
    procedure Clear;
    procedure SetCell(Row, Col: Integer; AChar: Char; AEffects: TMatrixTextEffects;
      ATextColor: TColor = clBlack; ABgColor: TColor = clWhite);
    function GetCell(Row, Col: Integer): TMatrixCell;
    function GetRowText(Row: Integer): string;
    function ExportToPlainText: string;

    property Rows: Integer read FRows;
    property Columns: Integer read FColumns;
    property LinesPerInch: TMatrixLinesPerInch read FLPI;
  end;

  { Coleção de páginas que formam o documento completo }
  TMatrixDocument = class
  private
    FPages: TObjectList<TMatrixPage>;
    function GetPage(Index: Integer): TMatrixPage;
    function GetPageCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddPage(ARows, AColumns: Integer; ALPI: TMatrixLinesPerInch): TMatrixPage;
    function ExportToPlainText: string;

    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TMatrixPage read GetPage; default;
  end;

  { Utilitários de saída de impressão e exportação }
  TMatrixEngine = class
  public
    { Exportação para arquivo de texto puro }
    class procedure ExportToTextFile(ADoc: TMatrixDocument; const AFileName: string);

    { Exportação para PDF nativo (vetorial, sem DLL externa) }
    class procedure ExportToPDFFile(ADoc: TMatrixDocument; const AFileName: string;
      ALPI: TMatrixLinesPerInch = lpi6);

    { Envio RAW direto para o Spooler do Windows (comandos ESC/P ou PCL) }
    class procedure PrintRaw(ADoc: TMatrixDocument; const APrinterName, ADocTitle: string;
      ADriver: TMatrixDriver; ACopies: Integer; AFromPage: Integer = 1; AToPage: Integer = -1);

    { Impressão gráfica via GDI (funciona em qualquer impressora jato/laser/PDF) }
    class procedure PrintGDI(ADoc: TMatrixDocument; const APrinterName, ADocTitle: string;
      ACopies: Integer; AFromPage: Integer = 1; AToPage: Integer = -1);
  end;

implementation

{ TMatrixPage }

constructor TMatrixPage.Create(ARows, AColumns: Integer; ALPI: TMatrixLinesPerInch);
begin
  inherited Create;
  FRows    := ARows;
  FColumns := AColumns;
  FLPI     := ALPI;
  SetLength(FGrid, FRows, FColumns);
  Clear;
end;

function TMatrixPage.IsValidCoord(Row, Col: Integer): Boolean;
begin
  Result := (Row >= 1) and (Row <= FRows) and (Col >= 1) and (Col <= FColumns);
end;

procedure TMatrixPage.Clear;
var
  R, C: Integer;
begin
  for R := 0 to FRows - 1 do
    for C := 0 to FColumns - 1 do
    begin
      FGrid[R, C].CharVal   := ' ';
      FGrid[R, C].Effects   := [];
      FGrid[R, C].TextColor := clBlack;
      FGrid[R, C].BgColor   := clWhite;
    end;
end;

procedure TMatrixPage.SetCell(Row, Col: Integer; AChar: Char; AEffects: TMatrixTextEffects;
  ATextColor, ABgColor: TColor);
begin
  if IsValidCoord(Row, Col) then
  begin
    FGrid[Row - 1, Col - 1].CharVal   := AChar;
    FGrid[Row - 1, Col - 1].Effects   := AEffects;
    FGrid[Row - 1, Col - 1].TextColor := ATextColor;
    FGrid[Row - 1, Col - 1].BgColor   := ABgColor;
  end;
end;

function TMatrixPage.GetCell(Row, Col: Integer): TMatrixCell;
begin
  if IsValidCoord(Row, Col) then
    Result := FGrid[Row - 1, Col - 1]
  else
  begin
    Result.CharVal   := ' ';
    Result.Effects   := [];
    Result.TextColor := clBlack;
    Result.BgColor   := clWhite;
  end;
end;

function TMatrixPage.GetRowText(Row: Integer): string;
var
  C, LastNonSpace: Integer;
begin
  if (Row < 1) or (Row > FRows) then
    Exit('');

  LastNonSpace := -1;
  for C := FColumns - 1 downto 0 do
  begin
    if FGrid[Row - 1, C].CharVal <> ' ' then
    begin
      LastNonSpace := C;
      Break;
    end;
  end;

  if LastNonSpace < 0 then
    Exit('');

  SetLength(Result, LastNonSpace + 1);
  for C := 0 to LastNonSpace do
    Result[C + 1] := FGrid[Row - 1, C].CharVal;
end;

function TMatrixPage.ExportToPlainText: string;
var
  R: Integer;
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    for R := 1 to FRows do
    begin
      SB.AppendLine(GetRowText(R));
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

{ TMatrixDocument }

constructor TMatrixDocument.Create;
begin
  inherited Create;
  FPages := TObjectList<TMatrixPage>.Create(True);
end;

destructor TMatrixDocument.Destroy;
begin
  FPages.Free;
  inherited Destroy;
end;

procedure TMatrixDocument.Clear;
begin
  FPages.Clear;
end;

function TMatrixDocument.AddPage(ARows, AColumns: Integer; ALPI: TMatrixLinesPerInch): TMatrixPage;
begin
  Result := TMatrixPage.Create(ARows, AColumns, ALPI);
  FPages.Add(Result);
end;

function TMatrixDocument.GetPage(Index: Integer): TMatrixPage;
begin
  if (Index >= 0) and (Index < FPages.Count) then
    Result := FPages[Index]
  else
    Result := nil;
end;

function TMatrixDocument.GetPageCount: Integer;
begin
  Result := FPages.Count;
end;

function TMatrixDocument.ExportToPlainText: string;
var
  I: Integer;
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    for I := 0 to FPages.Count - 1 do
    begin
      SB.Append(FPages[I].ExportToPlainText);
      if I < FPages.Count - 1 then
        SB.Append(#12); // Form Feed
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

{ TMatrixEngine }

class procedure TMatrixEngine.ExportToTextFile(ADoc: TMatrixDocument; const AFileName: string);
var
  TextContent: string;
  OutputList: TStringList;
begin
  if not Assigned(ADoc) or (ADoc.PageCount = 0) then
    Exit;

  TextContent := ADoc.ExportToPlainText;
  OutputList := TStringList.Create;
  try
    OutputList.Text := TextContent;
    OutputList.SaveToFile(AFileName, TEncoding.ANSI);
  finally
    OutputList.Free;
  end;
end;

{ Gerador Nativo de PDF em Pascal Puro }
class procedure TMatrixEngine.ExportToPDFFile(ADoc: TMatrixDocument; const AFileName: string;
  ALPI: TMatrixLinesPerInch);
var
  FS: TFileStream;
  XRefOffsets: TList<Int64>;
  ObjCount: Integer;
  PageObjIDs: TList<Integer>;
  I, R: Integer;
  Page: TMatrixPage;
  PageWidth, PageHeight: Double;
  CharWidth, LineHeight, FontSize: Double;
  StreamContent: TStringList;
  StreamBytes: TBytes;
  CurrentLine: string;
  YPos, XPos: Double;
  XRefStart: Int64;

  procedure WriteString(const S: AnsiString);
  begin
    if Length(S) > 0 then
      FS.WriteBuffer(S[1], Length(S));
  end;

  function BeginObj: Integer;
  begin
    Inc(ObjCount);
    XRefOffsets.Add(FS.Position);
    WriteString(AnsiString(Format('%d 0 obj'#10, [ObjCount])));
    Result := ObjCount;
  end;

  procedure EndObj;
  begin
    WriteString('endobj'#10);
  end;

  function EscapePDFString(const S: string): AnsiString;
  var
    J: Integer;
    Res: AnsiString;
  begin
    Res := '';
    for J := 1 to Length(S) do
    begin
      case S[J] of
        '(': Res := Res + '\(';
        ')': Res := Res + '\)';
        '\': Res := Res + '\\';
      else
        if (Ord(S[J]) >= 32) and (Ord(S[J]) <= 126) then
          Res := Res + AnsiChar(Ord(S[J]))
        else if (Ord(S[J]) >= 128) and (Ord(S[J]) <= 255) then
          Res := Res + AnsiChar(Ord(S[J]))
        else
          Res := Res + ' ';
      end;
    end;
    Result := Res;
  end;

var
  ContentObjID: Integer;
  CatID, FontNormID, FontBoldID: Integer;
  KidsStr: string;
begin
  if not Assigned(ADoc) or (ADoc.PageCount = 0) then
    Exit;

  FS := TFileStream.Create(AFileName, fmCreate);
  XRefOffsets := TList<Int64>.Create;
  PageObjIDs  := TList<Integer>.Create;
  StreamContent := TStringList.Create;
  try
    ObjCount := 0;
    WriteString('%PDF-1.4'#10'%âãÏÓ'#10);

    // Fontes Courier (Tipo 1 padrão PDF - não necessita embutir arquivos TTF)
    FontNormID := BeginObj;
    WriteString('<< /Type /Font /Subtype /Type1 /BaseFont /Courier /Encoding /WinAnsiEncoding >>'#10);
    EndObj;

    FontBoldID := BeginObj;
    WriteString('<< /Type /Font /Subtype /Type1 /BaseFont /Courier-Bold /Encoding /WinAnsiEncoding >>'#10);
    EndObj;

    // Gerar páginas
    for I := 0 to ADoc.PageCount - 1 do
    begin
      Page := ADoc[I];

      // Dimensões da folha: padrão contínuo 80 ou 132 colunas (Letter/Custom)
      if Page.Columns <= 80 then
        PageWidth := 8.5 * 72   // 612 pt
      else
        PageWidth := 14.0 * 72; // 1008 pt

      if Page.Rows <= 66 then
        PageHeight := 11.0 * 72 // 792 pt
      else
        PageHeight := (Page.Rows / 6.0) * 72;

      // Cálculo de fontes e espaçamentos
      CharWidth := (PageWidth - 40) / Page.Columns;
      FontSize  := CharWidth * 1.65;
      if FontSize > 10 then FontSize := 10;
      if FontSize < 5 then FontSize := 5;

      if Page.LinesPerInch = lpi8 then
        LineHeight := 72.0 / 8.0
      else
        LineHeight := 72.0 / 6.0;

      // Montar stream de conteúdo da página
      StreamContent.Clear;
      StreamContent.Add('q');
      StreamContent.Add('BT');

      for R := 1 to Page.Rows do
      begin
        CurrentLine := Page.GetRowText(R);
        if Trim(CurrentLine) <> '' then
        begin
          YPos := PageHeight - 30.0 - (R * LineHeight);
          XPos := 20.0;

          // Desenhar texto
          StreamContent.Add(Format('/F1 %.2f Tf', [FontSize], TFormatSettings.Invariant));
          StreamContent.Add(Format('1 0 0 1 %.2f %.2f Tm', [XPos, YPos], TFormatSettings.Invariant));
          StreamContent.Add(Format('(%s) Tj', [string(EscapePDFString(CurrentLine))]));
        end;
      end;

      StreamContent.Add('ET');
      StreamContent.Add('Q');

      StreamBytes := TEncoding.ANSI.GetBytes(StreamContent.Text);

      // Objeto de Stream da página
      ContentObjID := BeginObj;
      WriteString(AnsiString(Format('<< /Length %d >>'#10'stream'#10, [Length(StreamBytes)])));
      if Length(StreamBytes) > 0 then
        FS.WriteBuffer(StreamBytes[0], Length(StreamBytes));
      WriteString(#10'endstream'#10);
      EndObj;

      // Objeto Page
      PageObjIDs.Add(BeginObj);
      WriteString(AnsiString(Format(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.2f %.2f] ' +
        '/Contents %d 0 R /Resources << /Font << /F1 %d 0 R /F2 %d 0 R >> >> >>'#10,
        [PageWidth, PageHeight, ContentObjID, FontNormID, FontBoldID], TFormatSettings.Invariant)));
      EndObj;
    end;

    // Objeto Pages (Catálogo de páginas)
    KidsStr := '';
    for I := 0 to PageObjIDs.Count - 1 do
      KidsStr := KidsStr + Format('%d 0 R ', [PageObjIDs[I]]);

    CatID := BeginObj;
    WriteString(AnsiString(Format('<< /Type /Catalog /Pages %d 0 R >>'#10, [CatID + 1])));
    EndObj;

    BeginObj; // Objeto Pages
    WriteString(AnsiString(Format('<< /Type /Pages /Kids [%s] /Count %d >>'#10, [KidsStr, PageObjIDs.Count])));
    EndObj;

    // Tabela XRef
    XRefStart := FS.Position;
    WriteString(AnsiString(Format('xref'#10'0 %d'#10'0000000000 65535 f '#10, [ObjCount + 1])));
    for I := 0 to XRefOffsets.Count - 1 do
    begin
      WriteString(AnsiString(Format('%010d 00000 n '#10, [XRefOffsets[I]])));
    end;

    // Trailer
    WriteString(AnsiString(Format(
      'trailer'#10'<< /Size %d /Root %d 0 R >>'#10'startxref'#10'%d'#10'%%%%EOF'#10,
      [ObjCount + 1, CatID, XRefStart])));

  finally
    StreamContent.Free;
    PageObjIDs.Free;
    XRefOffsets.Free;
    FS.Free;
  end;
end;

{ Envio RAW para o Spooler do Windows (ESC/P ou PCL) }
class procedure TMatrixEngine.PrintRaw(ADoc: TMatrixDocument; const APrinterName, ADocTitle: string;
  ADriver: TMatrixDriver; ACopies: Integer; AFromPage, AToPage: Integer);
var
  HPrinter: THandle;
  DocInfo: DOC_INFO_1;
  BytesWritten: DWORD;
  RawBuffer: TMemoryStream;
  I, CopyIdx, R: Integer;
  Page: TMatrixPage;
  LineText: string;

  procedure AppendCmd(const Cmd: AnsiString);
  begin
    if Length(Cmd) > 0 then
      RawBuffer.WriteBuffer(Cmd[1], Length(Cmd));
  end;

  procedure SetupDriverInit(LPI: TMatrixLinesPerInch);
  begin
    case ADriver of
      mdEpsonEscP:
      begin
        AppendCmd(#27'@'); // Reset
        if LPI = lpi8 then
          AppendCmd(#27'0') // 8 LPI
        else
          AppendCmd(#27'2'); // 6 LPI
      end;
      mdHPPcl:
      begin
        AppendCmd(#27'E'); // PCL Reset
        if LPI = lpi8 then
          AppendCmd(#27'&l8D')
        else
          AppendCmd(#27'&l6D');
      end;
    end;
  end;

begin
  if not Assigned(ADoc) or (ADoc.PageCount = 0) then
    Exit;

  if not OpenPrinter(PChar(APrinterName), HPrinter, nil) then
    raise Exception.CreateFmt('Não foi possível abrir a impressora "%s". Erro Win32: %d',
      [APrinterName, GetLastError]);

  try
    FillChar(DocInfo, SizeOf(DocInfo), 0);
    DocInfo.pDocName    := PChar(ADocTitle);
    DocInfo.pOutputFile := nil;
    DocInfo.pDatatype   := PChar('RAW');

    if StartDocPrinter(HPrinter, 1, @DocInfo) = 0 then
      raise Exception.CreateFmt('Erro ao iniciar trabalho de impressão. Código: %d', [GetLastError]);

    try
      if AFromPage < 1 then AFromPage := 1;
      if (AToPage < 1) or (AToPage > ADoc.PageCount) then AToPage := ADoc.PageCount;

      RawBuffer := TMemoryStream.Create;
      try
        for CopyIdx := 1 to ACopies do
        begin
          for I := AFromPage - 1 to AToPage - 1 do
          begin
            Page := ADoc[I];
            RawBuffer.Clear;

            SetupDriverInit(Page.LinesPerInch);

            // Gravar cada linha
            for R := 1 to Page.Rows do
            begin
              LineText := Page.GetRowText(R);
              if Page.Columns > 80 then
              begin
                // Se for condensado, ativa ESC/P condensado
                if ADriver = mdEpsonEscP then
                  AppendCmd(#15);
              end;

              AppendCmd(AnsiString(LineText) + #13#10);
            end;

            AppendCmd(#12); // Form Feed

            if not StartPagePrinter(HPrinter) then
              Break;

            WritePrinter(HPrinter, RawBuffer.Memory, RawBuffer.Size, BytesWritten);
            EndPagePrinter(HPrinter);
          end;
        end;
      finally
        RawBuffer.Free;
      end;
    finally
      EndDocPrinter(HPrinter);
    end;
  finally
    ClosePrinter(HPrinter);
  end;
end;

{ Impressão Gráfica via VCL GDI (TPrinter) }
class procedure TMatrixEngine.PrintGDI(ADoc: TMatrixDocument; const APrinterName, ADocTitle: string;
  ACopies: Integer; AFromPage, AToPage: Integer);
var
  I, CopyIdx, R, PrinterIdx: Integer;
  Page: TMatrixPage;
  LineText: string;
  CharWidth, LineHeight, MargX, MargY: Integer;
  TextMetric: TTextMetric;
begin
  if not Assigned(ADoc) or (ADoc.PageCount = 0) then
    Exit;

  // Localizar a impressora selecionada no Printer
  PrinterIdx := Printer.Printers.IndexOf(APrinterName);
  if PrinterIdx >= 0 then
    Printer.PrinterIndex := PrinterIdx;

  if AFromPage < 1 then AFromPage := 1;
  if (AToPage < 1) or (AToPage > ADoc.PageCount) then AToPage := ADoc.PageCount;

  Printer.Title := ADocTitle;
  Printer.BeginDoc;
  try
    for CopyIdx := 1 to ACopies do
    begin
      for I := AFromPage - 1 to AToPage - 1 do
      begin
        Page := ADoc[I];

        if (CopyIdx > 1) or (I > AFromPage - 1) then
          Printer.NewPage;

        // Configurar fonte monoespaçada e dimensionamento proporcional
        Printer.Canvas.Font.Name := 'Courier New';
        Printer.Canvas.Font.Style := [];

        // Calcular tamanho da fonte com base na resolução da impressora
        MargX := GetDeviceCaps(Printer.Handle, LOGPIXELSX) div 2; // 0.5 pol margem
        MargY := GetDeviceCaps(Printer.Handle, LOGPIXELSY) div 2;

        CharWidth := (Printer.PageWidth - (MargX * 2)) div Page.Columns;
        Printer.Canvas.Font.Height := -Round(CharWidth * 1.6);

        GetTextMetrics(Printer.Canvas.Handle, TextMetric);
        LineHeight := (Printer.PageHeight - (MargY * 2)) div Page.Rows;

        for R := 1 to Page.Rows do
        begin
          LineText := Page.GetRowText(R);
          if LineText <> '' then
          begin
            Printer.Canvas.TextOut(
              MargX,
              MargY + ((R - 1) * LineHeight),
              LineText
            );
          end;
        end;
      end;
    end;
    Printer.EndDoc;
  except
    Printer.Abort;
    raise;
  end;
end;

end.
