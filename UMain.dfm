object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'FMain'
  ClientHeight = 444
  ClientWidth = 443
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OnCreate = FormCreate
  TextHeight = 15
  object CardPanel1: TCardPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 444
    Align = alClient
    ActiveCard = CSettings
    BevelEdges = []
    BevelOuter = bvNone
    Caption = 'CardPanel1'
    TabOrder = 0
    object CSettings: TCard
      Left = 0
      Top = 0
      Width = 443
      Height = 444
      Caption = 'CSettings'
      CardIndex = 0
      TabOrder = 0
      DesignSize = (
        443
        444)
      object LForceShutdownHint: TLabel
        Left = 0
        Top = 0
        Width = 443
        Height = 30
        Align = alTop
        Alignment = taCenter
        Caption = 
          'Note: If force shutdown/restard is disabled, winows will ask to ' +
          'shutdown your pc. If you have any unsaved documents open, it wil' +
          'l not shut down/restart!'
        Color = clRed
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Visible = False
        WordWrap = True
        ExplicitWidth = 440
      end
      object CBForced: TCheckBox
        Left = 167
        Top = 33
        Width = 234
        Height = 17
        Caption = 'Force Shutdown'
        TabOrder = 0
      end
      object RBShutdown: TRadioButton
        Left = 7
        Top = 33
        Width = 82
        Height = 17
        Caption = 'Shutdown'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = RBShutdownClick
      end
      object RBRestart: TRadioButton
        Left = 95
        Top = 33
        Width = 66
        Height = 17
        Caption = 'Restart'
        TabOrder = 2
        OnClick = RBRestartClick
      end
      object PCMain: TPageControl
        Left = 0
        Top = 56
        Width = 443
        Height = 388
        ActivePage = TSShutdownAt
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 3
        object TSSteamUpdate: TTabSheet
          Caption = 'Shutdown after Steam update'
          OnShow = TSSteamUpdateShow
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 435
            Height = 358
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
            object Label8: TLabel
              Left = 0
              Top = 0
              Width = 435
              Height = 28
              Align = alTop
              Alignment = taCenter
              Caption = 'Current game update:'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -20
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              ExplicitWidth = 206
            end
            object LCurrentSteamGame: TLabel
              Left = 0
              Top = 28
              Width = 435
              Height = 28
              Align = alTop
              Alignment = taCenter
              Caption = '-'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -20
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
              ExplicitWidth = 8
            end
            object Label7: TLabel
              Left = 0
              Top = 88
              Width = 435
              Height = 15
              Align = alTop
              Alignment = taCenter
              Caption = 'PC will shutdown 1 minute after the update/download is done'
              ExplicitWidth = 328
            end
            object BSteamShutdown: TButton
              Left = 0
              Top = 56
              Width = 435
              Height = 32
              Align = alTop
              Caption = 'No updates running on Steam'
              Enabled = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -20
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              OnClick = BSteamShutdownClick
            end
          end
        end
        object TSShutdownIn: TTabSheet
          Caption = 'Shutdown in time'
          ImageIndex = 1
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 435
            Height = 358
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
            object Label1: TLabel
              Left = 0
              Top = 0
              Width = 435
              Height = 28
              Align = alTop
              Caption = ' Shutdown in'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -20
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              ExplicitWidth = 125
            end
            object EInDays: TLabeledEdit
              Left = 8
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 25
              EditLabel.Height = 15
              EditLabel.Caption = 'Days'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 0
              Text = '0'
              OnClick = EInDaysClick
            end
            object EInHours: TLabeledEdit
              Left = 47
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 32
              EditLabel.Height = 15
              EditLabel.Caption = 'Hours'
              MaxLength = 2
              NumbersOnly = True
              TabOrder = 1
              Text = '0'
              OnClick = EInHoursClick
            end
            object EInMins: TLabeledEdit
              Left = 86
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 26
              EditLabel.Height = 15
              EditLabel.Caption = 'Mins'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 2
              Text = '5'
              OnClick = EInMinsClick
            end
            object EInSecs: TLabeledEdit
              Left = 125
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 23
              EditLabel.Height = 15
              EditLabel.Caption = 'Secs'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 3
              Text = '0'
              OnClick = EInSecsClick
            end
            object BShutdownIn: TButton
              Left = 8
              Top = 80
              Width = 149
              Height = 25
              Caption = 'Shutdown'
              TabOrder = 4
            end
          end
        end
        object TSShutdownAt: TTabSheet
          Caption = 'Shutdown at date, time'
          ImageIndex = 2
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 435
            Height = 358
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
            object Label2: TLabel
              Left = 0
              Top = 0
              Width = 435
              Height = 28
              Align = alTop
              Caption = ' Shutdown at'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -20
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              ExplicitWidth = 126
            end
            object Label3: TLabel
              Left = 47
              Top = 59
              Width = 3
              Height = 15
              Caption = '.'
            end
            object Label4: TLabel
              Left = 94
              Top = 59
              Width = 3
              Height = 15
              Caption = '.'
            end
            object EAtYear: TLabeledEdit
              Left = 103
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 22
              EditLabel.Height = 15
              EditLabel.Caption = 'Year'
              MaxLength = 4
              NumbersOnly = True
              TabOrder = 0
              Text = ''
              OnClick = EAtYearClick
            end
            object EInMonth: TLabeledEdit
              Left = 55
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 36
              EditLabel.Height = 15
              EditLabel.Caption = 'Month'
              MaxLength = 2
              NumbersOnly = True
              TabOrder = 1
              Text = ''
              OnClick = EInMonthClick
            end
            object EAtDay: TLabeledEdit
              Left = 8
              Top = 51
              Width = 33
              Height = 23
              EditLabel.Width = 20
              EditLabel.Height = 15
              EditLabel.Caption = 'Day'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 2
              Text = ''
              OnClick = EAtDayClick
            end
            object EAtHour: TLabeledEdit
              Left = 8
              Top = 97
              Width = 33
              Height = 23
              EditLabel.Width = 27
              EditLabel.Height = 15
              EditLabel.Caption = 'Hour'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 3
              Text = ''
            end
            object EAtMin: TLabeledEdit
              Left = 55
              Top = 97
              Width = 33
              Height = 23
              EditLabel.Width = 21
              EditLabel.Height = 15
              EditLabel.Caption = 'Min'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 4
              Text = ''
            end
            object EAtSec: TLabeledEdit
              Left = 102
              Top = 97
              Width = 33
              Height = 23
              EditLabel.Width = 18
              EditLabel.Height = 15
              EditLabel.Caption = 'Sec'
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 5
              Text = ''
            end
            object BShutdownAt: TButton
              Left = 8
              Top = 126
              Width = 127
              Height = 25
              Caption = 'Shutdown'
              TabOrder = 6
            end
          end
        end
      end
    end
    object Card2: TCard
      Left = 0
      Top = 0
      Width = 443
      Height = 444
      Caption = 'CCountdown'
      CardIndex = 1
      Color = clBackground
      ParentBackground = False
      TabOrder = 1
    end
  end
  object MainMenu1: TMainMenu
    Left = 972
    Top = 9
    object Settings1: TMenuItem
      Caption = 'Settings'
      OnClick = Settings1Click
    end
  end
  object TSteamGameDetection: TTimer
    OnTimer = TSteamGameDetectionTimer
    Left = 356
    Top = 106
  end
end
