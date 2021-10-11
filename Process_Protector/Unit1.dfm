object Form1: TForm1
  Left = 222
  Top = 128
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1047#1072#1097#1080#1090#1072' '#1055#1088#1086#1094#1077#1089#1089#1072
  ClientHeight = 275
  ClientWidth = 324
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 14
    Top = 26
    Width = 86
    Height = 16
    Caption = #1048#1044' '#1055#1088#1086#1089#1077#1089#1089#1072
  end
  object CheckBox1: TCheckBox
    Left = 29
    Top = 92
    Width = 283
    Height = 21
    Caption = #1047#1072#1097#1080#1090#1072' '#1086#1090' ZwDuplicateObject'
    TabOrder = 1
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 29
    Top = 129
    Width = 283
    Height = 21
    Caption = #1047#1072#1097#1080#1090#1072' '#1086#1090' ZwReadVirtualMemory'
    TabOrder = 2
    OnClick = CheckBox2Click
  end
  object CheckBox4: TCheckBox
    Left = 29
    Top = 205
    Width = 283
    Height = 21
    Caption = #1047#1072#1097#1080#1090#1072' '#1086#1090' ZwTerminateProcess'
    TabOrder = 3
    OnClick = CheckBox4Click
  end
  object Edit1: TEdit
    Left = 110
    Top = 22
    Width = 57
    Height = 24
    TabOrder = 4
    Text = '0'
  end
  object Button1: TButton
    Left = 180
    Top = 20
    Width = 93
    Height = 27
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = -123
    Top = -123
    Width = 31
    Height = 31
    TabOrder = 0
  end
  object CheckBox5: TCheckBox
    Left = 29
    Top = 243
    Width = 283
    Height = 21
    Caption = #1047#1072#1097#1080#1090#1072' '#1086#1090' ZwOpenProcess'
    TabOrder = 6
    OnClick = CheckBox5Click
  end
  object CheckBox3: TCheckBox
    Left = 29
    Top = 167
    Width = 283
    Height = 21
    Caption = #1047#1072#1097#1080#1090#1072' '#1086#1090' ZwWriteVirtualMemory'
    TabOrder = 7
    OnClick = CheckBox3Click
  end
  object XPManifest1: TXPManifest
    Left = 247
    Top = 10
  end
end
