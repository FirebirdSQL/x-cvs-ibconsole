object frmDBValidation: TfrmDBValidation
  Left = 185
  Top = 181
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = 'Database Validation'
  ClientHeight = 217
  ClientWidth = 348
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnHelp = FormHelp
  PixelsPerInch = 96
  TextHeight = 13
  object lblDatabaseName: TLabel
    Left = 15
    Top = 15
    Width = 67
    Height = 16
    AutoSize = False
    Caption = 'Database:'
  end
  object bvlLine1: TBevel
    Left = 15
    Top = 42
    Width = 319
    Height = 8
    Shape = bsTopLine
  end
  object lblOptions: TLabel
    Left = 15
    Top = 59
    Width = 75
    Height = 16
    AutoSize = False
    Caption = 'O&ptions:'
    FocusControl = sgOptions
  end
  object stxDatabaseName: TLabel
    Left = 89
    Top = 14
    Width = 87
    Height = 13
    Caption = 'stxDatabaseName'
  end
  object pnlOptionName: TPanel
    Left = 16
    Top = 82
    Width = 170
    Height = 28
    Alignment = taLeftJustify
    BevelInner = bvLowered
    BevelOuter = bvLowered
    TabOrder = 0
  end
  object sgOptions: TStringGrid
    Left = 15
    Top = 81
    Width = 319
    Height = 88
    Color = clSilver
    ColCount = 2
    DefaultColWidth = 90
    DefaultRowHeight = 21
    FixedCols = 0
    RowCount = 3
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColSizing]
    ScrollBars = ssNone
    TabOrder = 1
    OnDrawCell = sgOptionsDrawCell
    OnSelectCell = sgOptionsSelectCell
    ColWidths = (
      168
      145)
  end
  object cbOptions: TComboBox
    Left = 187
    Top = 82
    Width = 143
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    OnDblClick = cbOptionsDblClick
    OnExit = cbOptionsExit
    OnKeyDown = cbOptionsKeyDown
  end
  object btnOK: TButton
    Left = 179
    Top = 184
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 261
    Top = 184
    Width = 75
    Height = 25
    Caption = '&Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
