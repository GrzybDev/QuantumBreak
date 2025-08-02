#define AppName "Spolszczenie do Quantum Break"
#define AppVersion "1.1.6"
#define AppPublisher "GrzybDev"
#define AppURL "https://grzyb.dev/app/QuantumBreak"

#define SetupFilename "QuantumBreak_PLFanTranslation_Setup"

#define SteamAppId 474960
#define SteamGameInstallDir "QuantumBreak"

[Setup]
AppendDefaultDirName=no
AppendDefaultGroupName=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
AppId={#SteamGameInstallDir}_PLFanTranslation
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AllowNoIcons=yes
SolidCompression=yes
DefaultDirName={reg:HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Steam App {#SteamAppId},InstallLocation|C:\Program Files (x86)\Steam\steamapps\common\{#SteamGameInstallDir}}
DefaultGroupName={#AppPublisher}\{#AppName}
DirExistsWarning=no
DisableWelcomePage=no
SetupIconFile=installer\setup.ico
UninstallDisplayIcon=installer\setup.ico
LicenseFile=installer\LICENSE.txt
InfoBeforeFile=installer\INFO.txt
OutputDir=dist
OutputBaseFilename={#SetupFilename}
WizardImageFile=installer\branding.bmp
WizardSmallImageFile=installer\setup.bmp
WizardStyle=modern

[Languages]
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"

[Components]
Name: "main"; Description: "Spolszczenie gry"; Types: full compact custom; Flags: fixed
Name: "episodes"; Description: "Spolszczenie serialu"; Types: full

[Files]
Source: "dist\data\ep999-000-pl.bin"; DestDir: "{app}\data"; Components: main
Source: "dist\data\ep999-000-pl.rmdp"; DestDir: "{app}\data"; Components: main
Source: "dist\dx11\loc_x64_f.dll"; DestDir: "{app}\dx11"; Components: episodes; Flags: uninsneveruninstall
Source: "dist\videos\episodes\*"; DestDir: "{app}\videos\episodes"; Components: episodes; Flags: recursesubdirs

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
  UserDir: string;
begin
  if (CurStep = ssInstall) and WizardIsComponentSelected('episodes') then
  begin
    UserDir := ExpandConstant('{app}');

    // Handle loc_x64_f.dll
    if FileExists(UserDir + '\dx11\loc_x64_f.dll') then
    begin
      // Only rename if the renamed file does not already exist
      if not FileExists(UserDir + '\dx11\loc_x64_f_o.dll') then
      begin
        if not RenameFile(UserDir + '\dx11\loc_x64_f.dll', UserDir + '\dx11\loc_x64_f_o.dll') then
          MsgBox('Wystąpił błąd podczas próby zmiany nazwy pliku dx11\loc_x64_f.dll', mbError, MB_OK);
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  UserDir: string;
begin
  if (CurUninstallStep = usUninstall) then
  begin
    UserDir := ExpandConstant('{app}');

    // Handle loc_x64_f.dll restoration
    if FileExists(UserDir + '\dx11\loc_x64_f_o.dll') then
    begin
      // Attempt to delete current .dll if present
      if FileExists(UserDir + '\dx11\loc_x64_f.dll') then
      begin
        if not DeleteFile(UserDir + '\dx11\loc_x64_f.dll') then
          MsgBox('Nie udało się usunąć pliku: dx11\loc_x64_f.dll. Plik może być używany przez inny program.', mbError, MB_OK);
      end;

      // Restore the original
      if not RenameFile(UserDir + '\dx11\loc_x64_f_o.dll', UserDir + '\dx11\loc_x64_f.dll') then
        MsgBox('Nie udało się przywrócić oryginalnego pliku dx11\loc_x64_f.dll. Upewnij się, że nie jest on aktualnie używany.', mbError, MB_OK);
    end;

    // Handle videoList.rmdj restoration
    if FileExists(UserDir + '\data\videoList_original.rmdj') then
    begin
      // Attempt to delete current file if present
      if FileExists(UserDir + '\data\videoList.rmdj') then
      begin
        if not DeleteFile(UserDir + '\data\videoList.rmdj') then
          MsgBox('Nie udało się usunąć pliku: data\videoList.rmdj. Plik może być zablokowany.', mbError, MB_OK);
      end;

      // Restore the original
      if not RenameFile(UserDir + '\data\videoList_original.rmdj', UserDir + '\data\videoList.rmdj') then
        MsgBox('Nie udało się przywrócić oryginalnego pliku data\videoList.rmdj. Sprawdź, czy nie jest w użyciu.', mbError, MB_OK);
    end;
  end;
end;
