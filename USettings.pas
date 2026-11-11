unit USettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ExtDlgs, System.IOUtils, System.Win.Registry, System.Generics.Collections;

type
  TFSettings = class(TForm)
    ESteamPath: TLabeledEdit;
    BSteamPathBrowse: TButton;
    FOD1: TFileOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure BSteamPathBrowseClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FSettings: TFSettings;

implementation

{$R *.dfm}

function GetSteamPath: string;
var
  Reg:TRegistry;
begin
  Result := '';
  reg:=TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly('Software\Valve\Steam') then
    begin
      if Reg.ValueExists('SteamPath') then
        Result := StringReplace(Reg.ReadString('SteamPath'), '/', '\', [rfReplaceAll]);
        Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TFSettings.BSteamPathBrowseClick(Sender: TObject);
var
  dir:string;
begin
  FOD1.DefaultFolder:=ESteamPath.Text;
  if FOD1.Execute then
  begin
    dir := FOD1.FileName;
    if FileExists(dir+'\steam.exe') then
    begin
      ESteamPath.Text := dir;
    end
    else
    begin
      ShowMessage('Select the main folder of Steam, where steam itself is installed and where the steam.exe is located.');
    end;
  end;
end;

procedure TFSettings.FormCreate(Sender: TObject);
begin
  ESteamPath.Text:=GetSteamPath;
end;

end.
