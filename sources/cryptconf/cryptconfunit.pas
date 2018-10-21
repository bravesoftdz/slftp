unit cryptconfunit;

interface

uses{$IFDEF MSWINDOWS}System.SysUtils{$ELSE}SysUtils{$ENDIF}, {$IFDEF MSWINDOWS}System.Classes{$ELSE}Classes{$ENDIF}, {$IFDEF MSWINDOWS}System.Math{$ELSE}Math{$ENDIF}, encinifile, helper
{$IFDEF FPC}
,strutils
{$ENDIF}
;


{$I kv.inc}

//function GenerateKeyValue:boolean;

procedure DisplayHelp(expanded: boolean = False);

function ReadPassword(pwfile: string = 'masterpass.txt'): string;
function PassphraseQuality(const Password: string): Extended;
function RandomString: string;

function EncryptFile(const inputfile, outputfile: string; password: string = ''): boolean;
function DecryptFile(const inputfile, outputfile: string; password: string = ''): boolean;

//function DecryptFile(const inputfile, outputfile: string; {$IFDEF UNICODE}password: ansistring = ''{$ELSE}password: string = ''{$ENDIF}): boolean;
//function EncryptFile(const inputfile, outputfile: string; {$IFDEF UNICODE}password: ansistring = ''{$ELSE}password: string = ''{$ENDIF}): boolean;
function DecryptFixIni(inputfile, outputfile: string): boolean;

// needed for newer version than slftp 1.5.3.0 (all valuenames are lowercase now)
function ChangeConfigValuesToLowercase(const inputfile, outputfile: string; password: string = ''): boolean;

const
  CC_VERSION: string = '3.2.1';
  CC_CharSet: string = '^1234567890ߴqwertzuiop�+asdfghjkl��#<yxcvbnm,.-�!"�$%&/()=?`QWERTZUIOP�*ASDFGHJKL��''>YXCVBNM;:_';

implementation

procedure DisplayHelp(expanded: boolean = False);
begin
WriteLn(Format('TeamSoulless - CryptConf v%s  (c)2000-2016',[CC_VERSION]));
WriteLn('');
if not expanded then begin
WriteLn(Format(' %12s %3s',['Syntax',':']));
WriteLn(Format(' %s <operation> Input_File Output_File [options]',[extractfilename(paramstr(0))]));
WriteLn(Format(' %s --help', [ExtractFileName(ParamStr(0))]));
  Exit;
end;
WriteLn(Format(' %12s %3s',['Syntax',':']));
WriteLn(Format('  %s <operation> Input_File Output_File [options]',[extractfilename(paramstr(0))]));
WriteLn(Format(' %12s %3s',['Operations',':']));
WriteLn(Format('%12s %7s %s',['-e',':','Encrypts the input file']));
WriteLn(Format('%12s %7s %s',['-d',':','Decrypts the input file']));
WriteLn(Format('%13s %6s %s',['-lc',':','For slFtp +1.5.4 (all valuenames are lowercase now)']));
WriteLn(Format('%18s %s %s',['-fixzero',':','Was for older SLFTP Configfiles... (1.1.*)']));
WriteLn(Format(' %12s %3s',['Options',':']));
WriteLn(Format('%15s %4s %s',['--pw',':',' Reads the password from the Command Line Prompt']));
WriteLn(Format('%15s %4s %s',['--pf',':','Reads the password on a unicellular text file']));
WriteLn(Format(' %12s %3s',['Synopsis',':']));
WriteLn(Format('	%s -d slftp.rules rules.txt --pw prettyunsecured',[extractfilename(paramstr(0))]));
WriteLn(Format('	%s -e rules.plain slftp.rules --pw prettyunsecured',[extractfilename(paramstr(0))]));
WriteLn(Format('	%s -d slftp.rules rules.txt --pf key.txt',[extractfilename(paramstr(0))]));
WriteLn(Format('	%s -e rules.plain slftp.rules --pf key.txt',[extractfilename(paramstr(0))]));
{$IFDEF MSWINDOWS}
WriteLn('');
Writeln('Press any key...');
readln;
{$ENDIF}
end;

{#    Password Stuff    }

function ReadPassword(pwfile: string = 'masterpass.txt'): string;
var
  pf: TStringlist;
  pfc: TEncStringlist;
begin
  pf := TStringlist.Create;
  if fileexists(pwfile) then
  begin
    pf.LoadFromFile(pwfile);
    result := pf.Strings[0];
  end
  else
  begin
    writeln(Format('Error, %s dose not exists!',[pwfile]));
    result := '';
    //Halt(1);
  end;
end;

function RandomString: string;
var
  i: Integer;
begin
  SetLength(Result, 24);
  for i := 1 to 24 do
    Result[i] := CC_CharSet[1 + Random(Length(CC_CharSet))];
end;
function PassphraseQuality(const Password : string): Extended;
// returns computed Quality in range 0.0 to 1.0
// source extracted from Delphi Encryption Compendium, DEC
// Convert to Delphi 2009 by Fabian (Nickname: xZise)
  function Diff(const AWord1, AWord2 : Word) : Word; overload;
  begin
    if AWord1 > AWord2 then
      Result := AWord1 - AWord2
    else
      Result := AWord2 - AWord1;
  end;
  function Diff(const AByte1, AByte2 : Byte) : Byte; overload;
  begin
    if AByte1 > AByte2 then
      Result := AByte1 - AByte2
    else
      Result := AByte2 - AByte1;
  end;
  {$IFDEF Unicode}
  function Entropy(P: PWordArray; L: Integer): Extended;
  {$ELSE}
  function Entropy(P: PByteArray; L: Integer): Extended;
  {$ENDIF}
  var
    Freq: Extended;
    I: Integer;
    {$IFDEF Unicode}
    Accu: array [Word] of LongWord;
    {$ELSE}
    Accu: array [Byte] of LongWord;
    {$ENDIF}
  begin
    Result := 0.0;
    if L <= 0 then Exit;
    FillChar(Accu, SizeOf(Accu), 0);
    for I := 0 to L-1 do Inc(Accu[P[I]]);
    for I := 0 to High(Accu) do
      if Accu[I] <> 0 then
      begin
        Freq := Accu[I] / L;
        Result := Result - Freq * (Ln(Freq) / Ln(2));
      end;
  end;
  function Differency: Extended;
  var
    S: string;
    L,I: Integer;
  begin
    Result := 0.0;
    L := Length(Password);
    if L <= 1 then Exit;
    SetLength(S, L-1);
    for I := 2 to L do
    begin
      {$IFDEF Unicode}
      Word(S[I-1]) := Diff(Word(Password[I-1]), Word(Password[I]));
      {$ELSE}
      Byte(S[I-1]) := Diff(Byte(Password[I-1]), Byte(Password[I]));
      {$ENDIF}
    end;
    Result := Entropy(Pointer(S), Length(S));
  end;
  function KeyDiff: Extended;
  var
    S: string;
    L,I,J: Integer;
  begin
    Result := 0.0;
    L := Length(Password);
    if L <= 1 then Exit;
    S := Password;
    UniqueString(S);
    for I := 1 to L do
    begin
      J := Pos(S[I], CC_CharSet);
      if J > 0 then S[I] := Char(J);
    end;
    for I := 2 to L do
    begin
      {$IFDEF Unicode}
      Word(S[I-1]) := Diff(Word(S[I-1]), Word(S[I]));
      {$ELSE}
      Byte(S[I-1]) := Diff(Byte(S[I-1]), Byte(S[I]));
      {$ENDIF}
    end;
    Result := Entropy(Pointer(S), L-1);
  end;
const
  GoodLength = 10.0; // good length of Passphrases
var
  L: Extended;
begin
  Result := Entropy(Pointer(Password), Length(Password));
  if Result <> 0 then
  begin
    Result := Result * (Ln(Length(Password)) / Ln(GoodLength));
    L := KeyDiff + Differency;
    if L <> 0 then L := L / 64;
    Result := Result * L;
    if Result < 0 then Result := -Result;
    if Result > 1 then Result := 1;
  end;
end;

procedure WipeString(var password: string);
var
  i: integer;
begin
  password := '@';
  for I := 0 to 10 do
    password := password;
  password := '|';
  for I := 0 to 10 do
    password := password;
  password := '^';
  for I := 0 to 10 do
    password := password;
  password := '[';
  for I := 0 to 10 do
    password := password;
  password := '';
end;

{#    Decrypt | Encrypt Stuff     #}

function DecryptFile(const inputfile, outputfile: string; password: string = ''): boolean;
var
  x: TEncStringlist;
  y: TStringList;
  upw: string;
begin
  result := False;
  if password = '' then
    upw := MyGetPass('Password: ')
  else
    upw := password;
  try
    x := TEncStringlist.Create(upw);
    y := TStringList.Create;
    try
      x.LoadFromFile(inputfile);
      y.Assign(x);
      y.SaveToFile(outputfile);
      result := True;
    finally
      x.free;
      y.free;
      WipeString(upw);
      WipeString(password);
    end;
  except on E: Exception do
    begin
      WriteLn('Decryption failed with error:');
      WriteLn(E.Message);
      //
    end;
  end;
end;

//function EncryptFile(const inputfile, outputfile: string; {$IFDEF UNICODE}password: ansistring = ''{$ELSE}password: string = ''{$ENDIF}): boolean;

function EncryptFile(const inputfile, outputfile: string; password: string = ''): boolean;
var
  x: TEncStringlist;
  y: TStringList;
  //{$IFDEF UNICODE}upw: ansistring{$ELSE}upw: string;{$ENDIF}
  upw: string;
begin
  result := False;
  if password = '' then begin
    upw := MyGetPass('Password: ');
    if MyGetPass('Again: ') <> upw then begin
    Writeln('Passwords dont match');
      halt(1);
    end;
  end
  else
    upw := password;
  try
    x := TEncStringlist.Create(upw);
    y := TStringList.Create;
    try
      y.LoadFromFile(inputfile);
      x.Assign(y);
      x.SaveToFile(outputfile);
      result := True;
    finally
      x.free;
      y.free;
      WipeString(upw);
      WipeString(password);
    end;
  except on E: Exception do
    begin
      WriteLn('Encryption failed with error:');
      WriteLn(E.Message);
    end;
  end;
end;

function DecryptFixIni(inputfile, outputfile: string): boolean;
var
  x: TEncStringlist;
  y: TStringList;
begin
  result := False;
  try
    x := TEncStringlist.Create();
    y := TStringList.Create;
    try
      x.LoadFromFile(inputfile);
      y.Assign(x);
      y.SaveToFile(outputfile);
    finally
      result := True;
      x.free;
      y.free;
    end;
  except on E: Exception do
    begin
      WriteLn('Fixzero failed with error:');
      WriteLn(E.Message);
    end;
  end;
end;


function ChangeConfigValuesToLowercase(const inputfile, outputfile: string; password: string = ''): boolean;
var
  x: TEncStringlist;
  y: TStringList;
  i: Integer;
  upw: string;
begin
  Result := False;

  if password = '' then
    upw := MyGetPass('Password: ')
  else
    upw := password;

  try
    x := TEncStringlist.Create(upw);
    try
      x.LoadFromFile(inputfile);
      for i := 0 to x.Count - 1 do
      begin
      if
      {$IFDEF FPC}
      ((x.Strings[i] = '') or (AnsiStartsStr('[',x.Strings[i])))
      {$ELSE}
      (x.Strings[i].StartsWith('[') or x.Strings[i].IsEmpty)
      {$ENDIF}
      then
        continue;
        if x.Names[i] = 'ProxyName' then x.Strings[i] := lowercase(x.Names[i]) + '=' + x.ValueFromIndex[i];
        if x.Names[i] = 'NoLoginMSG' then x.Strings[i] := lowercase(x.Names[i]) + '=' + x.ValueFromIndex[i];
        if x.Names[i] = 'IRCNick' then x.Strings[i] := lowercase(x.Names[i]) + '=' + x.ValueFromIndex[i];
        if x.Names[i] = 'SiteInfos' then x.Strings[i] := lowercase(x.Names[i]) + '=' + x.ValueFromIndex[i];
      end;
      x.SaveToFile(outputfile);
    finally
      x.free;
    end;
  except on E: Exception do
    begin
      WriteLn('Changing valuenames to lowercase failed with error:');
      WriteLn(E.Message);
      exit;
    end;
  end;
  
  Result := True;
end;

(*
function GenerateKeyValue:boolean;
var kv:TStringlist; kvc:TEncStringlist; kvindex:integer;
  I: Integer;
  passphqul:integer;
  passphquls:string;
{$IFDEF UNICODE}upw: ansistring{$ELSE}upw: string;{$ENDIF}
begin

result:=False;
passphquls:='----------';
upw:=MyGetPass('Password: ');
passphqul:=Round(PassphraseQuality(upw));
for I := 0 to passphqul -1 do passphquls[i]:='#';

Writeln(Format('Passphrase quality:',[passphquls]));
//Exit;
kv:=TStringlist.Create;
kvindex:=RandomRange(4,15);
kv.Add('<!----------SLFTP-KEY-VALUE---------->');
kv.Add(Format('<Index="%d" />',[kvindex]));
for I := 1 to kvindex -1 do kv.Add(Format('<KV Key="%s" />',[RandomString]));
kv.Add(Format('<KV Key="%s" />',[upw]));
for I := 1 to RandomRange(10,25) do kv.Add(Format('<KV Key="%s" />',[RandomString]));
kv.Add('<!----------SLFTP-KEY-VALUE----------/>');

try
kvc:=TEncStringlist.Create(mykey);
try
kvc.Assign(kv);
kvc.SaveToFile('cmasterkey.txt');
result:=True;
finally
 kvc.free;
 kv.free;
end;
except  on E:Exception do begin
WriteLn('Save crypted masterkey file failed with error:');
WriteLn(E.Message);
end;
end;
end;

*)
end.

