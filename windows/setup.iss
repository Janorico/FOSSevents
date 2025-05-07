#define MyAppName "FOSSevents"
#define MyAppVersion "1.1"
#define MyAppStatus "stable"
#define MyAppPublisher "Janorico"
#define MyAppVerName MyAppName + " v" + MyAppVersion + "-" + MyAppStatus
#define MyAppURL "https://github.com/Janorico/fossevents"
#define MyAppExeName "fossevents"
#define MyAppSetupName = MyAppExeName + "_setup"
#define MyAppSetupDescription "Setup for " + MyAppName
#define MyAppCopyright "Copyright (C) 2025-present Janosch Lion"

[Setup]
AppId={{75E396F2-3481-464F-8DA0-D8D18974DFFD}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
DefaultGroupName={#MyAppPublisher}
DisableProgramGroupPage=yes
PrivilegesRequiredOverridesAllowed=dialog
LicenseFile=C:\Janosch\Downloads\GNU General Public License\gpl-3.0.rtf
OutputBaseFilename={#MyAppSetupName}
OutputDir=..\build\windows\x64\setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
; Setup version info
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoOriginalFileName={#MyAppSetupName}.exe
VersionInfoCopyright={#MyAppCopyright}
VersionInfoDescription={#MyAppSetupDescription}
VersionInfoVersion={#MyAppVersion}

;[Languages]
;Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\LICENSE.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}.exe"; Comment: "{#MyAppVerName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}.exe"; Comment: "{#MyAppVerName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
