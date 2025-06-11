unit SignInfo;

interface
uses
  Winapi.Windows;

type

  ISignInfo = interface
    ['{568999DB-4739-402B-A9E0-B7500FCE4C97}']
    function GetCertOwnerString: string;
    function GetCertIssuerString: string;
    function GetCertFingerprintString: string;
    function IsSigned: Boolean;
  end;

  TSignInfo = class(TInterfacedObject, ISignInfo)
  private
      // Win32 data structures
    FCert: PWinCertificate;
    FCertContext: PCCERT_CONTEXT;
      // analysis results
    FCertOwner: string;
    FCertIssuer: string;
    FCertFingerprint: string;
    FIsSigned: Boolean;
    procedure AnalyzeExecutableFile(const FileName: string);
    function GetCertificateContext(const FileName: string): PCCERT_CONTEXT;
  public
    constructor Create(const FileName: string);
    function GetCertOwnerString: string;
    function GetCertIssuerString: string;
    function GetCertFingerprintString: string;
    function IsSigned: Boolean;
    destructor Destroy; override;
  end;

function IsTrustedExecutableImage(const FileName: string): Boolean;
function GetCurrentExecutablePath: string;

implementation
uses
  System.SysUtils;

  // Retrieves the fully qualified path for the file that contains the module used to create the current process.
  // Reason: The ParamStr(0) depends on the command line and can be tampered.
function GetCurrentExecutablePath: string;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
  Len: DWORD;
begin

  Len := GetModuleFileNameW(0, Buffer, Length(Buffer));
  if Len = 0 then
    RaiseLastOSError;
  Result := Buffer;
end;

function IsTrustedExecutableImage(const FileName: string): Boolean;
var
  WinTrustFileInfo: WINTRUST_FILE_INFO;
  WinTrustData: WINTRUST_DATA;
  WinTrustAction: TGUID;
  ResultStatus: LongInt;
begin
    // https://learn.microsoft.com/en-us/windows/win32/api/wintrust/ns-wintrust-wintrust_file_info
  ZeroMemory(@WinTrustFileInfo, SizeOf(WINTRUST_FILE_INFO));
  WinTrustFileInfo.cbStruct := SizeOf(WINTRUST_FILE_INFO);
  WinTrustFileInfo.pcwszFilePath := PWideChar(FileName);
  WinTrustFileInfo.hFile := 0;
  WinTrustFileInfo.pgKnownSubject := nil;

    // https://learn.microsoft.com/de-de/windows/win32/api/wintrust/ns-wintrust-wintrust_data
  ZeroMemory(@WinTrustData, SizeOf(WINTRUST_DATA));
  WinTrustData.cbStruct := SizeOf(WINTRUST_DATA);
  WinTrustData.pPolicyCallbackData := nil;
  WinTrustData.pSIPClientData := nil;
  WinTrustData.dwUIChoice := WTD_UI_NONE;
  WinTrustData.fdwRevocationChecks := WTD_REVOKE_NONE;
  WinTrustData.dwUnionChoice := WTD_CHOICE_FILE;
  WinTrustData.pFile := @WinTrustFileInfo;
  WinTrustData.dwStateAction := WTD_STATEACTION_VERIFY;
  WinTrustData.hWVTStateData := 0;
  WinTrustData.pwszURLReference := nil;
  WinTrustData.dwProvFlags := WTD_SAFER_FLAG;
  WinTrustData.dwUIContext := 0;

    // GUID of the action to be performed
  WinTrustAction := WINTRUST_ACTION_GENERIC_VERIFY_V2;

    // Call WinVerifyTrust to verify the digital signature
  ResultStatus := WinVerifyTrust(INVALID_HANDLE_VALUE, WinTrustAction, @WinTrustData);

    // Check the result
  Result := ResultStatus = ERROR_SUCCESS;

    // Clean up
  WinTrustData.dwStateAction := WTD_STATEACTION_CLOSE;
  WinVerifyTrust(0, WinTrustAction, @WinTrustData);
end;

{ TSignInfo }

// NT only

// Imagehlp.dll
const
  CERT_SECTION_TYPE_ANY = $FF;      // Any Certificate type

function ImageEnumerateCertificates(FileHandle: THandle; TypeFilter: WORD;
  out CertificateCount: DWORD; Indicies: PDWORD; IndexCount: Integer): BOOL; stdcall; external 'Imagehlp.dll';
function ImageGetCertificateHeader(FileHandle: THandle; CertificateIndex: Integer;
  var CertificateHeader: TWinCertificate): BOOL; stdcall; external 'Imagehlp.dll';
function ImageGetCertificateData(FileHandle: THandle; CertificateIndex: Integer;
  Certificate: PWinCertificate; var RequiredLength: DWORD): BOOL; stdcall; external 'Imagehlp.dll';

// Crypt32.dll
const
  CERT_NAME_SIMPLE_DISPLAY_TYPE = 4; // used to get subject name
  CERT_NAME_ISSUER_FLAG         = 1; // used to get issuer name
  PKCS_7_ASN_ENCODING           = $00010000;
  X509_ASN_ENCODING             = $00000001;

type
  HCRYPTPROV_LEGACY = type Pointer;
  PFN_CRYPT_GET_SIGNER_CERTIFICATE = type Pointer;

  CRYPT_VERIFY_MESSAGE_PARA = record
    cbSize: DWORD;
    dwMsgAndCertEncodingType: DWORD;
    hCryptProv: HCRYPTPROV_LEGACY;
    pfnGetSignerCertificate: PFN_CRYPT_GET_SIGNER_CERTIFICATE;
    pvGetArg: Pointer;
  end;

function CryptVerifyMessageSignature(const pVerifyPara: CRYPT_VERIFY_MESSAGE_PARA;
  dwSignerIndex: DWORD; pbSignedBlob: PByte; cbSignedBlob: DWORD; pbDecoded: PBYTE;
  pcbDecoded: PDWORD; ppSignerCert: PCCERT_CONTEXT): BOOL; stdcall; external 'Crypt32.dll';
function CertGetNameStringA(pCertContext: PCCERT_CONTEXT; dwType: DWORD; dwFlags: DWORD; pvTypePara: Pointer;
  pszNameString: PAnsiChar; cchNameString: DWORD): DWORD; stdcall; external 'Crypt32.dll';
function CertFreeCertificateContext(pCertContext: PCCERT_CONTEXT): BOOL; stdcall; external 'Crypt32.dll';
function CertCreateCertificateContext(dwCertEncodingType: DWORD;
  pbCertEncoded: PBYTE; cbCertEncoded: DWORD): PCCERT_CONTEXT; stdcall; external 'Crypt32.dll';
function CryptHashCertificate(hCryptProv: ULONG_PTR; Algid: DWORD; dwFlags: DWORD; pbEncoded: PBYTE;
  cbEncoded: DWORD; pbComputedHash: PBYTE; pcbComputedHash: PDWORD): BOOL; stdcall; external 'Crypt32.dll';

// WinTrust.dll
const
  WINTRUST_ACTION_GENERIC_VERIFY_V2: TGUID = '{00AAC56B-CD44-11d0-8CC2-00C04FC295EE}';
  WTD_CHOICE_FILE                          = 1;
  WTD_REVOKE_NONE                          = 0;
  WTD_UI_NONE                              = 2;

type
  PWinTrustFileInfo = ^TWinTrustFileInfo;
  TWinTrustFileInfo = record
    cbStruct: DWORD;                    // = sizeof(WINTRUST_FILE_INFO)
    pcwszFilePath: PWideChar;           // required, file name to be verified
    hFile: THandle;                     // optional, open handle to pcwszFilePath
    pgKnownSubject: PGUID;              // optional: fill if the subject type is known
  end;

  PWinTrustData = ^TWinTrustData;
  TWinTrustData = record
    cbStruct: DWORD;
    pPolicyCallbackData: Pointer;
    pSIPClientData: Pointer;
    dwUIChoice: DWORD;
    fdwRevocationChecks: DWORD;
    dwUnionChoice: DWORD;
    pFile: PWinTrustFileInfo;
    dwStateAction: DWORD;
    hWVTStateData: THandle;
    pwszURLReference: PWideChar;
    dwProvFlags: DWORD;
    dwUIContext: DWORD;
  end;

function WinVerifyTrust(hwnd: HWND; const ActionID: TGUID; ActionData: Pointer): Longint; stdcall; external wintrust;

constructor TSignInfo.Create(const FileName: string);
begin
  FCertOwner := '';
  FCertIssuer := '';
  FIsSigned := False;
  FCert := nil;
  FCertContext := nil;

  if FileExists(FileName) then
    AnalyzeExecutableFile(FileName);
end;

destructor TSignInfo.Destroy;
begin
  if(FCert <> nil) then
  begin
    FreeMem(FCert);
    FCert := nil;
  end;
  if(FCertContext <> nil) then
  begin
    CertFreeCertificateContext(FCertContext);
    FCertContext := nil;
  end;
  inherited;
end;

  // https://stackoverflow.com/questions/5993877/checking-digital-signature-programmatically-from-delphi
procedure TSignInfo.AnalyzeExecutableFile(const FileName: string);

  function GetCertFingerprint(const Context: PCCERT_CONTEXT): string;
  begin
      // Extract the certificate's fingerprint (SHA-1 hash of the encoded certificate)
    if Assigned(Context) then
    begin
      const ALG_ID_SHA1 = $00008004;
      var Hash: array[0..19] of Byte;
      var HashLen: DWORD := Length(Hash);
      if CryptHashCertificate(0, ALG_ID_SHA1, 0, Context^.pbCertEncoded, Context^.cbCertEncoded, @Hash, @HashLen) then
      begin
        Result := '';
        for var i := 0 to HashLen - 1 do
        begin
          Result := Result + IntToHex(Hash[i], 2);
        end;
      end
      else
        Result := '';
    end
    else
      Result := '';
  end;

  function GetCertInfo(const Context: PCCERT_CONTEXT; Flag: DWORD): string;
  var
    CertName: AnsiString;
    CertNameLen: DWORD;
  begin
    CertNameLen := CertGetNameStringA(Context, CERT_NAME_SIMPLE_DISPLAY_TYPE, Flag, nil, nil, 0);
    SetLength(CertName, CertNameLen - 1);
    CertGetNameStringA(Context, CERT_NAME_SIMPLE_DISPLAY_TYPE, Flag, nil, PAnsiChar(CertName), CertNameLen);
    Result := CertName;
  end;

var
  CertContext: PCCERT_CONTEXT;
  VerifyParams: CRYPT_VERIFY_MESSAGE_PARA;
begin
  CertContext := GetCertificateContext(FileName);
  if CertContext <> nil then
  begin

      // Extract the certificate's subject names. Don't compare the entire
      // certificate or the public key as those will change when the
      // certificate is renewed.
    FCertOwner := GetCertInfo(CertContext, 0);

      // Extract the certificate's issuer names
    FCertIssuer := GetCertInfo(CertContext, CERT_NAME_ISSUER_FLAG);

      // Extract the certificate fingerprint
    FCertFingerprint := GetCertFingerprint(CertContext);
  end;
end;

function TSignInfo.GetCertificateContext(const FileName: string): PCCERT_CONTEXT;
var
  hExe: HMODULE;
  CertCount: DWORD;
  CertName: AnsiString;
  CertNameLen: DWORD;
  VerifyParams: CRYPT_VERIFY_MESSAGE_PARA;
begin
  Result := nil;

    // Verify that the exe was signed by a private key
  hExe := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_RANDOM_ACCESS, 0);
  if hExe = INVALID_HANDLE_VALUE then
    Exit;
  try
      // There should only be one certificate associated with the exe
    if (not ImageEnumerateCertificates(hExe, CERT_SECTION_TYPE_ANY, CertCount, nil, 0)) or (CertCount <> 1) then
      Exit;

      // Read the certificate header so we can get the size needed for the full cert
    GetMem(FCert, SizeOf(TWinCertificate) + 3); // ImageGetCertificateHeader writes an DWORD at bCertificate for some reason

    FCert.dwLength := 0;
    FCert.wRevision := WIN_CERT_REVISION_1_0;
    if not ImageGetCertificateHeader(hExe, 0, FCert^) then
      Exit;

      // Read the full certificate
    ReallocMem(FCert, SizeOf(TWinCertificate) + FCert.dwLength);
    if not ImageGetCertificateData(hExe, 0, FCert, FCert.dwLength) then
      Exit;

      // Get the certificate context.  CryptVerifyMessageSignature has the
      // side effect of creating a context for the signing certificate.
    FillChar(VerifyParams, SizeOf(VerifyParams), 0);
    VerifyParams.cbSize := SizeOf(VerifyParams);
    VerifyParams.dwMsgAndCertEncodingType := X509_ASN_ENCODING or PKCS_7_ASN_ENCODING;
    if not CryptVerifyMessageSignature(VerifyParams, 0, @FCert.bCertificate,
       FCert.dwLength, nil, nil, @FCertContext) then
      Exit;

      // at this point there is some valid certificate
    FIsSigned := True;
    Result := FCertContext;

  finally
    CloseHandle(hExe);
  end;
end;

function TSignInfo.GetCertOwnerString: string;
begin
  Result := FCertOwner;
end;

function TSignInfo.GetCertIssuerString: string;
begin
  Result := FCertIssuer;
end;

function TSignInfo.GetCertFingerprintString: string;
begin
  Result := FCertFingerprint;
end;

function TSignInfo.IsSigned: Boolean;
begin
  Result := FIsSigned;
end;


end.
