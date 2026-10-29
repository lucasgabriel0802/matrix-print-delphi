object FormMatrixPreview: TFormMatrixPreview
  Left = 0
  Top = 0
  Caption = 'Visualiza'#231#227'o de Relat'#243'rio - MatrixPrint'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 0
    object btnFirst: TSpeedButton
      Left = 8
      Top = 6
      Width = 26
      Height = 26
      Hint = 'Primeira P'#225'gina (Home)'
      Caption = '|<'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFirstClick
    end
    object btnPrior: TSpeedButton
      Left = 36
      Top = 6
      Width = 26
      Height = 26
      Hint = 'P'#225'gina Anterior (PageUp)'
      Caption = '<'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnPriorClick
    end
    object lblPageIndicator: TLabel
      Left = 68
      Top = 11
      Width = 72
      Height = 13
      Alignment = taCenter
      Caption = 'P'#225'gina 1 de 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnNext: TSpeedButton
      Left = 146
      Top = 6
      Width = 26
      Height = 26
      Hint = 'Pr'#243'xima P'#225'gina (PageDown)'
      Caption = '>'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnNextClick
    end
    object btnLast: TSpeedButton
      Left = 174
      Top = 6
      Width = 26
      Height = 26
      Hint = #218'ltima P'#225'gina (End)'
      Caption = '>|'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnLastClick
    end
    object Sep1: TBevel
      Left = 206
      Top = 6
      Width = 2
      Height = 26
      Shape = bsLeftLine
    end
    object btnZoomOut: TSpeedButton
      Left = 214
      Top = 6
      Width = 26
      Height = 26
      Hint = 'Diminuir Zoom'
      Caption = '-'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnZoomOutClick
    end
    object cbZoom: TComboBox
      Left = 244
      Top = 8
      Width = 64
      Height = 21
      TabOrder = 0
      Text = '100%'
      OnChange = cbZoomChange
    end
    object btnZoomIn: TSpeedButton
      Left = 312
      Top = 6
      Width = 26
      Height = 26
      Hint = 'Aumentar Zoom'
      Caption = '+'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnZoomInClick
    end
    object btnZoom100: TSpeedButton
      Left = 340
      Top = 6
      Width = 36
      Height = 26
      Hint = 'Zoom 100%'
      Caption = '100%'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnZoom100Click
    end
    object btnZoomFitWidth: TSpeedButton
      Left = 378
      Top = 6
      Width = 56
      Height = 26
      Hint = 'Ajustar '#224' Largura'
      Caption = 'Largura'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnZoomFitWidthClick
    end
    object Sep2: TBevel
      Left = 440
      Top = 6
      Width = 2
      Height = 26
      Shape = bsLeftLine
    end
    object btnFind: TSpeedButton
      Left = 448
      Top = 6
      Width = 54
      Height = 26
      Hint = 'Localizar Texto (Ctrl+F)'
      Caption = 'Localizar'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFindClick
    end
    object btnCopy: TSpeedButton
      Left = 504
      Top = 6
      Width = 46
      Height = 26
      Hint = 'Copiar P'#225'gina para Clipboard'
      Caption = 'Copiar'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnCopyClick
    end
    object Sep3: TBevel
      Left = 556
      Top = 6
      Width = 2
      Height = 26
      Shape = bsLeftLine
    end
    object btnExportTxt: TSpeedButton
      Left = 564
      Top = 6
      Width = 48
      Height = 26
      Hint = 'Salvar como Arquivo Texto (.txt)'
      Caption = 'TXT'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnExportTxtClick
    end
    object btnExportPdf: TSpeedButton
      Left = 614
      Top = 6
      Width = 48
      Height = 26
      Hint = 'Salvar como Documento PDF (.pdf)'
      Caption = 'PDF'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnExportPdfClick
    end
    object Sep4: TBevel
      Left = 668
      Top = 6
      Width = 2
      Height = 26
      Shape = bsLeftLine
    end
    object btnSetup: TSpeedButton
      Left = 676
      Top = 6
      Width = 70
      Height = 26
      Hint = 'Configurar Impressora'
      Caption = 'Configurar'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnSetupClick
    end
    object btnPrint: TSpeedButton
      Left = 748
      Top = 6
      Width = 64
      Height = 26
      Hint = 'Imprimir Documento (Ctrl+P)'
      Caption = 'Imprimir'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnPrintClick
    end
    object Sep5: TBevel
      Left = 818
      Top = 6
      Width = 2
      Height = 26
      Shape = bsLeftLine
    end
    object btnClose: TSpeedButton
      Left = 826
      Top = 6
      Width = 60
      Height = 26
      Hint = 'Fechar Visualiza'#231#227'o (Esc)'
      Caption = 'Fechar'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnCloseClick
    end
  end
  object ScrollBox: TScrollBox
    Left = 0
    Top = 38
    Width = 900
    Height = 543
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    Color = clGray
    ParentColor = False
    TabOrder = 1
    object PaintBoxCanvas: TPaintBox
      Left = 50
      Top = 20
      Width = 700
      Height = 900
      OnPaint = PaintBoxCanvasPaint
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 581
    Width = 900
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 250
      end
      item
        Width = 50
      end>
  end
  object SaveDialogTxt: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Arquivo Texto (*.txt)|*.txt|Todos os Arquivos (*.*)|*.*'
    Left = 480
    Top = 200
  end
  object SaveDialogPdf: TSaveDialog
    DefaultExt = 'pdf'
    Filter = 'Documento PDF (*.pdf)|*.pdf|Todos os Arquivos (*.*)|*.*'
    Left = 540
    Top = 200
  end
  object FindDialog: TFindDialog
    OnFind = FindDialogFind
    Left = 420
    Top = 200
  end
end

