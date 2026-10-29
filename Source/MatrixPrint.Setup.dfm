object FormMatrixSetup: TFormMatrixSetup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configura'#231#227'o de Impress'#227'o'
  ClientHeight = 360
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 460
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblHeaderTitle: TLabel
      Left = 16
      Top = 8
      Width = 148
      Height = 17
      Caption = 'Configurar Impress'#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblHeaderSub: TLabel
      Left = 16
      Top = 27
      Width = 272
      Height = 13
      Caption = 'Selecione a impressora e as op'#231#245'es de sa'#237'da desejadas.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object gbPrinter: TGroupBox
    Left = 16
    Top = 58
    Width = 428
    Height = 110
    Caption = ' Impressora '
    TabOrder = 1
    object lblPrinter: TLabel
      Left = 16
      Top = 22
      Width = 34
      Height = 13
      Caption = 'Nome:'
    end
    object lblDriver: TLabel
      Left = 16
      Top = 64
      Width = 83
      Height = 13
      Caption = 'Modo / Driver:'
    end
    object cbPrinters: TComboBox
      Left = 16
      Top = 38
      Width = 394
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object cbDriver: TComboBox
      Left = 16
      Top = 80
      Width = 394
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
  end
  object gbRange: TGroupBox
    Left = 16
    Top = 174
    Width = 240
    Height = 120
    Caption = ' Intervalo de P'#225'ginas '
    TabOrder = 2
    object lblFrom: TLabel
      Left = 36
      Top = 80
      Width = 17
      Height = 13
      Caption = 'De:'
    end
    object lblTo: TLabel
      Left = 120
      Top = 80
      Width = 20
      Height = 13
      Caption = 'At'#233':'
    end
    object rbAllPages: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Todas as p'#225'ginas'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbRangeClick
    end
    object rbPagesInterval: TRadioButton
      Left = 16
      Top = 50
      Width = 80
      Height = 17
      Caption = 'P'#225'ginas:'
      TabOrder = 1
      OnClick = rbRangeClick
    end
    object edFromPage: TEdit
      Left = 58
      Top = 77
      Width = 45
      Height = 21
      TabOrder = 2
      Text = '1'
    end
    object edToPage: TEdit
      Left = 146
      Top = 77
      Width = 45
      Height = 21
      TabOrder = 3
      Text = '1'
    end
  end
  object gbCopies: TGroupBox
    Left = 264
    Top = 174
    Width = 180
    Height = 120
    Caption = ' C'#243'pias '
    TabOrder = 3
    object lblCopies: TLabel
      Left = 16
      Top = 26
      Width = 63
      Height = 13
      Caption = 'Quantidade:'
    end
    object edCopies: TEdit
      Left = 16
      Top = 45
      Width = 60
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object udCopies: TUpDown
      Left = 76
      Top = 45
      Width = 16
      Height = 21
      Associate = edCopies
      Min = 1
      Max = 999
      Position = 1
      TabOrder = 1
    end
    object chkCollate: TCheckBox
      Left = 16
      Top = 82
      Width = 97
      Height = 17
      Caption = 'Agrupar'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 310
    Width = 460
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object btnOK: TButton
      Left = 284
      Top = 12
      Width = 75
      Height = 26
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 368
      Top = 12
      Width = 75
      Height = 26
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
    end
  end
end

