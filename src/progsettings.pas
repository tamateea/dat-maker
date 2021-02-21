unit progsettings;

interface

uses
  Windows, Messages, SysUtils, Variants, OpenGl1x, Forms;

procedure SaveSettings();
procedure LoadSettings();
procedure Delay(msecs:integer);

var
  settingsfile: File;
  setedgecolor,set_t1,set_t2,set_t3,set_t4,set_t5,set_bfill: TVector3f;
  Dir_user, Cur_file_user: String;
  dir_len,cur_name_len,i: Integer;
  Settings_Loaded: Boolean;

implementation

procedure SaveSettings();
var
cpath,cname: String;
savesettings,Result: Boolean;
data: byte;
begin
Result := True;
data := 0;
savesettings := True;
cpath := ExtractFilePath( Application.ExeName );
cname:= cpath + 'settings.dat';
AssignFile(settingsfile, cname);
{$I-}
  ReWrite(settingsfile, 1);
{$I+}
  if IOResult <> 0 then begin
    Result := false;
   // MessageBox(0, PChar(IntToStr(IOResult)), 'I/O Error', 0);
    end;
    AssignFile(settingsfile, cname);
{$I-}
  ReWrite(settingsfile, 1);
{$I+}
  if IOResult <> 0 then begin
    Result := false;
  //  MessageBox(0, PChar(IntToStr(IOResult)), 'I/O Error', 0);
    end;
data:=Round(set_bfill[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_bfill[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_bfill[2]*255); BlockWrite(settingsfile, data, 1);
data:=Round(setedgecolor[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(setedgecolor[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(setedgecolor[2]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t1[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t1[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t1[2]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t2[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t2[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t2[2]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t4[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t4[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t4[2]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t3[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t3[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t3[2]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t5[0]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t5[1]*255); BlockWrite(settingsfile, data, 1);
data:=Round(set_t5[2]*255); BlockWrite(settingsfile, data, 1);

dir_len := Length(Dir_user);
data:= dir_len; BlockWrite(settingsfile, data, 1);
If dir_len > 0 then begin
  for i := 1 to dir_len do
     begin
        data := Ord(Dir_user[i]);
        BlockWrite(settingsfile, data, 1);
     end;
end;
//MessageBox(0, PChar(':'+Dir_user+':'+IntToStr(Length(Dir_user))), PChar('current dir'), MB_OK);

cur_name_len := Length(Cur_file_user);
data:= cur_name_len; BlockWrite(settingsfile, data, 1);
If cur_name_len > 0 then begin
  for i := 1 to cur_name_len do
     begin
        data := Ord(Cur_file_user[i]);
        BlockWrite(settingsfile, data, 1);
     end;
end;
// MessageBox(0, PChar(':'+Cur_file_user+':'+IntToStr(Length(Cur_file_user))), PChar('current dir'), MB_OK);



try
  CloseFile(settingsfile);
except
savesettings:=False;
    end;

 If (savesettings = False) OR (Result = False) then  MessageBox(0, PChar('Could not save settings'), PChar('Error'), MB_OK);

end;


procedure LoadSettings();
var
cpath,cname: String;
savesettings,Result: Boolean;
data: byte;
begin
Settings_Loaded := True;
Result := True;
data := 0;
savesettings := True;
cpath := ExtractFilePath( Application.ExeName );
cname:= cpath + 'settings.dat';
AssignFile(settingsfile, cname);
{$I-}
  Reset(settingsfile, 1);
{$I+}
  if IOResult <> 0 then begin
    Result := false;
   // MessageBox(0, PChar(IntToStr(IOResult)), 'I/O Error', 0);
    end;
    AssignFile(settingsfile, cname);
{$I-}
  Reset(settingsfile, 1);
{$I+}
  if IOResult <> 0 then begin
    Result := false;
  //  MessageBox(0, PChar(IntToStr(IOResult)), 'I/O Error', 0);
    end;
If Result = True then begin
try
//MessageBox(0, PChar('test'), 'I/O Error', 0);

BlockRead(settingsfile, data, 1); set_bfill[0]:= data / 255;
BlockRead(settingsfile, data, 1); set_bfill[1]:= data / 255;
BlockRead(settingsfile, data, 1); set_bfill[2]:= data / 255;
BlockRead(settingsfile, data, 1); setedgecolor[0]:= data / 255;
BlockRead(settingsfile, data, 1); setedgecolor[1]:= data / 255;
BlockRead(settingsfile, data, 1); setedgecolor[2]:= data / 255;
BlockRead(settingsfile, data, 1); set_t1[0]:= data / 255;
BlockRead(settingsfile, data, 1); set_t1[1]:= data / 255;
BlockRead(settingsfile, data, 1); set_t1[2]:= data / 255;
BlockRead(settingsfile, data, 1); set_t2[0]:= data / 255;
BlockRead(settingsfile, data, 1); set_t2[1]:= data / 255;
BlockRead(settingsfile, data, 1); set_t2[2]:= data / 255;
BlockRead(settingsfile, data, 1); set_t4[0]:= data / 255;
BlockRead(settingsfile, data, 1); set_t4[1]:= data / 255;
BlockRead(settingsfile, data, 1); set_t4[2]:= data / 255;
BlockRead(settingsfile, data, 1); set_t3[0]:= data / 255;
BlockRead(settingsfile, data, 1); set_t3[1]:= data / 255;
BlockRead(settingsfile, data, 1); set_t3[2]:= data / 255;
BlockRead(settingsfile, data, 1); set_t5[0]:= data / 255;
BlockRead(settingsfile, data, 1); set_t5[1]:= data / 255;
BlockRead(settingsfile, data, 1); set_t5[2]:= data / 255;

BlockRead(settingsfile, data, 1); dir_len := data;

//dir_len := Length(Dir_user);
//data:= dir_len; BlockWrite(settingsfile, data, 1);
Dir_user := '';
If dir_len > 0 then begin
  for i := 1 to dir_len do
     begin
        //data := Ord(Dir_user[i]);
        BlockRead(settingsfile, data, 1);
        Dir_user:=Dir_user+Char(data);
     end;
end;
//MessageBox(0, PChar(':'+Dir_user+':'+IntToStr(Length(Dir_user))), PChar('current dir'), MB_OK);

BlockRead(settingsfile, data, 1); cur_name_len := data;

//cur_name_len := Length(Cur_file_user);
//data:= cur_name_len; BlockWrite(settingsfile, data, 1);
Cur_file_user := '';
If cur_name_len > 0 then begin
  for i := 1 to cur_name_len do
     begin
        //data := Ord(Cur_file_user[i]);
        BlockRead(settingsfile, data, 1);
        Cur_file_user := Cur_file_user + Char(data);
     end;
end;
// MessageBox(0, PChar(':'+Cur_file_user+':'+IntToStr(Length(Cur_file_user))), PChar('current dir'), MB_OK);
except
//dostuff
savesettings:=False;
end;
end;



try
  CloseFile(settingsfile);
except
savesettings:=False;
    end;

 If (savesettings = False) OR (Result = False) then
 begin
 // if can't open then set default values.
 Settings_Loaded := False;
// MessageBox(0, PChar('No settings Found'), PChar('Error'), MB_OK);
 end;

end;

procedure Delay(msecs:integer);
var
   FirstTickCount:longint;
begin
     FirstTickCount:=GetTickCount;
     repeat    
           Application.ProcessMessages; {allowing access to other 
                                         controls, etc.}
     until ((GetTickCount-FirstTickCount) >= Longint(msecs));
end;


end.
