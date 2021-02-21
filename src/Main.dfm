object Main: TMain
  Left = 49
  Top = 23
  Width = 669
  Height = 525
  Caption = 'DatMaker v1.3'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010100001000400280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000010000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    00000000000000000000000000000000000000000000000000000000000000F0
    000F000FFF0000F0000F00F000F000F0000F000000F000F0000F000000F000FF
    FFF0000FFF0000F0000F00F0000000F0000F00F0000000F0000F00F000F000FF
    FFF0000FFF00000000000000000000000000000000000000000000000000FFFF
    0000FFFF0000FFFF0000FFFF0000DEE30000DEDD0000DEFD0000DEFD0000C1E3
    0000DEDF0000DEDF0000DEDD0000C1E30000FFFF0000FFFF0000FFFF0000}
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 161
    Top = 41
    Width = 500
    Height = 438
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 0
    OnMouseDown = Panel1MouseDown
    OnMouseMove = Panel1MouseMove
    OnMouseUp = Panel1MouseUp
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 161
    Height = 438
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      161
      438)
    object FileListBox: TFileListBox
      Left = 2
      Top = 2
      Width = 155
      Height = 277
      Anchors = [akLeft, akTop, akRight, akBottom]
      FileType = [ftDirectory, ftNormal]
      ItemHeight = 13
      Mask = '*.dat;*.rsm;*.mdl;*.mqo'
      TabOrder = 0
      OnClick = FileListBoxClick
    end
    object panel4: TPanel
      Left = 0
      Top = 279
      Width = 157
      Height = 158
      Anchors = [akLeft, akBottom]
      BevelOuter = bvNone
      TabOrder = 1
      object Label3: TLabel
        Left = 4
        Top = 104
        Width = 49
        Height = 13
        Caption = 'Use Blank'
      end
      object Label2: TLabel
        Left = 100
        Top = 41
        Width = 25
        Height = 13
        Caption = 'Edge'
      end
      object Label1: TLabel
        Left = 70
        Top = 41
        Width = 19
        Height = 13
        Caption = 'Bkg'
      end
      object Shape1: TShape
        Left = 72
        Top = 55
        Width = 17
        Height = 17
        Brush.Color = clSilver
        OnMouseUp = Shape1MouseUp
      end
      object Shape2: TShape
        Left = 104
        Top = 55
        Width = 17
        Height = 17
        Brush.Color = clYellow
        OnMouseUp = Shape2MouseUp
      end
      object Label4: TLabel
        Left = 42
        Top = 138
        Width = 6
        Height = 13
        Caption = '0'
      end
      object c_fill: TCheckBox
        Left = 8
        Top = 4
        Width = 73
        Height = 17
        Caption = 'Fill'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object c_edges: TCheckBox
        Left = 8
        Top = 20
        Width = 53
        Height = 17
        Caption = 'Edges'
        TabOrder = 1
      end
      object c_points: TCheckBox
        Left = 8
        Top = 36
        Width = 57
        Height = 17
        Caption = 'points'
        TabOrder = 2
      end
      object c_grid: TCheckBox
        Left = 8
        Top = 56
        Width = 49
        Height = 17
        Caption = 'Grid'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object c_axis: TCheckBox
        Left = 8
        Top = 72
        Width = 49
        Height = 17
        Caption = 'Axis'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object TRI: TCheckBox
        Left = 8
        Top = 116
        Width = 45
        Height = 17
        Caption = 'PRI:'
        TabOrder = 5
        OnClick = TRIClick
      end
      object c_cullface: TCheckBox
        Left = 84
        Top = 8
        Width = 65
        Height = 17
        Caption = 'Cull Face'
        Checked = True
        State = cbChecked
        TabOrder = 6
        OnClick = c_cullfaceClick
      end
      object C_Box: TComboBox
        Left = 56
        Top = 80
        Width = 97
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 7
        Text = 'No Anim'
        OnChange = C_BoxChange
        Items.Strings = (
          'No Anim'
          'Inject BLANKS'
          'Head object'
          'Amulet'
          'Left hand'
          'Right Hand'
          'Gloves'
          'Shoes')
      end
      object Button1: TButton
        Left = 80
        Top = 119
        Width = 73
        Height = 34
        Caption = 'Make .dat'
        TabOrder = 8
        OnClick = Button1Click
      end
      object CheckBox9: TCheckBox
        Left = 84
        Top = 24
        Width = 65
        Height = 17
        Caption = 'Texures'
        Enabled = False
        TabOrder = 9
        OnClick = c_cullfaceClick
      end
      object Edit1: TEdit
        Left = 8
        Top = 136
        Width = 29
        Height = 21
        TabOrder = 10
        Text = '0'
        OnChange = Edit1Exit
        OnKeyPress = Edit1KeyPress
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 661
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label5: TLabel
      Left = 10
      Top = 20
      Width = 61
      Height = 13
      Caption = 'Directory List'
    end
    object Shape3: TShape
      Left = 249
      Top = 0
      Width = 17
      Height = 17
      OnMouseUp = Shape3MouseUp
    end
    object Shape4: TShape
      Left = 249
      Top = 20
      Width = 17
      Height = 17
      Brush.Color = clBlack
      OnMouseUp = Shape4MouseUp
    end
    object Shape5: TShape
      Left = 365
      Top = 20
      Width = 17
      Height = 17
      Brush.Color = clYellow
      OnMouseUp = Shape5MouseUp
    end
    object Shape6: TShape
      Left = 365
      Top = 0
      Width = 17
      Height = 17
      Brush.Color = 16744703
      OnMouseUp = Shape6MouseUp
    end
    object Shape7: TShape
      Left = 473
      Top = 0
      Width = 17
      Height = 17
      Brush.Color = clLime
      OnMouseUp = Shape7MouseUp
    end
    object CheckBox1: TCheckBox
      Left = 170
      Top = 18
      Width = 77
      Height = 17
      Caption = 'Tri Nums'
      TabOrder = 0
    end
    object Button2: TButton
      Left = 80
      Top = 20
      Width = 55
      Height = 17
      Caption = 'Refresh'
      TabOrder = 1
      OnClick = Button2Click
    end
    object CheckBox2: TCheckBox
      Left = 170
      Top = 0
      Width = 79
      Height = 17
      Caption = 'Point Nums'
      TabOrder = 2
    end
    object CheckBox3: TCheckBox
      Left = 286
      Top = 18
      Width = 79
      Height = 17
      Caption = 'Tskin Nums'
      TabOrder = 3
    end
    object CheckBox4: TCheckBox
      Left = 286
      Top = 0
      Width = 79
      Height = 17
      Caption = 'Vskin Nums'
      TabOrder = 4
    end
    object CheckBox5: TCheckBox
      Left = 404
      Top = 2
      Width = 69
      Height = 17
      Caption = 'Priorities'
      TabOrder = 5
    end
    object CheckBox6: TCheckBox
      Left = 404
      Top = 20
      Width = 105
      Height = 17
      Caption = 'Texture Triangles'
      Enabled = False
      TabOrder = 6
    end
    object CheckBox7: TCheckBox
      Left = 518
      Top = 18
      Width = 83
      Height = 17
      Caption = 'Transparent'
      TabOrder = 7
    end
    object CheckBox8: TCheckBox
      Left = 518
      Top = 0
      Width = 83
      Height = 17
      Caption = 'False Colour'
      TabOrder = 8
    end
  end
  object MainMenu1: TMainMenu
    Left = 167
    Top = 50
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open'
        OnClick = Open1Click
      end
      object OpenFolder1: TMenuItem
        Caption = 'Open Folder'
        OnClick = OpenFolder1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Export1: TMenuItem
        Caption = 'Export'
        object N3DS1: TMenuItem
          Caption = 'MQO'
          OnClick = N3DS1Click
        end
        object MQOv21: TMenuItem
          Caption = 'MQO v2'
          Enabled = False
        end
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Convert1: TMenuItem
      Caption = 'Convert'
      object Old2New1: TMenuItem
        Caption = 'Old2New'
        Enabled = False
      end
      object New2Old1: TMenuItem
        Caption = 'New2Old'
        Enabled = False
      end
    end
    object Settings1: TMenuItem
      Caption = 'Settings'
      object SaveSettings1: TMenuItem
        Caption = 'Save Settings'
        OnClick = SaveColors1Click
      end
    end
    object About1: TMenuItem
      Caption = 'Help'
      object Help1: TMenuItem
        Caption = 'Help'
        OnClick = Help1Click
      end
      object About2: TMenuItem
        Caption = 'About'
        OnClick = About2Click
      end
    end
  end
  object FileOpen: TOpenDialog
    Filter = 
      'RS Models(*.dat;*.rsm;*.mdl;*.mqo)|*.dat;*.rsm;*.mdl;*.mqo|All F' +
      'iles|*.*'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 198
    Top = 50
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Options = [cdFullOpen]
    Left = 230
    Top = 50
  end
end
