{*
  seems to be working correctly
  need to set flags for model type....
*}

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
 vweight: array of Integer;
 mqoPRI: array of Integer;
 mqoTSKIN: array of Integer;
 mqoweit1: array of Integer;
 mqoweit2: array of Integer;
 mqoweit3: array of Integer;
  numofmat,matcount,kmat_i, kobj_i, kver_i, kface_i,EofCount,kkkfilesize : Integer;
  vwnum,e,vweightnum,animfacecount: Integer;
  kEofFlag,ignoreflag,quadflag,lineflag,weightflag,isanimflag,modelflag,vskin1flag : Boolean;
  mqoPRIflag, mqoTSKINflag,mqoVSKIN1flag,mqoVSKIN2flag,mqoVSKIN3flag,nomatflag,notestflag: Boolean;
  vskin1_flag,vskin2_flag,vskin3_flag: Boolean;
  Has_Pri, Has_Vskin, Has_Tskin : Boolean;
  errorcode: String;
  //  V, F, Tex: array of TVector3i;
//  C, M, A: array of Integer;
//  N: array of TVector3f;
//  FileNamek: string;
//  Fout2: File;
  MQOin: File;
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
  Reset(MQOin,1);
{$I+}
  if IOResult <> 0 then
    Result := false else Result := true;
end;

function ReadWord(): AnsiString;
Var
str1,str2 : AnsiString;
ch1 : AnsiChar;
bh1 : Byte;
bh2: array of Byte;
begin
SetLength(bh2, 1);
str1 := ' ';
repeat
     BlockRead(MQOin, bh1, 1);
     //Read(MQOin, bh1);
     ch1 := AnsiChar(bh1);
     if (ch1 <> #09) AND (ch1 <> #10) then str1 := str1 + ch1;
     Inc(EofCount);
until ((ch1 = #32) OR (ch1 = #13) OR (ch1 = #160));

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

procedure AddVskins();
var
t : Integer;
begin
 SetLength(vweight, kver_i);
 for t := 0 to kver_i -1 do
   begin
     //WriteLn(Output,'vertex weights.......');
    // ReadLn(Input);
     If (vskin1_flag = True) then vweight[t] := vweight[t]+ mqoweit1[t];
     If (vskin2_flag = True) then vweight[t] := vweight[t]+ mqoweit2[t];
     If (vskin3_flag = True) then vweight[t] := vweight[t]+ mqoweit3[t];
     If vweight[t] > 254 then vweight[t] := 254;
     If vweight[t] < 0 then vweight[t] := 0;
   end;
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
  SetLength(Skin, 0);
  SetLength(Fskin, 0);
  SetLength(t_pri, 0);
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

      //nope !! A[i] := MQOmat[mat_i][3];
   //   A[i] := 1;   //alpha is set wrong here!!!!!
   end;
   GTextured := 0;
   GNumTriangles := kface_i;
   GNumVertices := Kver_i;

   If Has_Pri = True then begin
       SetLength(t_pri, kface_i);
         for i := 0 to kface_i-1 do
          begin
           t_pri[i] := mqoPRI[i];
          end;
      end;

   If Has_Tskin = True then begin
       SetLength(Fskin, kface_i);
         for i := 0 to kface_i-1 do
          begin
           Fskin[i] := mqoTSKIN[i];
          end;
      end;

   If Has_Vskin = True then begin
       SetLength(Skin, kver_i);
         for i := 0 to kver_i-1 do
          begin
           Skin[i] := vweight[i];
          end;
      end;

end;

procedure Close;
begin
  CloseFile(MQOin);
end;

// READ METASEQUOIA FILE

procedure LoadMQO(FileName: String);
var
  mat_i, obj_i, ver_i, face_i, i, j ,k,q,debug,kkkfilesize : Integer;
  IsValid: Boolean;
  flag : boolean;
  s1,s2: String;

  begin
  EofCount :=0;
  kEofFlag := False;
  SetLength(MQOmat, 0);
  SetLength(MQOver, 0); SetLength(MQOver, 1);
  SetLength(MQOface, 0);
  SetLength(vweight, 0);
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
  ignoreflag := False;
  quadflag := False;
  lineflag := False;
  weightflag := False;
  vskin1flag := False;
  isanimflag := False;
  matcount := 0;
  modelflag := True;
  mqoPRIflag := False;
  mqoTSKINflag := False;
  mqoVSKIN1flag := False;
  mqoVSKIN2flag := False;
  mqoVSKIN3flag := False;
  nomatflag := False;
  notestflag := False;
  animfacecount := 0;
  vskin1_flag := False;
  vskin2_flag := False;
  vskin3_flag := False;
  Has_Pri := False;
  Has_Vskin := False;
  Has_Tskin := False;

  LoadFile(FileName);
//   WriteLn(Output,'loading file.......');
  if not LoadFile(FileName) then
  begin
    MessageBox(0, 'mqo---Unable to load file.', 'Error', 0);
    Exit;
  end;
  IF FileSize(MQOin) < 1 then kEofFlag := True;

  try
    s1 := ' ';

     while  not(kEofFlag) do
       begin
       s1 := ReadWord;
  //      WriteLn(Output, s1,':');
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
                   i := 22;
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


            1: // '\001'                    scene test
              begin
               for q := 0 to 1 do begin
                if AnsiCompareStr(s1, '}') = 0 then
                begin
                i := 0;
                end;
               break;
               end; //of stupid for loop
              end; // of case1



            3: // '\003'         object test
              begin
              for q := 0 to 1 do begin
               if AnsiCompareStr(s1, '}') = 0 then
                begin
                 k := ver_i;
                 i := 0;
                 inc(obj_i);
                 break;
                end;

               if AnsiCompareStr(s1, '"PRI:"') = 0 then
                begin
                Has_Pri := True;
                modelflag := False;
                mqoPRIflag := True;
                mqoTSKINflag := False;
                mqoVSKIN1flag := False;
                mqoVSKIN2flag := False;
                mqoVSKIN3flag := False;
                SetLength(mqoPRI,0); SetLength(mqoPRI,face_i);
                  //i := 50
                 break;
                end;

               if AnsiCompareStr(s1, '"TSKIN:"') = 0 then
                begin
                Has_Tskin := True;
                modelflag := False;
                mqoPRIflag := False;
                mqoTSKINflag := True;
                mqoVSKIN1flag := False;
                mqoVSKIN2flag := False;
                mqoVSKIN3flag := False;
                SetLength(mqoTSKIN,0); SetLength(mqoTSKIN,face_i);
                  //i := 50
                 break;
                end;

               if AnsiCompareStr(s1, '"VSKIN1:"') = 0 then
                begin
                Has_Vskin := True;
                modelflag := False;
                mqoPRIflag := False;
                mqoTSKINflag := False;
                mqoVSKIN1flag := True;
                mqoVSKIN2flag := False;
                mqoVSKIN3flag := False;
                vskin1_flag:=True;
                  //i := 50
                 break;
                end;

               if AnsiCompareStr(s1, '"VSKIN2:"') = 0 then
                begin
                Has_Vskin := True;
                modelflag := False;
                mqoPRIflag := False;
                mqoTSKINflag := False;
                mqoVSKIN1flag := False;
                mqoVSKIN2flag := True;
                mqoVSKIN3flag := False;
                vskin2_flag := True;
                  //i := 50
                 break;
                end;

               if AnsiCompareStr(s1, '"VSKIN3:"') = 0 then
                begin
                Has_Vskin := True;
                modelflag := False;
                mqoPRIflag := False;
                mqoTSKINflag := False;
                mqoVSKIN1flag := False;
                mqoVSKIN2flag := False;
                mqoVSKIN3flag := True;
                vskin3_flag := True;
                          //i := 50
                 break;
                end;

               if (AnsiCompareStr(s1, 'vertex') = 0) AND (modelflag = True) then
                begin
    //              WriteLn(Output, ' doing standard vertices ');
    //              ReadLn(input);
                 i := 31;
                 j := -1;
                 break;
                end;

                 if (AnsiCompareStr(s1, 'vertex') = 0) AND (modelflag = False) then
                begin
     //           WriteLn(Output, ' doing other vertices ');
    //              ReadLn(input);
                 i := 33;
                 j := -1;
                 break;
                end;

               if (AnsiCompareStr(s1, 'face') = 0) AND (modelflag = True) then
               begin
               i := 32;
              // j := 0;
               break;
               end;

                if (AnsiCompareStr(s1, 'face') = 0) AND (modelflag = False) then
               begin
               animfacecount := 0;
               i := 34;
             //  j := 0;
               break;
               end;

               
               if AnsiCompareStr(s1, 'vertexattr') = 0 then
               begin
    //           WriteLn(Output, ' found vertex weights ');
               weightflag := True;
               i := 41;
               break;
               end;

             break;
             end;//of stupid for loop
            end; //of case 3



           22:
             begin
               for q := 0 to 1 do begin
                numofmat := StrToInt(s1);
                if (numofmat > 256) then begin
                isanimflag := True;
                i := 23;
                break
                end;
                if (numofmat < 257) then begin
                isanimflag := False;
                i := 24;
                break;
                end;

               break;
              end;//of stupid for loop
             end; //of case 22


             23: // '\002'                        material test
              begin
              for q := 0 to 1 do begin
                if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 0;
                        break;
                    end;
                if (AnsiStartsStr('col(', s1)) and (matcount > 255) then
                    begin
      //              WriteLn(Output,'found mat:',matcount);
     //               ReadLn(Input);
                        SetLength(MQOmat,Length(MQOmat)+1);
                        s2 := SubString(s1,4);
                 //       WriteLn(Output, ' test1 ',s2);
                        MQOmat[mat_i][0] :=  StrToFloat(s2);
                   //     WriteLn(Output, ' test2 ');
                        j := 1;
                       break;
                    end;
                    if (AnsiStartsStr('col(', s1)) and (matcount < 256) then
                    begin
             //       WriteLn(Output,'matcount ',matcount);
                    Inc(matcount);
                    break;
                    end;

                if(j = 1) OR (j = 2) then
                    begin
                        SetLength(MQOmat,Length(MQOmat)+1);
                        MQOmat[mat_i][j] := StrToFloat(s1);
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
      //          WriteLn(Output,'matcount ',matcount);
              //  ReadLn(Input);

                 break;
                end; // of stupid for loop
               end; //of case23


             24: // '\002'                        material test
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
               end; //of case24




            31: // '\037'          vertices
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

// the + k is to handle more than 1 object since vertex numbers reset for each object.


           32: // ' '            model faces
            begin
              for q := 0 to 1 do begin
        //      WriteLn(output, 'case32');
                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 3;
                        break;
                    end;

                    if (AnsiCompareStr(s1, '2') = 0) AND (j=0) then
                    begin
           //             WriteLn(output, 'found lines');
                       ignoreflag := true;
                       lineflag := True;
                       nomatflag := True;
                        break;
                    end;

                   if (AnsiCompareStr(s1, '4') = 0) AND (j=0) then
                    begin
    //                    WriteLn(output, 'found quads');
                        quadflag := True;
                        break;
                    end;

                    if AnsiStartsStr('V', s1) AND (ignoreflag = False) then
                    begin
                       SetLength(MQOface,Length(MQOface)+1);
                       s2 := (SubString(s1,2));
                 //      WriteLn(Output, 's2 =',s2, ' +', face_i);
                       MQOface[face_i][0] := StrToInt(SubString(s1,2)) + k;
                        MQOface[face_i][5] := obj_i;
                        j := 1;
                        break;
                    end;

                    if AnsiStartsStr('V', s1) AND (ignoreflag = True) then
                    begin
                      j := 0;
                      ignoreflag := False;
                    end;

                    if(j = 1) then
                    begin
                        MQOface[face_i][1] := StrToInt(s1) + k;
                        j := 2;
                        break;
                    end;
                    if(j = 2) then
                      begin
                        //WriteLn(Output, 'press enter'); ReadLn(Input, FileName);
                        if AnsiEndsStr(')', s1) then //should handle lines but don't!
                        begin
                            //WriteLn(Output,'substring = ',SubString2(s1 ,Length(s1), 1));
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

                    //needs test for lines so line mat isn't written??????

                    if (AnsiStartsStr('M', s1)) AND (nomatflag = False) then
                    begin
                        s2 := StringReplace(s1, 'M(', '', [rfReplaceAll, rfIgnoreCase]);
                        s1 := StringReplace(s2, ')', '', [rfReplaceAll, rfIgnoreCase]);
                        If (isanimflag = False) then MQOface[face_i - 1][4] := StrToInt(s1);
                        If (isanimflag = True) then MQOface[face_i - 1][4] := (StrToInt(s1)-256);
                    end;

                   if (AnsiStartsStr('M', s1)) AND (nomatflag = True) then
                    begin
                      nomatflag := False;
                    end;


                break;
                end; //of stupid for loop
               end; //of case 32


          33: // '\037'          vertices
             begin
               for q := 0 to 1 do begin
          //     WriteLn(output, 'case31');
                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 3;
                        break;
                    end;

                //basically ignore vertex data

              break;
              end;//of stupid for loop
             end; //of case 33


         34: // ' '        PRI and TSKIN    faces
            begin
              for q := 0 to 1 do begin
        //      WriteLn(output, 'case32');
                If (mqoVSKIN1flag = True) OR
                (mqoVSKIN2flag = True) OR
                (mqoVSKIN3flag = True) then begin
                j := 0;
                ignoreflag := True;
                notestflag := True;
                end;


                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 3;
                        break;
                    end;

                    if (AnsiCompareStr(s1, '2') = 0) AND (j=0) AND (ignoreflag = False) then
                    begin
   //                     WriteLn(output, 'found lines');


                       ignoreflag := true;
                       lineflag := True;
                       nomatflag := True;
                        break;
                    end;

                 //  if (AnsiCompareStr(s1, '4') = 0) AND (j=0) then
                 //   begin
                 //     WriteLn(output, 'found quads');
                 //      if (notestflag = False) then  quadflag := True;
                 //      break;
                 //   end;

                    if AnsiStartsStr('V', s1) AND (ignoreflag = False) then
                    begin
 //                      SetLength(MQOface,Length(MQOface)+1);
                       s2 := (SubString(s1,2));
                 //      WriteLn(Output, 's2 =',s2, ' +', face_i);
 //                      MQOface[face_i][0] := StrToInt(SubString(s1,2)) + k;
 //                       MQOface[face_i][5] := obj_i;
                        j := 1;
                        break;
                    end;

                    if AnsiStartsStr('V', s1) AND (ignoreflag = True) then
                    begin
                      j := 0;
                      ignoreflag := False;
                    end;

                    if(j = 1) then
                    begin
 //                       MQOface[face_i][1] := StrToInt(s1) + k;
                        j := 2;
                        break;
                    end;
                    if(j = 2) then
                      begin
                        //WriteLn(Output, 'press enter'); ReadLn(Input, FileName);
                        if AnsiEndsStr(')', s1) then 
                        begin
                            //WriteLn(Output,'substring = ',SubString2(s1 ,Length(s1), 1));
 //                           MQOface[face_i][2] :=  StrToInt(SubString2(s1 ,Length(s1), 1)) + k;
 //                           MQOface[face_i][3] := MQOface[face_i][2];
                            inc(animfacecount);
                            j := 0;
                        end else
                        begin
//                           MQOface[face_i][2] := StrToInt(s1) + k;
                            j := 3;
                        end;
                       break;
                      end;
                    if(j = 3) then
                    begin
//                        MQOface[face_i][3] := StrToInt( SubString2(s1 ,Length(s1), 1)) + k;
                        inc(animfacecount);
                        j := 0;
                        break;
                    end;
                    if (AnsiStartsStr('M', s1)) AND (nomatflag = False) then
                    begin
                    if animfacecount > face_i then MessageBox(0, PChar('count error'), PChar('Error'), MB_OK);

                        s2 := StringReplace(s1, 'M(', '', [rfReplaceAll, rfIgnoreCase]);
                        s1 := StringReplace(s2, ')', '', [rfReplaceAll, rfIgnoreCase]);

                        If (mqoPRIflag = True) then mqoPRI[animfacecount-1] := StrToInt(s1);
                        If (mqoTSKINflag = True) then mqoTSKIN[animfacecount-1] := StrToInt(s1);
                    end;

                   if (AnsiStartsStr('M', s1)) AND (nomatflag = True) then
                    begin
                      nomatflag := False;
                    end;

                break;
                end; //of stupid for loop
               end; //of case 34



            41: // ' '            weights
            begin
              for q := 0 to 1 do begin
        //      WriteLn(output, 'case32');
                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
                        i := 3;
                        break;
                    end;


                     if AnsiCompareStr(s1, 'weit') = 0 then
                    begin
                    vskin1flag := true; //remove this from here ???
                    //SetLength(vweight,ver_i);
                    if mqoVSKIN1flag = True then SetLength(mqoweit1,ver_i);
                    if mqoVSKIN2flag = True then SetLength(mqoweit2,ver_i);
                    if mqoVSKIN3flag = True then SetLength(mqoweit3,ver_i);

                    //set all weights to 0
                    
                    for e := 0 to ver_i -1 do
                      begin
                      // vweight[e]:=0;
                       if mqoVSKIN1flag = True then mqoweit1[e]:=0;
                       if mqoVSKIN2flag = True then mqoweit2[e]:=0;
                       if mqoVSKIN3flag = True then mqoweit3[e]:=0;
                      end;
                        i := 42;
                        break;
                    end;


                    if AnsiCompareStr(s1, '{') = 0 then
                    begin
                        //i := 3;
                        break;
                    end;

                  break;
                end; //of stupid for loop
               end; //of case 41

          42: // ' '            weight sub group
            begin
              for q := 0 to 1 do begin
        //      WriteLn(output, 'case32');
                    if AnsiCompareStr(s1, '}') = 0 then
                    begin
          //           ReadLn(Input);
                        i := 41;
                        break;
                    end;


                    if AnsiCompareStr(s1, '{') = 0 then
                    begin
                        i := 42;
                        break;
                    end;

                   if (vskin1flag = True) then     //???????????????
                   begin
                    //get the vertex number from the data.
                    vwnum :=  StrToInt(s1);

             //       WriteLn(output, 'vwnum',vwnum);
                    i := 43;
                  //   ReadLn(Input);
                    break;
                   end;
                  i := 43;
                  break;
                end; //of stupid for loop
               end; //of case 42


        43: // ' '            weight sub group
            begin
              for q := 0 to 1 do begin
        //      WriteLn(output, 'case32');

                if (vskin1flag = True) then
                   begin
                   vweightnum := Round(StrToFloat(s1)*100);
                   if(vweightnum < 0) then vweightnum := 0;
                   if(vweightnum > 100) then vweightnum := 100;
            //       if (vwnum > -1) then vweight[vwnum] := vweightnum;
                   if (vwnum > -1) and (mqoVSKIN1flag = True) then mqoweit1[vwnum] := vweightnum;
                   if (vwnum > -1) and (mqoVSKIN2flag = True) then mqoweit2[vwnum] := vweightnum;
                   if (vwnum > -1) and (mqoVSKIN3flag = True) then mqoweit3[vwnum] := vweightnum;
                   vwnum := -1;
                   //test for <0 >100
              //     WriteLn(output, 'vweight=',vweightnum);
                    //get the weight number from the data.
                    i := 42;
                    break;
                   end;
                   i := 42;
                   break;
                end; //of stupid for loop
               end; //of case 42


          end; //end of case statement
 //   ReadLn(Input);
        end;//end of while
  except
  IsValid := false;
  SetToZero;
  end;

  if not IsValid then begin
    MessageBox(0, 'MQO Could not load file.', 'Error', 0);
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

   AddVskins;
   LoadArrays;
   
   If (isanimflag = False) then Model_version := 3;
   If (isanimflag = True) then Model_version := 4;
   //need to add vertex weight arrays together
   CalcNormals;
   errorcode := '';
   If (quadflag = True) then errorcode := errorcode + 'Contains Quads - ';
   If (lineflag = True) then errorcode := errorcode + 'Contains Lines';
   If (quadflag = True) OR (lineflag = True) then
   MessageBox(0, PChar(errorcode), PChar('Might want to remodel that'), MB_OK);
    end;
 end;

end.
