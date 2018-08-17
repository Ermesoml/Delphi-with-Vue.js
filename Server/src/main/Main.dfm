object FrDarajaServer: TFrDarajaServer
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Daraja Server Tuturial 1.0'
  ClientHeight = 113
  ClientWidth = 424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbPortaConfigurada: TLabel
    Left = 8
    Top = 71
    Width = 90
    Height = 13
    Caption = 'Porta configurada:'
  end
  object btConectar: TBitBtn
    Left = 8
    Top = 40
    Width = 405
    Height = 25
    Caption = 'Conectar'
    TabOrder = 0
    OnClick = btConectarClick
  end
  object stStatusConexao: TStaticText
    Left = 8
    Top = 17
    Width = 405
    Height = 17
    Alignment = taCenter
    AutoSize = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = sbsSingle
    Caption = 'N'#227'o conectado'
    Color = clMaroon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    Transparent = False
  end
  object btAlterarPorta: TButton
    Left = 327
    Top = 84
    Width = 86
    Height = 25
    Caption = 'Configuracoes'
    TabOrder = 2
  end
  object ePorta: TEdit
    Left = 8
    Top = 86
    Width = 313
    Height = 21
    ReadOnly = True
    TabOrder = 3
  end
end
