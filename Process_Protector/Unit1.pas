{Автор Зорков Игорь - zorkovigor@mail.ru}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinSvc, StdCtrls, XPMan;

type
  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    CheckBox5: TCheckBox;
    XPManifest1: TXPManifest;
    CheckBox3: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DriverDevice: THANDLE = 0;

implementation

{$R *.dfm}

function _EnablePrivilegeW(Privilege: WideString): Boolean;
var
  TokenHandle: THandle;
  TokenPrivileges: TTokenPrivileges;
  ReturnLength: Cardinal;
begin
  Result := False;
  if Windows.OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TokenHandle) then
  begin
    try
      LookupPrivilegeValueW(nil, PWideChar(Privilege), TokenPrivileges.Privileges[0].Luid);
      TokenPrivileges.PrivilegeCount := 1;
      TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      if AdjustTokenPrivileges(TokenHandle, False, TokenPrivileges, 0, nil, ReturnLength) then
        Result := True;
    finally
      CloseHandle(TokenHandle);
    end;
  end;
end;

procedure _LoadDriverW(DriverPath: WideString);
var
  hSCManager, hService: SC_HANDLE;
  lpServiceArgVectors: PWideChar;
begin
  hSCManager := 0;
  hSCManager := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);

  if hSCManager <> 0 then
  begin
    hService := 0;
    hService := CreateServiceW(hSCManager,
                               'ProtectService',
                               'Protect Kernel Driver',
                               SERVICE_ALL_ACCESS,
                               SERVICE_KERNEL_DRIVER,
                               SERVICE_DEMAND_START,
                               SERVICE_ERROR_NORMAL,
                               PWideChar(DriverPath),
                               nil,
                               nil,
                               nil,
                               nil,
                               nil);

    hService := 0;
    lpServiceArgVectors := nil;

    hService := OpenServiceW(hSCManager, 'ProtectService', SERVICE_ALL_ACCESS);
    if hService <> 0 then
    begin
      StartServiceW(hService, 0, PWideChar(lpServiceArgVectors));
      CloseServiceHandle(hService);
    end;

    CloseServiceHandle(hSCManager);
  end;

  DriverDevice := CreateFileW('\\.\' + 'PROTECTDRIVER', GENERIC_READ or GENERIC_WRITE, 0, PSECURITY_DESCRIPTOR(nil), OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
end;

procedure _UnloadDriverW;
var
  hSCManager, hService: SC_HANDLE;
  lpServiceStatus: TServiceStatus;
begin
  if (DriverDevice <> 0) then
    CloseHandle(DriverDevice);
    
  hSCManager := 0;
  hSCManager := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);

  if hSCManager <> 0 then
  begin

    hService := 0;
    hService := OpenServiceW(hSCManager, 'ProtectService', SERVICE_ALL_ACCESS);
    if (hService <> 0) then
    begin
      ControlService(hService, SERVICE_CONTROL_STOP, lpServiceStatus);
      DeleteService(hService);
      CloseServiceHandle(hService);
    end;

    CloseServiceHandle(hSCManager);
  end;
end;

function CTL_CODE(DeviceType: Integer; Func: Integer; Meth: Integer; Access: Integer): DWORD;
begin
  Result := (DeviceType shl 16) or (Access shl 14) or (Func shl 2) or (Meth);
end;

type
  TFunctionsAddresses = record
    ZwDuplicateObjectAddress: Pointer;
    ZwReadVirtualMemory: Pointer;
    ZwWriteVirtualMemory: Pointer;
    ZwTerminateProcessAddress: Pointer;
    ZwOpenProcessAddress: Pointer;
  end;
  PFunctionsAddresses = ^TFunctionsAddresses;

function SendFunctionsAddresses: Boolean;
var
  dwBytesReturned: DWORD;
  FunctionsAddresses: TFunctionsAddresses;
begin
  Result := False;
  FunctionsAddresses.ZwDuplicateObjectAddress := (GetProcAddress(GetModuleHandleW('ntdll.dll'), 'NtDuplicateObject'));
  FunctionsAddresses.ZwReadVirtualMemory := (GetProcAddress(GetModuleHandleW('ntdll.dll'), 'NtReadVirtualMemory'));
  FunctionsAddresses.ZwWriteVirtualMemory := (GetProcAddress(GetModuleHandleW('ntdll.dll'), 'NtWriteVirtualMemory'));
  FunctionsAddresses.ZwTerminateProcessAddress := (GetProcAddress(GetModuleHandleW('ntdll.dll'), 'NtTerminateProcess'));
  FunctionsAddresses.ZwOpenProcessAddress := (GetProcAddress(GetModuleHandleW('ntdll.dll'), 'NtOpenProcess'));
  Result := DeviceIoControl(DriverDevice, CTL_CODE($F100, $0901, 0, 0), @FunctionsAddresses, SizeOf(FunctionsAddresses), nil, 0, dwBytesReturned, 0);
end;

type
  TProtectInfo = record
    ProtectProcessId: Cardinal;
    //ProtectProcessId2: Cardinal;
  end;
  PProtectInfo = ^TProtectInfo;

function SendProtectInfo: Boolean;
var
  dwBytesReturned: DWORD;
  ProtectInfo: TProtectInfo;
begin
  Result := False;
  ProtectInfo.ProtectProcessId := StrToInt(Form1.Edit1.Text);
  //ProtectInfo.ProtectProcessId2 := ;
  Result := DeviceIoControl(DriverDevice, CTL_CODE($F100, $0900, 0, 0), @ProtectInfo, SizeOf(ProtectInfo), nil, 0, dwBytesReturned, 0);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Left:= Screen.Width div 2 - Width div 2;
  Top:= Screen.Height div 2 - Height div 2;
  Font.Name:= 'Microsoft Sans Serif';

  Edit1.Text:= IntToStr(GetCurrentProcessId);
  _EnablePrivilegeW('SeLoadDriverPrivilege');
  _LoadDriverW(ExtractFilePath(ParamStr(0)) + 'ProtectDriver.sys');
  SendFunctionsAddresses;
  SendProtectInfo;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SendProtectInfo;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
var
  dwBytesReturned: DWORD;
begin
  //  $0902 - On
  //  $0903 - Off
  if not CheckBox1.Checked then
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0903, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0)
  else
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0902, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
var
  dwBytesReturned: DWORD;
begin
  //  $0904 - On
  //  $0905 - Off
  if not CheckBox2.Checked then
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0905, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0)
  else
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0904, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
var
  dwBytesReturned: DWORD;
begin
  //  $0906 - On
  //  $0907 - Off
  if not CheckBox3.Checked then
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0907, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0)
  else
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0906, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
var
  dwBytesReturned: DWORD;
begin
  //  $0908 - On
  //  $0909 - Off
  if not CheckBox4.Checked then
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0909, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0)
  else
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0908, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
end;

procedure TForm1.CheckBox5Click(Sender: TObject);
var
  dwBytesReturned: DWORD;
begin
  //  $0910 - On
  //  $0911 - Off
  if not CheckBox5.Checked then
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0911, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0)
  else
     DeviceIoControl(DriverDevice, CTL_CODE($F100, $0910, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  dwBytesReturned: DWORD;
begin
  CanClose:= False;
  DeviceIoControl(DriverDevice, CTL_CODE($F100, $0903, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
  DeviceIoControl(DriverDevice, CTL_CODE($F100, $0905, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
  DeviceIoControl(DriverDevice, CTL_CODE($F100, $0907, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
  DeviceIoControl(DriverDevice, CTL_CODE($F100, $0909, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
  DeviceIoControl(DriverDevice, CTL_CODE($F100, $0911, 0, 0), nil, 0, nil, 0, dwBytesReturned, 0);
  _UnloadDriverW;
  CanClose:= True;
end;

end.
