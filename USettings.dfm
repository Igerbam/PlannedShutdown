object FSettings: TFSettings
  Left = 0
  Top = 0
  Caption = 'FSettings'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  DesignSize = (
    624
    441)
  TextHeight = 15
  object ESteamPath: TLabeledEdit
    Left = 8
    Top = 24
    Width = 584
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 71
    EditLabel.Height = 15
    EditLabel.Caption = 'Steam-Folder'
    TabOrder = 0
    Text = ''
  end
  object BSteamPathBrowse: TButton
    Left = 592
    Top = 23
    Width = 24
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = BSteamPathBrowseClick
  end
  object FOD1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoForceFileSystem, fdoPathMustExist]
    Title = 
      'Select your Steam folder. It should be the main Steam folder, wh' +
      'ere Steam itself is installed.'
    Left = 304
    Top = 168
  end
end
