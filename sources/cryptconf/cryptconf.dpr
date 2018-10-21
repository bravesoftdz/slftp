program cryptconf;

{$IFDEF MSWINDOWS}{$APPTYPE CONSOLE}{$ENDIF}

uses
  {$IFDEF MSWINDOWS}System.SysUtils{$ELSE}SysUtils{$ENDIF},
  helper,
  {$IFDEF MSWINDOWS}System.Classes{$ELSE}Classes{$ENDIF},
  encinifile,
  cryptconfunit in 'cryptconfunit.pas';

var
  jobresu: boolean;

begin
  jobresu := False;

  if (ParamStr(1) = '--help') then
  begin
    DisplayHelp(True);
    exit;
  end;

  (*
  if (ParamStr(1) = '--create-kv') then begin
  jobresu:=GenerateKeyValue;
  exit;
  end;
  *)

  if ParamCount < 3 then
  begin
    DisplayHelp;
    halt;
  end;

  if ParamStr(2) = ParamStr(3) then
  begin
    WriteLn('Dont use the same input and output files! It will destroy your source if you mistype the password!');
{$IFDEF MSWINDOWS}
    Writeln('Press any key...');
    readln;
{$ENDIF}
    Halt(1);
  end;

  if ((ParamStr(1) <> '-d') and (ParamStr(1) <> '-e') and (ParamStr(1) <> '-fixzero') and (ParamStr(1) <> '-lowercase') and (ParamStr(1) <> '-lc') and (ParamStr(1) <> '--help')) then
  begin
    WriteLn('No valid trigger, check --help!');
    Halt(1);
  end;

  (*Decrypt*)
  if (ParamStr(1) = '-d') then
  begin
    if (ParamStr(4) = '--pw') then
      jobresu := DecryptFile(ParamStr(2), ParamStr(3), ParamStr(5));
    if (ParamStr(4) = '--pf') then
      jobresu := DecryptFile(ParamStr(2), ParamStr(3), ReadPassword(ParamStr(5)));
    if ParamCount = 3 then
      jobresu := DecryptFile(ParamStr(2), ParamStr(3), '');

    if jobresu then
      WriteLn('Decryption successful!');
  end; //if (ParamStr(1) = '-d') then begin

  (*Encrypt*)
  if (ParamStr(1) = '-e') then
  begin
    if (ParamStr(4) = '--pw') then
      jobresu := EncryptFile(ParamStr(2), ParamStr(3), ParamStr(5));
    if (ParamStr(4) = '--pf') then
      jobresu := EncryptFile(ParamStr(2), ParamStr(3), ReadPassword(ParamStr(5)));
    if ParamCount = 3 then
      jobresu := EncryptFile(ParamStr(2), ParamStr(3), '');

    if jobresu then
      WriteLn('Encryption successful!');
  end; //if (ParamStr(1) = '-e') then begin

  (*Fixzero*)
  if (ParamStr(1) = '-fixzero') then
  begin
    jobresu := DecryptFixIni(ParamStr(2), ParamStr(3));
    if jobresu then
      WriteLn('Fixzero successful!');
  end; //if (ParamStr(1) = '-e') then begin
  
  
  (* lowercase config valuenames *)
  if ((ParamStr(1) = '-lowercase') OR (ParamStr(1) = '-lc')) then
  begin
    if (ParamStr(4) = '--pw') then
      jobresu := ChangeConfigValuesToLowercase(ParamStr(2), ParamStr(3), ParamStr(5));
    if (ParamStr(4) = '--pf') then
      if (ParamStr(5) = '') then
        jobresu := ChangeConfigValuesToLowercase(ParamStr(2), ParamStr(3), ReadPassword())
      else
        jobresu := ChangeConfigValuesToLowercase(ParamStr(2), ParamStr(3), ReadPassword(ParamStr(5)));
    if ParamCount = 3 then
      jobresu := ChangeConfigValuesToLowercase(ParamStr(2), ParamStr(3), '');
    if jobresu then
      WriteLn('Changing values to lowercase successful!');
  end;
  

{$IFDEF MSWINDOWS}
  Writeln('Press any key...');
  readln;
{$ENDIF}

end.

