unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXPanels, Vcl.Mask, Vcl.ComCtrls, Vcl.Menus, USettings,
  System.IOUtils, System.Win.Registry, System.Generics.Collections, System.Generics.Defaults;

type
  TSteamGame = record
    Name:string;
    AppID:string;
    StateFlag:integer;
  end;
  TSteamGames=TArray<TSteamGame>;

TSteamUpdateStatus = record
    GameName: string;
    IsUpdating: Boolean;
    IsPaused: Boolean;
    ProgressPercent: Double; // Von 0.0 bis 100.0
  end;

type
  TFMain = class(TForm)
    CardPanel1: TCardPanel;
    CSettings: TCard;
    Card2: TCard;
    CBForced: TCheckBox;
    RBShutdown: TRadioButton;
    RBRestart: TRadioButton;
    PCMain: TPageControl;
    TSSteamUpdate: TTabSheet;
    TSShutdownIn: TTabSheet;
    TSShutdownAt: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    EInDays: TLabeledEdit;
    EInHours: TLabeledEdit;
    EInMins: TLabeledEdit;
    EInSecs: TLabeledEdit;
    Panel3: TPanel;
    BSteamShutdown: TButton;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EAtYear: TLabeledEdit;
    EInMonth: TLabeledEdit;
    EAtDay: TLabeledEdit;
    EAtHour: TLabeledEdit;
    EAtMin: TLabeledEdit;
    EAtSec: TLabeledEdit;
    BShutdownAt: TButton;
    BShutdownIn: TButton;
    MainMenu1: TMainMenu;
    Settings1: TMenuItem;
    LForceShutdownHint: TLabel;
    Label8: TLabel;
    LCurrentSteamGame: TLabel;
    TSteamGameDetection: TTimer;
    Label7: TLabel;
    procedure RBShutdownClick(Sender: TObject);
    procedure RBRestartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure TSSteamUpdateShow(Sender: TObject);
    procedure TSteamGameDetectionTimer(Sender: TObject);
    procedure BSteamShutdownClick(Sender: TObject);
    procedure shutdown();
    procedure EInDaysClick(Sender: TObject);
    procedure EInHoursClick(Sender: TObject);
    procedure EInMinsClick(Sender: TObject);
    procedure EInSecsClick(Sender: TObject);
    procedure EAtDayClick(Sender: TObject);
    procedure EInMonthClick(Sender: TObject);
    procedure EAtYearClick(Sender: TObject);
  private
    adminmode:boolean;
    steamgames:TSteamGames;
    ShutdownAfterSteamDone:boolean;
    SteamTimerS:integer;
    shutdownorrestart:string;

    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

function AppRunningAsAdmin: Boolean;
var
  TokenHandle: THandle;
  Elevation: TTokenElevation;
  ReturnLength: DWORD;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, TokenHandle) then
  begin
    try
      if GetTokenInformation(TokenHandle, TokenElevation, @Elevation, SizeOf(Elevation), ReturnLength) then
      begin
        Result := Elevation.TokenIsElevated <> 0;
      end;
    finally
      CloseHandle(TokenHandle);
    end;
  end;
end;

procedure TFMain.shutdown();
begin
  Application.Terminate;
end;

// Hilfsfunktion 2: Liest einen Wert wie "name" "Counter-Strike 2" aus einer Textzeile aus
function ExtractVDFValue(const Line, Key: string): string;
var
  SearchKey: string;
  StartPos, EndPos: Integer;
begin
  Result := '';
  SearchKey := '"' + LowerCase(Key) + '"';

  // Suche nach dem Schlüssel (z.B. "appid")
  StartPos := Pos(SearchKey, LowerCase(Line));
  if StartPos > 0 then
  begin
    // Suche das erste Anführungszeichen des eigentlichen Wertes
    StartPos := Pos('"', Line, StartPos + Length(SearchKey));
    if StartPos > 0 then
    begin
      // Suche das schließende Anführungszeichen
      EndPos := Pos('"', Line, StartPos + 1);
      if EndPos > 0 then
        Result := Copy(Line, StartPos + 1, EndPos - StartPos - 1);
    end;
  end;
end;

// Hilfsfunktion 3: Textdateien sicher einlesen (ohne Steam zu blockieren)
procedure LoadFileSafely(const FilePath: string; List: TStringList);
var
  FS: TFileStream;
  SR: TStreamReader;
begin
  List.Clear;
  if not TFile.Exists(FilePath) then Exit;

  // fmShareDenyNone ist extrem wichtig, falls Steam die Datei gerade benutzt!
  FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
  try
    SR := TStreamReader.Create(FS, TEncoding.UTF8);
    try
      while not SR.EndOfStream do
        List.Add(SR.ReadLine);
    finally
      SR.Free;
    end;
  finally
    FS.Free;
  end;
end;

// HAUPTFUNKTION: Sucht alle Spiele aus allen Ordnern zusammen
function GetAllSteamGames: TSteamGames;
var
  SteamPath, LibFoldersFile, LibPath, AcfFile, Line: string;
  Lines: TStringList;
  Libraries: TStringList;
  GameList: TList<TSteamGame>;
  Game: TSteamGame;
  i, j: Integer;
  AppIdFound, NameFound: Boolean;
begin
  GameList := TList<TSteamGame>.Create;
  Libraries := TStringList.Create;
  Lines := TStringList.Create;
  try
    Libraries.CaseSensitive := False;

    // 1. Haupt-Steam-Ordner holen
    SteamPath := FSettings.ESteamPath.Text;
    if SteamPath = '' then Exit(nil); // Steam nicht gefunden
    Libraries.Add(SteamPath);

    // 2. Zusätzliche Bibliotheken aus der libraryfolders.vdf auslesen
    LibFoldersFile := TPath.Combine(SteamPath, 'steamapps\libraryfolders.vdf');
    LoadFileSafely(LibFoldersFile, Lines);

    for i := 0 to Lines.Count - 1 do
    begin
      LibPath := ExtractVDFValue(Lines[i], 'path');
      if LibPath <> '' then
      begin
        // In der .vdf stehen oft Doppel-Backslashes (\\), die werden reparieren
        LibPath := StringReplace(LibPath, '\\', '\', [rfReplaceAll]);

        // Ordner zur Liste hinzufügen, falls noch nicht vorhanden
        if Libraries.IndexOf(LibPath) = -1 then
          Libraries.Add(LibPath);
      end;
    end;

    // 3. Alle gefundenen Bibliotheken nach .acf Dateien durchsuchen
    for i := 0 to Libraries.Count - 1 do
    begin
      LibPath := TPath.Combine(Libraries[i], 'steamapps');
      if not TDirectory.Exists(LibPath) then Continue;

      // Alle appmanifest_*.acf Dateien im Ordner finden
      for AcfFile in TDirectory.GetFiles(LibPath, 'appmanifest_*.acf') do
      begin
        LoadFileSafely(AcfFile, Lines);
        Game.Name := '';
        Game.AppID := '';
        AppIdFound := False;
        NameFound := False;

        // Datei durchsuchen
        for j := 0 to Lines.Count - 1 do
        begin
          Line := Lines[j];
          if not AppIdFound then
          begin
            Game.AppID := ExtractVDFValue(Line, 'appid');
            if Game.AppID <> '' then AppIdFound := True;
          end;

          if not NameFound then
          begin
            Game.Name := ExtractVDFValue(Line, 'name');
            if Game.Name <> '' then NameFound := True;
          end;

          // Wenn beides gefunden , muss restliche Datei nicht mehr lesen
          if AppIdFound and NameFound then Break;
        end;

        // Spiel zum Array hinzufügen, wenn Name und ID gefunden
        if (Game.AppID <> '') and (Game.Name <> '') then
          GameList.Add(Game);
      end;
    end;

    // Das Ergebnis als Delphi-Array zurückgeben
    Result := GameList.ToArray;

  finally
    // Speicher sauber aufräumen
    GameList.Free;
    Libraries.Free;
    Lines.Free;
  end;
end;

function GetActiveSteamUpdate: TSteamUpdateStatus;
var
  SteamPath, LibFoldersFile, LibPath, AcfFile, Line: string;
  Lines, Libraries: TStringList;
  i, j: Integer;
  GameName, ValBytesDL, ValBytesTotal, ValStateFlags: string;
  BytesDL, BytesTotal: Int64;
  StateFlagsInt: Integer;
begin
  // Standardwerte (nichts lädt herunter)
  Result.IsUpdating := False;
  Result.IsPaused := False; // Standardwert
  Result.GameName := '';
  Result.ProgressPercent := 0.0;

  Libraries := TStringList.Create;
  Lines := TStringList.Create;
  try
    SteamPath := FSettings.ESteamPath.Text;
    if SteamPath = '' then Exit;
    Libraries.Add(SteamPath);

    // Weitere Bibliotheken aus libraryfolders.vdf laden
    LibFoldersFile := TPath.Combine(SteamPath, 'steamapps\libraryfolders.vdf');
    LoadFileSafely(LibFoldersFile, Lines);
    for i := 0 to Lines.Count - 1 do
    begin
      LibPath := ExtractVDFValue(Lines[i], 'path');
      if LibPath <> '' then
      begin
        LibPath := StringReplace(LibPath, '\\', '\', [rfReplaceAll]);
        if Libraries.IndexOf(LibPath) = -1 then Libraries.Add(LibPath);
      end;
    end;

    // Alle Bibliotheken durchsuchen
    for i := 0 to Libraries.Count - 1 do
    begin
      LibPath := TPath.Combine(Libraries[i], 'steamapps');
      if not TDirectory.Exists(LibPath) then Continue;

      for AcfFile in TDirectory.GetFiles(LibPath, 'appmanifest_*.acf') do
      begin
        LoadFileSafely(AcfFile, Lines);
        GameName := '';
        ValBytesDL := '';
        ValBytesTotal := '';
        ValStateFlags := '';

        // Komplette Datei einlesen und die relevanten Werte suchen
        for j := 0 to Lines.Count - 1 do
        begin
          Line := Lines[j];
          if GameName = '' then GameName := ExtractVDFValue(Line, 'name');
          if ValBytesDL = '' then ValBytesDL := ExtractVDFValue(Line, 'BytesDownloaded');
          if ValBytesTotal = '' then ValBytesTotal := ExtractVDFValue(Line, 'BytesToDownload');
          if ValStateFlags = '' then ValStateFlags := ExtractVDFValue(Line, 'StateFlags');
        end;

        // Wenn StateFlags "4" ist, ist das Spiel auf dem neuesten Stand.
        if ValStateFlags = '4' then Continue;

        // In Zahlen umwandeln
        BytesTotal := StrToInt64Def(ValBytesTotal, 0);
        BytesDL := StrToInt64Def(ValBytesDL, 0);
        StateFlagsInt := StrToIntDef(ValStateFlags, 0);

        if BytesTotal > 0 then
        begin
          Result.IsUpdating := True;
          Result.GameName := GameName;
          Result.ProgressPercent := (BytesDL / BytesTotal) * 100;

          // DIE KORREKTUR: Wir prüfen mit einer Bitmaske auf ALLE aktiven Zustände.
          // 16384=Validating, 65536=Preallocating, 131072=Downloading, 262144=Staging, 524288=Committing
          // Wenn das Ergebnis 0 ist, macht Steam gerade absolut gar nichts -> Pausiert!
          Result.IsPaused := (StateFlagsInt and (16384 or 65536 or 131072 or 262144 or 524288)) = 0;


          // Wir haben das ladende/pausierte Spiel gefunden -> Abbruch!
          Exit;
        end;
      end;
    end;
  finally
    Libraries.Free;
    Lines.Free;
  end;
end;

procedure TFMain.BSteamShutdownClick(Sender: TObject);
begin
  if ShutdownAfterSteamDone then
  begin
    ShutdownAfterSteamDone:=false;
    BSteamShutdown.Caption:='Plan shutdown after steam is done';
    SteamTimerS:=60;
  end
  else
  begin
    ShutdownAfterSteamDone:=true;
    BSteamShutdown.Caption:='Cancel shutdown';
  end
end;

procedure TFMain.EAtDayClick(Sender: TObject);
begin
  EAtDay.SelectAll;
end;

procedure TFMain.EAtYearClick(Sender: TObject);
begin
  EAtYear.SelectAll;
end;

procedure TFMain.EInDaysClick(Sender: TObject);
begin
  EInDays.SelectAll;
end;

procedure TFMain.EInHoursClick(Sender: TObject);
begin
  EInHours.SelectAll;
end;

procedure TFMain.EInMinsClick(Sender: TObject);
begin
  EInMins.SelectAll;
end;

procedure TFMain.EInMonthClick(Sender: TObject);
begin
  EInMonth.SelectAll;
end;

procedure TFMain.EInSecsClick(Sender: TObject);
begin
  EInSecs.SelectAll;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  CBForced.Enabled:=AppRunningAsAdmin;
  CBForced.Checked:=AppRunningAsAdmin;
  LForceShutdownHint.Visible:=not AppRunningAsAdmin;
  if not AppRunningAsAdmin then
  begin
    CBForced.Caption:=CBForced.Caption+' (Requires Admin-Mode)'
  end;
  SteamTimerS:=60;
end;

procedure TFMain.RBRestartClick(Sender: TObject);
begin
  with CBForced do
  begin
    Caption:='Force Restart';
    if not AppRunningAsAdmin then
    begin
      Caption:=Caption+' (Requires Admin-Mode)'
    end;
  end;
  shutdownorrestart:='restart';
end;

procedure TFMain.RBShutdownClick(Sender: TObject);
begin
  with CBForced do
  begin
    Caption:='Force Shutodwn';
    if not AppRunningAsAdmin then
    begin
      Caption:=Caption+' (Requires Admin-Mode)'
    end;
  end;
  shutdownorrestart:='shutdown';
end;

procedure TFMain.Settings1Click(Sender: TObject);
begin
  FSettings.Show;
end;

procedure TFMain.TSSteamUpdateShow(Sender: TObject);
var
  i:integer;
begin
  //LBSteamGames.Clear;

  steamgames:=GetAllSteamGames;

  TArray.Sort<TSteamGame>(steamgames, TComparer<TSteamGame>.Construct(
    function(const Left, Right: TSteamGame): Integer
    begin
      Result := string.CompareText(Left.Name, Right.Name);
    end
  ));

  for i := 0 to Length(steamgames)-1 do
  begin
    //LBSteamGames.Items.Add(steamgames[i].Name);
  end;
end;

procedure TFMain.TSteamGameDetectionTimer(Sender: TObject);
var
  Game:TSteamUpdateStatus;
begin
  if Trim(FSettings.ESteamPath.Text)<>'' then
  begin
    Game:=GetActiveSteamUpdate;
    if Game.IsUpdating then
    begin
      SteamTimerS:=60;
      if not ShutdownAfterSteamDone then
        BSteamShutdown.Caption:='Plan shutdown after Steam is done';
      LCurrentSteamGame.Caption:=Game.GameName;
      BSteamShutdown.Enabled:=True;
    end
    else
    begin
      if ShutdownAfterSteamDone then
      begin
        if SteamTimerS<0 then
        begin
          shutdown;
        end;
        LCurrentSteamGame.Caption:='Update Done! PC will '+shutdownorrestart+' in '+IntToStr(SteamTimerS)+'s';
        SteamTimerS:=SteamTimerS-1;
      end
      else
      begin
        LCurrentSteamGame.Caption:='-';
        BSteamShutdown.Caption:='No updates running on Steam';
        BSteamShutdown.Enabled:=False;
      end;
    end;
  end;
end;

end.
