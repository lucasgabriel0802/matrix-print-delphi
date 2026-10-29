object FormDemoMain: TFormDemoMain
  Left = 0
  Top = 0
  Caption = 'MatrixPrint Demo - Impress'#227'o Matricial e Texto Puro'
  ClientHeight = 440
  ClientWidth = 620
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 620
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 20
      Top = 12
      Width = 195
      Height = 21
      Caption = 'MatrixPrint - Su'#237'te Aberta'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 20
      Top = 35
      Width = 422
      Height = 13
      Caption = 'Demonstra'#231#227'o de gera'#231#227'o matricial, preview cont'#237'nuo, spool RAW, exporta'#231#227'o PDF e TXT.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object grpConfig: TGroupBox
    Left = 20
    Top = 75
    Width = 580
    Height = 110
    Caption = ' Configura'#231#245'es do Documento '
    TabOrder = 1
    object lblColumns: TLabel
      Left = 20
      Top = 28
      Width = 43
      Height = 13
      Caption = 'Colunas:'
    end
    object lblLines: TLabel
      Left = 140
      Top = 28
      Width = 36
      Height = 13
      Caption = 'Linhas:'
    end
    object cboColumns: TComboBox
      Left = 20
      Top = 45
      Width = 100
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = '80 Colunas'
      Items.Strings = (
        '80 Colunas'
        '132 Colunas')
    end
    object edtLines: TEdit
      Left = 140
      Top = 45
      Width = 60
      Height = 21
      TabOrder = 1
      Text = '66'
    end
    object chkZebra: TCheckBox
      Left = 230
      Top = 47
      Width = 160
      Height = 17
      Caption = 'Efeito Zebrado no Preview'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object chkTractorFeed: TCheckBox
      Left = 405
      Top = 47
      Width = 160
      Height = 17
      Caption = 'Remalina (Papel Cont'#237'nuo)'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chkSampleData: TCheckBox
      Left = 20
      Top = 78
      Width = 350
      Height = 17
      Caption = 'Gerar m'#250'ltiplas p'#225'ginas (Demonstra'#231#227'o de pagina'#231#227'o autom'#225'tica)'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
  object grpActions: TGroupBox
    Left = 20
    Top = 200
    Width = 580
    Height = 140
    Caption = ' A'#231#245'es de Sa'#237'da '
    TabOrder = 2
    object btnPreview: TButton
      Left = 20
      Top = 30
      Width = 170
      Height = 42
      Caption = 'Visualizar Preview...'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnSetup: TButton
      Left = 205
      Top = 30
      Width = 170
      Height = 42
      Caption = 'Configurar Impress'#227'o...'
      TabOrder = 1
      OnClick = btnSetupClick
    end
    object btnPrintDirect: TButton
      Left = 390
      Top = 30
      Width = 170
      Height = 42
      Caption = 'Imprimir Direto (RAW)'
      TabOrder = 2
      OnClick = btnPrintDirectClick
    end
    object btnExportPDF: TButton
      Left = 20
      Top = 82
      Width = 170
      Height = 35
      Caption = 'Exportar para PDF...'
      TabOrder = 3
      OnClick = btnExportPDFClick
    end
    object btnExportTXT: TButton
      Left = 205
      Top = 82
      Width = 170
      Height = 35
      Caption = 'Exportar para TXT...'
      TabOrder = 4
      OnClick = btnExportTXTClick
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 395
    Width = 620
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 3
    object lblInfo: TLabel
      Left = 20
      Top = 14
      Width = 434
      Height = 13
      Caption = 'MatrixPrint v1.0.0 '#8212' Totalmente livre de depend'#234'ncias propriet'#225'rias. Compat'#237'vel Delphi 10.1+.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      ParentFont = False
    end
  end
  object dlgSave: TSaveDialog
    Left = 528
    Top = 272
  end
end

