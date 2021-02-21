(*

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*)

unit OpenMQO;
// list of all objects available to the client program. public usable stuff
interface

uses
  Windows, SysUtils, OpenGl1x, FileRSM, StrUtils, RScolor;

Type
 ki4 = array[0..3] of Integer;
 ki4d = array[0..3] of Double;
 ki6 = array[0..5] of Integer;


//function LoadFile(FileName: String): Boolean;
//procedure Close;
procedure LoadMQO(FileName: String);

var
 MQOver: array of ki4;
 MQOmat: array of ki4d;
 MQOface: array of ki6;
  kmat_i, kobj_i, kver_i, kface_i,EofCount : Integer;
  kEofFlag : Boolean;
//  V, F, Tex: array of TVector3i;
//  C, M, A: array of Integer;
//  N: array of TVector3f;
//  FileNamek: string;
//  Fout2: File;
  MQOin: TextFile;
//  GNumVertices, GNumTriangles, GNumTexTriangles, GTextured, Gi1,
//  GTransparent, Gk1, Gl1, GXsSize, GYsSize, GZsSize, GTriangleDataLength: Integer;
//end of list of objects available to client

implementation

function GetNormal(V1, V2, V3: TVector3i): TVector3f;
var l: single;
Begin
  V2[0] := -V2[0];
  V2[1] := -V2[1];
  V2[2] := -V2[2];
  V1[0] := V1[0] + V2[0];
  V1[1] := V1[1] + V2[1];
  V1[2] := V1[2] + V2[2];
  V3[0] := V3[0] + V2[0];
  V3[1] := V3[1] + V2[1];
  V3[2] := V3[2] + V2[2];
  Result[0] := v1[1] * v3[2] - v3[1] * v1[2];
  Result[1] := v3[0] * v1[2] - v1[0] * v3[2];
  Result[2] := v1[0] * v3[1] - v3[0] * v1[1];
  l := sqrt(Result[0]*Result[0] + Result[1]*Result[1] + Result[2]*Result[2]);
  if l <> 0 then
  begin
    Result[0] := Result[0] / l;
    Result[1] := Result[1] / l;
    Result[2] := Result[2] / l;
  end;
  Result := Result;
end;


procedure CalcNormals;
var
  i, j, Count: Integer;
  l: Single;
  Normal: TVector3f;
  FaceNormals: array of TVector3f;
begin
   SetLength(N, Length(V));
   SetLength(FaceNormals, Length(F));

   for i := 0 to High(F) do begin
     Normal := GetNormal(V[F[i][0]], V[F[i][1]], V[F[i][2]]);
     FaceNormals[i] := Normal;
   end;

  for i := 0 to High(V) do
  begin
    ZeroMemory(@Normal, SizeOf(Normal));
    Count := 0;
    for j := 0 to High(F) do
    begin
      if (F[j][0] = i) or (F[j][1] = i) or (F[j][2] = i) then
      begin
        Normal[0] := Normal[0] + FaceNormals[j][0];
        Normal[1] := Normal[1] + FaceNormals[j][1];
        Normal[2] := Normal[2] + FaceNormals[j][2];
        Inc(Count);
      end;
    end;
    N[I][0] := -Normal[0] / Count;
    N[I][1] := -Normal[1] / Count;
    N[I][2] := -Normal[2] / Count;
    l := sqrt(N[I][0]*N[I][0] + N[I][1]*N[I][1] + N[I][2]*N[I][2]);
    if l <> 0 then
    begin
      N[I][0] := N[I][0] / l;
      N[I][1] := N[I][1] / l;
      N[I][2] := N[I][2] / l;
    end;
  end;
end;

function LoadFile(FileName: String): Boolean;
begin

  AssignFile(MQOin, FileName);
{$I-}
  Reset(MQOin);
{$I+}
  if IOResult <> 0 then
    Result := false else Result := true;
end;

function ReadWord(): String;
Var
str1,str2 : String;
ch1 : Char;
begin
str1 := ' ';
repeat
     Read(MQOin, ch1);
     if ch1 <> #09 then str1 := str1 + ch1;
     Inc(EofCount);
until ((ch1 = ' ') OR (ch1 = #13) );

 str2:=Trim(str1);
 If str2 = 'EOF' then kEofFlag := True;
 If str2 = 'Eof' then kEofFlag := True;
// If (EofCount >= FileSize(MQOin)) then kEofFlag := True;
 Result := str2;
end;

function SubString(str1: String; Intk1 :Integer ): String;
Var
str2 : String;
Len1 : Integer;
begin
str2 := str1;
Len1 := Length(str2)-Intk1;
Delete(str1,1,Intk1);
// Delete(FileExt,1,NameLen - 4);  Length(FileExt);
Result := str1;
end;

function SubString2(str1: String; Intk1, Intk2 :Integer ): String;
Var
str2 : String;
Len1 : Integer;
begin
str2 := str1;
Len1 := Length(str2)-Intk1;
Delete(str2,Intk1,Intk2);
// Delete(FileExt,1,NameLen - 4);  Length(FileExt);
Result := str2;
end;

procedure SetToZero();
var
i : Integer;
begin
  SetLength(V, 0);
  SetLength(F, 0);
  SetLength(C, 0);
  SetLength(A, 0);
     GTextured := 0;
   GNumTriangles := 0;
   kface_i := 0;
   GNumVertices := 0;
   Kver_i := 0;

end;

procedure LoadArrays();
var
i : Integer;
r,g,b : Double;
begin
  SetLength(V, 0); SetLength(V, kver_i);
  SetLength(F, 0); SetLength(F, kface_i);
  SetLength(C, 0); SetLength(C, kface_i);
  SetLength(A, 0); SetLength(A, kface_i);
  for i := 0 to kver_i-1 do
   begin
    V[i][0] := MQOver[i][0];
    V[i][1] := MQOver[i][1];
    V[i][2] := MQOver[i][2];
   end;
  for i := 0 to kface_i-1 do
   begin
      F[i][0] := MQOface[i][2];
      F[i][1] := MQOface[i][1];
      F[i][2] := MQOface[i][0];
      r := MQOmat[MQOface[i][4]][0];
      g := MQOmat[MQOface[i][4]][1];
      b := MQOmat[MQOface[i][4]][2];
      C[i] := GetColor(r,g,b);
      A[i] := Round((1.0 - MQOmat[MQOface[i][4]][3])*255);
      If A[i] < 0 then A[i] := 0;
      If A[i] > 255 then A[i] := 255;
   end;
   GTextured := 0;
   GNumTriangles := kface_i;
   GNumVertices := Kver_i;
end;

procedure Close;
begin
  CloseFile(MQOin);
end;

// READ METASEQUOIA FILE

procedure LoadMQO(FileName: String);
var
  mat_i, obj_i, ver_i, face_i, i, j ,k,q,debug: Integer;
  IsValid: Boolean;
  flag : boolean;
  s1,s2: String;

  begin
  EofCount :=0;
  kEofFlag := False;
  SetLength(MQOmat, 0);
  SetLength(MQOver, 0); SetLength(MQOver, 1);
  SetLength(MQOface, 0); 
  //SetLength(V, NumVertices);
  IsValid := true;
  flag := true;
  i := 0;
  j := 0;
  k := 0;
  mat_i := 0;
  obj_i := 0;
  ver_i := 0;
  face_i := 0;
  LoadFile(FileName);
  if not LoadFile(FileName) then
  begin
    MessageBox(0, 'mqo---Unable to load file.', 'Error', 0);
    Exit;
  end;
  IF FileSize(MQOin) < 10 then kEofFlag := True;
  try
    s1 := ' ';

     while  not(kEofFlag) do
       begin
       s1 := ReadWord;
      //  WriteLn(Output, s1,':');
          Case i of
            0: // '\0'
              begin
              for q := 0 to 1 do begin
               if AnsiCompareStr(s1,'Scene') = 0 then
                 begin
               //    WriteLn(Output, 'scenefound');
                   i := 1;
                   break;
                 end;
                if AnsiCompareStr(s1, 'Material') = 0 then
                 begin
              //   WriteLn(Output, 'matfound');
                   i := 2;
                   break;
                 end;
                 if AnsiCompareStr(s1, 'Object') = 0 then
                 begin
                 i := 3;
                 break;
                 end;
                 i := 0;
                break;
           //     Write(Output, 'kkk= ',i);
               end; //of stupid for loop 
              end; //case 0


            1: // '\001'
              begin
               for q := 0 to 1 do begin
                if AnsiCompareStr(s1, '}') = 0 then
                begin
                i := 0;
                end;
               break;
               end; //of stupid for loop
              end; // of case1

            2: // '\002'
              begin
              for q := 0 to 1 do begin
                if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 0;
                        break;
                    end;
                if AnsiStartsStr('col(', s1) then
                    begin
                        SetLength(MQOmat,Length(MQOmat)+1);
                        s2 := SubString(s1,4);
                 //       WriteLn(Output, ' test1 ',s2);
                        MQOmat[mat_i][0] :=  StrToFloat(s2);
                   //     WriteLn(Output, ' test2 ');
                        j := 1;
                       break;
                    end;
                if(j = 1) OR (j = 2) then
                    begin
                        SetLength(MQOmat,Length(MQOmat)+1);
                        MQOmat[mat_i][j] := StrToFloat(s1);
                        MQOmat[mat_i][3] := 0;
                        inc(j);
                        break;
                    end;
                if(j = 3) then
                    begin
                        SetLength(MQOmat,Length(MQOmat)+1);
                        s2 := SubString2(s1,Length(s1), 1);
                  //      WriteLn(Output, ' testk1 ',s2);
                        MQOmat[mat_i][3] := StrToFloat(s2);
                        inc(mat_i);
                        j := 0;
                    end;
                 break;
                end; // of stupid for loop
               end; //of case2


            3: // '\003'
              begin
              for q := 0 to 1 do begin
               if AnsiCompareStr(s1, '}') = 0 then
                begin
                 k := ver_i;
                 i := 0;
                 inc(obj_i);
                 break;
                end;
               if AnsiCompareStr(s1, 'vertex') = 0 then
                begin
                 i := 31;
                 j := -1;
                 break;
                end;
               if AnsiCompareStr(s1, 'face') = 0 then
               begin
               i := 32;
               break;
               end;
               
             break;
             end;//of stupid for loop
            end; //of case 3



            31: // '\037'
             begin
               for q := 0 to 1 do begin
          //     WriteLn(output, 'case31');
                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 3;
                        break;
                    end;
                    if AnsiCompareStr(s1, '{') = 0 then
                    begin
                        j := 0;
                        break;
                    end;
                     if AnsiCompareStr(s1, '') = 0 then break;
                    if (j < 0) then
                        break;
        //         SetLength(MQOver,Length(MQOver)+1);

//this set length is not in the correct place

                     debug := 666;
           //         debug := Round(StrToFloat(s1));
          //          WriteLn(Output,s1, '-vertex pos = ', debug,' ',ver_i,' ',j);
                   MQOver[ver_i][j] := Round(StrToFloat(s1));
                   j:=j+1;
                    if j = 3 then
                    begin
                        j := 0;
                        inc(ver_i);
                        SetLength(MQOver,Length(MQOver)+1);
                    end;
              break;
              end;//of stupid for loop
             end; //of case 31

 ///working up to here
//remember the stupid for loops            

           32: // ' '
            begin
              for q := 0 to 1 do begin
        //      WriteLn(output, 'case32');
                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 3;
                        break;
                    end;
                    if AnsiStartsStr('V', s1) then
                    begin
                       SetLength(MQOface,Length(MQOface)+1);
                       s2 := (SubString(s1,2));
                 //      WriteLn(Output, 's2 =',s2, ' +', face_i);
                       MQOface[face_i][0] := StrToInt(SubString(s1,2)) + k;
                        MQOface[face_i][5] := obj_i;
                        j := 1;
                        break;
                    end;
                    if(j = 1) then
                    begin
                        MQOface[face_i][1] := StrToInt(s1) + k;
                        j := 2;
                        break;
                    end;
                    if(j = 2) then
                      begin
                        if AnsiEndsStr(')', s1) then
                        begin
                            MQOface[face_i][2] :=  StrToInt(SubString2(s1 ,Length(s1), 1)) + k;
                            MQOface[face_i][3] := MQOface[face_i][2];
                            inc(face_i);
                            j := 0;
                        end else
                        begin
                           MQOface[face_i][2] := StrToInt(s1) + k;
                            j := 3;
                        end;
                       break;
                      end;
                    if(j = 3) then
                    begin
                        MQOface[face_i][3] := StrToInt( SubString2(s1 ,Length(s1), 1)) + k;
                        inc(face_i);
                        j := 0;
                        break;
                    end;
                    if AnsiStartsStr('M', s1) then
                    begin
                        s2 := StringReplace(s1, 'M(', '', [rfReplaceAll, rfIgnoreCase]);
                        s1 := StringReplace(s2, ')', '', [rfReplaceAll, rfIgnoreCase]);
                        MQOface[face_i - 1][4] := StrToInt(s1);

                    end;
                break;
                end; //of stupid for loop
               end; //of case 32



          end; //end of case statement
 //   ReadLn(Input);
        end;//end of while
  except
  IsValid := false;
  SetToZero;
  end;

  if not IsValid then begin
    MessageBox(0, 'MQO Invalid file format.', 'Error', 0);
    Close;
    Exit;
  end;


 // CalcNormals;
 //  FileNamek := FileName;
 //     Writeln(Fout2, 'End of file');
     kmat_i := mat_i;
    kobj_i := obj_i;
    kver_i := ver_i;
    kface_i := face_i;
    Close;
 If IsValid then begin
   LoadArrays;
   CalcNormals;
    end;
 end;

end.
