(*
MakeDat by MrPotatoHead
*)

unit MakeDat;
// list of all objects available to the client program. public usable stuff
interface

uses
  Windows, SysUtils, OpenGl1x, FileRSM, OpenMQO;


procedure SaveRSM(FileName: String);

var
  Addit:Integer;
  Fout: File;
//  V, F: array of TVector3i;
//  C, M, A: array of Integer;
//  N: array of TVector3f;
  FileNamek: string;
  Fout2: TextFile;
//  GNumVertices, GNumTriangles, GNumTexTriangles, GTextured, Gi1,
 // GTransparent, Gk1, Gl1, GXsSize, GYsSize, GZsSize, GTriangleDataLength: Integer;
//end of list of objects available to client
  Fskinval,Vskin,TP,PriTestCount : Integer;
  Animate, TriPri, SplitFlag,TransFlag,type6,PriTestFlag : Boolean;

implementation


function MakeDatFile(FileName: String): Boolean;
begin
  Result := true;
  AssignFile(Fout, FileName);
{$I-}
  ReWrite(Fout, 1);
{$I+}
  if IOResult <> 0 then begin
    Result := false;
    MessageBox(0, PChar(IntToStr(IOResult)), 'I/O Error', 0);
    end;
//  offset := 0;
end;



procedure Close;
begin
  CloseFile(Fout);
//  Writeln(Fout2, 'End of file');
//  CloseFile(Fout2);
end;



Procedure WriteWordInt(a: Integer);
Var
b,c,d : Integer;
 begin
  If a > 255 then
    begin
    b := (a and $00ff);
    c := a and $ff00;
    d := c shr 8;
    //   WriteLn(Output, b);
    //   WriteLn(Output, c);
    //   WriteLn(Output, d);
    BlockWrite(Fout, d, 1);
    BlockWrite(Fout, b, 1);
    end
  else
    begin
      b := 0;
      BlockWrite(Fout, b, 1);
      BlockWrite(Fout, a, 1);

    end;
 end;

 Procedure WriteInt(a: Integer);
 Var
 b,c,d : Integer;
 begin
  If a > 255 then
    begin
    b := (a and $00ff);
    c := a and $ff00;
    d := c shr 8;
    //   WriteLn(Output, b);
    //   WriteLn(Output, c);
    //   WriteLn(Output, d);
    BlockWrite(Fout, d, 1);
    BlockWrite(Fout, b, 1);
    Addit := 1;
    end
  else
    begin
      BlockWrite(Fout, a, 1);
    end;
 end;

 Procedure WriteSmInt(a: Integer);
 begin
      BlockWrite(Fout, a, 1);
 end;

 Procedure WriteBigInt(a: Integer);
 Var
 b,c,d : Integer;
 begin
    b := (a and $00ff);
    c := a and $ff00;
    d := c shr 8;
    //   WriteLn(Output, b);
    //   WriteLn(Output, c);
    //   WriteLn(Output, d);
    BlockWrite(Fout, d, 1);
    BlockWrite(Fout, b, 1);
 end;



 Procedure MakeHex(n1: Integer);
 Var
 a,b: Integer;
 begin
  if (n1 > -64) and (n1 < 63) then
    begin
      a := n1 + 64;
//      b := a and $7f;
      WriteSmInt(a);
      Addit := 0;
    end
  else
    begin
    a:= n1 + 49152;
//    b:= a or $8000;
  WriteBigInt(a);
  Addit := 1;
  end;
end;

 Procedure SmByte(a: Integer);
 Var
  b: Integer;
 begin
     b := (a and $00ff);
      BlockWrite(Fout, b, 1);
 end;

Procedure InsertPRI;
var
i9: Integer;
begin
For i9 := 0 to GNumTriangles-1 do
 begin
    SmByte(TP);
 end;
end;

Procedure InsertPRI2;
var
i9: Integer;
begin
PriTestFlag := False;
PriTestCount := mqoPRI[0];
For i9 := 1 to GNumTriangles-1 do
 begin
    TP := mqoPRI[i9];
    If (PriTestCount <> TP ) then PriTestFlag := True;
   // SmByte(TP);
 end;

If PriTestFlag = True then begin
  For i9 := 0 to GNumTriangles-1 do
   begin
    TP := mqoPRI[i9];
    SmByte(TP);
   end;
  end; 
end;


Procedure AlphaTest;
var
i9: Integer;
begin
TransFlag := False;
  For i9 := 0 to GNumTriangles-1 do
   begin
     If A[i9] > 0 then TransFlag := True;
   end;
  If TransFlag = True then begin
     For i9 := 0 to GNumTriangles-1 do
      begin
       SmByte(A[i9]);
      end;
   end;
end;

Procedure AnimateF;
var
i9: Integer;
begin
If SplitFlag = False then
 begin
 For i9 := 0 to GNumTriangles-1 do
  begin
    SmByte(Fskinval);
  end;
 end;
If SplitFlag = True then
 begin
 For i9 := 0 to GNumTriangles-1 do
  begin
   If V[F[i9][0]][0] < 0 then SmByte(Fskinval)
   else SmByte(Fskinval+1)
  end;
 end;

end;

Procedure AnimateF2;
var
i9: Integer;
begin
 For i9 := 0 to GNumTriangles-1 do
  begin
  Fskinval := mqoTSKIN[i9];
    SmByte(Fskinval);
  end;

end;



Procedure AnimateV;
var
i9: Integer;
begin
// test for which side of axis
If SplitFlag = False then
 begin
 For i9 := 0 to GNumVertices-1 do
  begin
    SmByte(Vskin);
  end;
 end;
If SplitFlag = True then
 begin
 For i9 := 0 to GNumVertices-1 do
  begin
   If V[i9][0] < 0 then SmByte(Vskin)
   else SmByte(Vskin+1);
  end;
 end;

end;


Procedure AnimateV2;
var
i9: Integer;
begin

 For i9 := 0 to GNumVertices-1 do
  begin
   Vskin := vweight[i9];
    SmByte(Vskin);
  end;

end;



//this is the psrt of the unit that is public to the client program.
//this is what makes it work

procedure SaveRSM(FileName: String);
var
FileName2,FileNameOut,A1,B1 : String;
name,temp1,num1,Xtemp,Ytemp,Ztemp : string;
  tempA, tempB, tempC, Mattemp : string;
  n1,n2,LnHex,NameLen,i1, NumMaterials,NumVert : Integer;
  NumTri,i,K1,s1,X1,Y1,Z1 : Integer;
  tA,tB,tC,Mt,EndSpace,getX,getY,getZ: Integer;
  XdatCount, YdatCount, ZdatCount : Integer;
  LastX, LastY, LastZ, LoadFlag: Integer;
  DataLength,OldFaceType,k,tv1,tv2,tv3 : Integer;
  OldV1,OldV2,OldV3 : Integer;
  V1,V2,V3,VertCount,OldFlag,NewFlag : Integer;
  OldVert1,NewVert3,TriType : Integer;
  OldVertex,a,PlusX,PlusY,PlusZ,PlusDat : Integer;
  BitArray,Va : array[0..2] of Integer;
  IsValid : Boolean;
  Fin : TextFile;
//  Fout : File;
  letter : char;
  VertX, VertY, VertZ ,Tri1, Tri2, Tri3: array of Integer;
  MatNum, MatList: array of Integer;
  LoadFlags,Xdat,Ydat,Zdat: array of Integer;
  TriData,FaceType,TriDataB: array of Integer;

begin
//  AssignFile(Fout2, 'debug.txt');
//  Rewrite(Fout2);
  {* Begin Validation*}
  FileName2 := FileName;
  NameLen :=  Length(FileName2);
  SetLength(FileName2,NameLen - 4);
  FileNameOut := FileName2 + 'b.dat';
//  FileNameOut := 'bentski.dat';
//  WriteLn(Output, FileNameOut);
//  AssignFile(Fout, FileNameOut);
//  ReWrite(Fout,1);


//  MakeDatFile(FileNameOut);
  if not (MakeDatFile(FileNameOut)) then begin
    MessageBox(0, 'Unable to make dat.', 'Error0', 0);
    Exit;
  end;
  IsValid := True;
//  ReSet(Fout, 1);
  try


//           *****************************************
//           ** Generate vertex data and load flags **
//           *****************************************

NumTri := GNumTriangles;
NumVert := GNumVertices;
TransFlag := False;

XdatCount :=0; YdatCount:=0; ZdatCount:=0;
LastX:=0; LastY:=0; LastZ:=0;

SetLength(Xdat, 0); SetLength(Xdat, NumVert);
SetLength(Ydat, 0); SetLength(Ydat, NumVert);
SetLength(Zdat, 0); SetLength(Zdat, NumVert);
SetLength(LoadFlags, 0); SetLength(LoadFlags, NumVert);

For i := 0 to NumVert -1 do
  begin
    LoadFlag :=0;
    getX := V[i][0];
    getY := V[i][1];
    getZ := V[i][2];

  If LastX <> getX then
    begin
      Xdat[XdatCount]:= getX - LastX;
      XdatCount := XdatCount + 1;
      LoadFlag := LoadFlag + 1;
      LastX := getX;
    end;
   If LastY <> getY then
    begin
      Ydat[YdatCount]:= -getY + LastY;
      YdatCount := YdatCount + 1;
      LoadFlag := LoadFlag + 2;
      LastY := getY;
    end;
   If LastZ <> getZ then
    begin
      Zdat[ZdatCount]:= -getZ + LastZ;
      ZdatCount := ZdatCount + 1;
      LoadFlag := LoadFlag + 4;
      LastZ := getZ;
    end;
    LoadFlags[i] := LoadFlag;
//    Write(Output, LoadFlag, ' ');
  end;
//    Writeln(Output);
//    Writeln(Output, 'Xdatcount = ',XdatCount, ' ');
//    Writeln(Output, 'Ydatcount = ',YdatCount, ' ');
//    Writeln(Output, 'Zdatcount = ',ZdatCount, ' ');
//    Writeln(Output);
    
//           *****************************************
//           **  Generate Face Data and face types  **
//           *****************************************


// vertices are working correctly


// WriteLn(Output, 'debug pos 1');
//    ReadLn(Input, FileName);

SetLength(FaceType, 0); SetLength(FaceType, NumTri);
SetLength(TriData, 0); SetLength(TriData, (NumTri*3));
//TriData is set to length NumTri*3 - worst case scenario of ALL seperate triangles

BitArray[0] := 1; BitArray[1] := 2; BitArray[2] := 4;
OldV1 := 0; OldV2 := 0; OldV3 := 0;
DataLength :=0;
OldFaceType :=0;

For k := 0 to NumTri -1 do
  begin
   type6 := False;
    V1 :=F[k][0];
    V2 :=F[k][1];
    V3 :=F[k][2];
    Va[0] := V1; Va[1] := V2; Va[2] := V3;
    VertCount := 0; OldFlag := 0; NewFlag := 0;

//count the number of identical vertices
// in BOTH current AND last triangles..........



// NEED test for single seperate triangles.....
// single triangles are fucking up the output





    For i := 0 to 2 do
      begin
        if OldV1=Va[i] then
          begin
            VertCount:=VertCount+1;
            OldFlag := OldFlag +1;
            NewFlag:=NewFlag + BitArray[i];
          end;
        end;
    For i := 0 to 2 do
      begin
        if OldV2=Va[i] then
          begin
            VertCount:=VertCount+1;
            OldFlag := OldFlag +2;
            NewFlag:=NewFlag + BitArray[i];
          end;
        end;
    For i := 0 to 2 do
      begin
        if OldV3=Va[i] then
          begin
            VertCount:=VertCount+1;
            OldFlag := OldFlag +4;
            NewFlag:=NewFlag + BitArray[i];
          end;
        end;



// TEST for case 2
  If VertCount <>2 then
    begin
      FaceType[k] := 1;
//      Write(Output, 'facetype=1 ');
    for i := 0 to 2 do
      begin
        TriData[DataLength] := Va[i];
        DataLength := DataLength + 1;
//        Write(Output,Va[i], ' ');
      end;
//      Writeln(Output);
      OldFaceType := 1;
      OldV1 := Va[0];
      OldV2 := Va[1];
      OldV3 := Va[2];
    end; //end of IF

// TEST for caes 2 and 3
  If VertCount = 2 then
    begin

    //sort first triangle if was case 1

      If OldFaceType = 1 then
        begin
          //OldVert1 := not(OldFlag and 7);
          OldVert1 := 7 - OldFlag;
//          Write(Output, ' OldFlag = ',OldFlag);
//          Write(Output, ' OldVert1 = ',OldVert1);
          If OldVert1 = 2 then
            begin
              tv1 := TriData[DataLength -2];
              tv2 := TriData[DataLength -1];
              tv3 := TriData[DataLength -3];
              TriData[DataLength -3]:= tv1; OldV1 := tv1;
              TriData[DataLength -2]:= tv2; OldV2 := tv2;
              TriData[DataLength -1]:= tv3; OldV3 := tv3;
            end;

          If OldVert1 = 4 then
            begin
              tv1 := TriData[DataLength -1];
              tv2 := TriData[DataLength -3];
              tv3 := TriData[DataLength -2];
              TriData[DataLength -3]:= tv1; OldV1 := tv1;
              TriData[DataLength -2]:= tv2; OldV2 := tv2;
              TriData[DataLength -1]:= tv3; OldV3 := tv3;
            end;
      end; //end of IF

          //sort second triangle

      //NewVert3 := not (NewFlag and 7);
      NewVert3 := 7 - NewFlag;
//      Write(Output, ' NewFlag = ',NewFlag);
//      Write(Output, ' NewVert3 = ',NewVert3);
      If NewVert3 = 1 then
        begin
          tv1 := Va[1];
          tv2 := Va[2];
          tv3 := Va[0];
          Va[0] := tv1;
          Va[1] := tv2;
          Va[2] := tv3;
        end;
      If NewVert3 = 2 then
        begin
          tv1 := Va[2];
          tv2 := Va[0];
          tv3 := Va[1];
          Va[0] := tv1;
          Va[1] := tv2;
          Va[2] := tv3;
        end;


//  test for tritype here.......

      TriType := 6;                           //set to 6 for better debug
      If OldV1 = Va[0] then TriType := 2;
      If OldV2 = Va[1] then TriType := 3;

//below removes the need for type 4 triangles
// which allows a 2 bit storage of type data     
If TriType = 6 then type6 := True;

If type6 = False then
  begin
      FaceType[k] := TriType;
      OldFaceType := TriType;
      TriData[DataLength] := Va[2];
 //     Write(Output,' tritype=',TriType,' ');
 //     Write(Output,Va[2]);
      DataLength := DataLength + 1;
//      Writeln(Output,' vertices ',Va[0],' ',Va[1],' ',Va[2]);
      OldV1 := Va[0]; OldV2 := Va[1]; OldV3 := Va[2];
   end else
    begin
      FaceType[k] := 1;
//      Write(Output, 'facetype=1 ');
    for i := 0 to 2 do
      begin
        TriData[DataLength] := Va[i];
        DataLength := DataLength + 1;
//        Write(Output,Va[i], ' ');
      end;
//      Writeln(Output);
      OldFaceType := 1;
      OldV1 := Va[0];
      OldV2 := Va[1];
      OldV3 := Va[2];
    end;



    end; //end of IF vert count = 2  = cases 2 and 3


  end;  //end of k counter

//  Writeln(Output,' Number of  Triangles =  ',NumTri);
//  Writeln(Output,' DataLength =  ',DataLength);

// this sets the array for triangle data

  SetLength(TriDataB, 0); SetLength(TriDataB, DataLength);
  OldVertex := 0;
  For i := 0 to DataLength -1 do
    begin
      TriDataB[i] := TriData[i] - OldVertex;
      OldVertex := TriData[i];
 //      Writeln(Output,' Difference = ',TriDataB[i]);
     end;



    
//           *****************************************
//           *******   Then output everything   ******
//           *****************************************

//first store load flags
//then triangletype  = FaceType[]
// then triangle data = TriDataB[]
// colour data
// xlist
// ylist
// zlist
//generate footer info




//    Writeln(Output,'LoadFlags = ');
  for i := 0 to NumVert -1 do
    begin
      n1 := LoadFlags[i];
// {$I-}
  WriteInt(n1);
//{$I+}

// write facetypes
//   Write(Output,n1,' ');
    end;

    for i := 0 to NumTri -1 do
    begin
      n1 := FaceType[i];
   // {$I-}
     WriteInt(n1);
   //{$I+}
    end;

If (Model_version = 3) AND (TriPri = True) then InsertPRI;   //what??
If (Model_version = 4) AND (Has_Pri = True) then InsertPRI2;
//triangle and vertex skins go here
If (Model_version = 3) AND (Animate = True) then AnimateF;
If (Model_version = 4) AND (Has_Tskin = True) then AnimateF2;

//Textured test must be done here

If (Model_version = 3) AND (Animate = True) then AnimateV;
If (Model_version = 4) AND (Has_Vskin = True) then AnimateV2;
//Then alpha

AlphaTest;

    PlusDat := 0;
 for i := 0 to DataLength -1 do
    begin
      n1 := TriDataB[i];
   MakeHex(n1);
   PlusDat := PlusDat + Addit;
    end;

 //color data
   for i := 0 to NumTri -1 do
    begin
      n1 := C[i];
   // {$I-}
     WriteWordInt(n1);
   //{$I+}
    end;

   PlusX := 0;
   for i := 0 to XdatCount-1 do
     begin
       n1 := Xdat[i];
       MakeHex(n1);
       PlusX := PlusX + Addit;
   end;

   PlusY := 0;
   for i := 0 to YdatCount-1 do
     begin
       n1 := Ydat[i];
       MakeHex(n1);
       PlusY := PlusY + Addit;
   end;

   PlusZ := 0;
    for i := 0 to ZdatCount-1 do
     begin
       n1 := Zdat[i];
       MakeHex(n1);
       PlusZ := PlusZ + Addit;
   end;

// write footer info

WriteWordInt(NumVert);
WriteWordInt(NumTri);
i := 0;
BlockWrite(Fout, i, 1);
BlockWrite(Fout, i, 1);

If TriPri = True then i := 255;   //for model version 3
If TriPri = False then i := UserPri;
If Has_Pri = True then i := 255;  //for model version 4
If (Has_Pri = True) AND (PriTestFlag = False) then i := PriTestCount;
If (Model_version = 4) AND (Has_Pri = False) then i := UserPri;
BlockWrite(Fout, i, 1);
i:= 0;

If TransFlag = True then i := 1;
BlockWrite(Fout, i, 1);
i := 0;

//do need to set flags independantly????????

If Animate = True then i := 1;
If isanimflag = True then i := 1;

If (Model_version = 4) AND (Has_Tskin = False) Then i := 0;
BlockWrite(Fout, i, 1);   //tskinflag

If isanimflag = True then i := 1;
If (Model_version = 4) AND (Has_Vskin = False) Then i := 0;
BlockWrite(Fout, i, 1);   //vskinflag
i := 0;

i := XdatCount + PlusX;
WriteWordInt(i);
i := YdatCount + PlusY;
WriteWordInt(i);
i := ZdatCount + PlusZ;
WriteWordInt(i);

i := DataLength  +PlusDat;
WriteWordInt(i);

//Writeln(Output,' XdatCount =  ',XdatCount);
//Writeln(Output,' YdatCount =  ',YdatCount);
//Writeln(Output,' ZdatCount =  ',ZdatCount);
//Writeln(Output,' dataoffset =  ',i);

//  Target := Copy(Source, 3, 4);
//  FileName2 := FileName;
//  NameLen :=  Length(FileName2);
//  SetLength(FileName2,NameLen - 4);
//  FileNameOut := FileName2 + '.dat';
//  WriteLn(Output, FileNameOut);
//  AssignFile(Fout, FileNameOut);
//  ReWrite(Fout);

//for i := 1 to 10 do
 // begin
//    MakeHex(i);
//    WriteLn('i= ',i,' n2= ',n2,' LnHex= ',LnHex);
//  end;

//   Write(Fout, IntToHex(n1, LnHex));
//   WriteLn(Fout, 'test');
  // And we do not even have to refer to these file names
//  WriteLn('n1/A1 = ',n1,' ',A1);
//  WriteLn('');
//  WriteLn('Press enter to exit');
  close;
 // Close(Fin);
//  ReadLn(Input, FileName);


  except
    IsValid := false;
  end;

  if not IsValid then begin
    MessageBox(0, 'Unable to Export! - see debug.txt.', 'Error', 0);
    Exit;
  end;
 //  Close;
   FileNamek := FileName;

end;


end.

