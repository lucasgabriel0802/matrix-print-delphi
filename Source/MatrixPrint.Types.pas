unit MatrixPrint.Types;

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
  System.Classes, System.SysUtils, Vcl.Graphics;

type
  { Efeitos de texto aplicáveis a cada caractere }
  TMatrixTextEffect = (
    mteBold,          // Negrito
    mteItalic,        // Itálico
    mteUnderline,     // Sublinhado
    mteCondensed12,   // Condensado 12 CPI (aprox. 96 colunas em 8 pol.)
    mteCondensed17,   // Condensado padrão 17.1 CPI (aprox. 132-140 colunas)
    mteCondensed20,   // Condensado 20 CPI (aprox. 160 colunas)
    mteExpanded       // Largura dupla (expandido)
  );
  TMatrixTextEffects = set of TMatrixTextEffect;

  { Densidade de linhas por polegada (LPI) }
  TMatrixLinesPerInch = (
    lpi6,             // 6 Linhas por polegada (padrão)
    lpi8              // 8 Linhas por polegada (compacto)
  );

  { Tipo de emulação / driver de impressora }
  TMatrixDriver = (
    mdEpsonEscP,      // Padrão ESC/P e ESC/P2 (Epson LX, FX, LQ, Citizen, etc.)
    mdHPPcl,          // HP PCL / DeskJet / LaserJet
    mdGenericText,    // Texto puro sem comandos de escape
    mdWindowsGDI      // Renderização gráfica em Courier via TPrinter.Canvas
  );

  { Célula individual da matriz (um caractere com seus atributos) }
  TMatrixCell = record
    CharVal: Char;
    Effects: TMatrixTextEffects;
    TextColor: TColor;
    BgColor: TColor;
  end;

  { Opções de configuração da tela de Preview }
  TMatrixPreviewOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FTitle: string;
    FZebraLines: Boolean;
    FTractorFeedMargin: Boolean;
    FPaperColor: TColor;
    FFontColor: TColor;
    FZebraColor: TColor;
    FZoomPercent: Integer;
    FMaximized: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Title: string read FTitle write FTitle;
    property ZebraLines: Boolean read FZebraLines write FZebraLines default True;
    property TractorFeedMargin: Boolean read FTractorFeedMargin write FTractorFeedMargin default True;
    property PaperColor: TColor read FPaperColor write FPaperColor default clWhite;
    property FontColor: TColor read FFontColor write FFontColor default clBlack;
    property ZebraColor: TColor read FZebraColor write FZebraColor default $00F9F9F9;
    property ZoomPercent: Integer read FZoomPercent write FZoomPercent default 100;
    property Maximized: Boolean read FMaximized write FMaximized default True;
  end;

  { Informações de configuração de impressão obtidas do Setup }
  TMatrixPrintSettings = record
    PrinterIndex: Integer;
    PrinterName: string;
    Copies: Integer;
    Collate: Boolean;
    PrintRangeAll: Boolean;
    FromPage: Integer;
    ToPage: Integer;
    Driver: TMatrixDriver;
    UseDirectRaw: Boolean;
  end;

const
  DEFAULT_COLUMNS = 80;
  DEFAULT_ROWS    = 66;

function MatrixDriverToStr(ADriver: TMatrixDriver): string;

implementation

function MatrixDriverToStr(ADriver: TMatrixDriver): string;
begin
  case ADriver of
    mdEpsonEscP:   Result := 'Epson ESC/P (Matricial)';
    mdHPPcl:       Result := 'HP PCL (DeskJet / LaserJet)';
    mdGenericText: Result := 'Texto Genérico (Sem Escapes)';
    mdWindowsGDI:  Result := 'Windows GDI (Gráfico Canvas)';
  else
    Result := 'Desconhecido';
  end;
end;

{ TMatrixPreviewOptions }

constructor TMatrixPreviewOptions.Create;
begin
  inherited Create;
  FEnabled           := True;
  FTitle             := 'Visualização de Impressão';
  FZebraLines        := True;
  FTractorFeedMargin := True;
  FPaperColor        := clWhite;
  FFontColor         := clBlack;
  FZebraColor        := $00F9F9F9;
  FZoomPercent       := 100;
  FMaximized         := True;
end;

procedure TMatrixPreviewOptions.Assign(Source: TPersistent);
begin
  if Source is TMatrixPreviewOptions then
  begin
    FEnabled           := TMatrixPreviewOptions(Source).Enabled;
    FTitle             := TMatrixPreviewOptions(Source).Title;
    FZebraLines        := TMatrixPreviewOptions(Source).ZebraLines;
    FTractorFeedMargin := TMatrixPreviewOptions(Source).TractorFeedMargin;
    FPaperColor        := TMatrixPreviewOptions(Source).PaperColor;
    FFontColor         := TMatrixPreviewOptions(Source).FontColor;
    FZebraColor        := TMatrixPreviewOptions(Source).ZebraColor;
    FZoomPercent       := TMatrixPreviewOptions(Source).ZoomPercent;
    FMaximized         := TMatrixPreviewOptions(Source).Maximized;
  end
  else
    inherited Assign(Source);
end;

end.
