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

unit FileRSMwithskins;
// list of all objects available to the client program. public usable stuff
interface

uses
  Windows, SysUtils, OpenGl1x;

type
  TRSStream = object
    F: File;
    offset: Integer;
    function LoadFile(FileName: String): Boolean;
    procedure Close;
    function ReadByte: Integer;
    function ReadUnsigned: Integer; overload;
    function ReadUnsigned(len: Integer): Integer; overload;
    procedure SetOffset(off: Integer);
  end;


procedure LoadRSM(FileName: String);

var
  V, F, Tex : array of TVector3i;
  C, M, A, Skin, Fskin: array of Integer;
  N: array of TVector3f;
  FileNamek: string;
  Fout2: TextFile;
  GNumVertices, GNumTriangles, GNumTexTriangles, GTextured, Gi1,
  GTransparent, Gk1, Gl1, GXsSize, GYsSize, GZsSize, GTriangleDataLength: Integer;
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

function TRSStream.LoadFile(FileName: String): Boolean;
begin
  Result := true;
  AssignFile(F, FileName);
{$I-}
  Reset(F, 1);
{$I+}
  if IOResult <> 0 then
    Result := false;
  offset := 0;
end;

function TRSStream.ReadByte: Integer;
var b: array of Byte;
begin
  Result := -1;
  Inc(offset);
  SetLength(b, 1);
{$I-}
  BlockRead(F, b[0], 1);
{$I+}
  if IOResult <> 0 then
    Exit;
  Result := b[0] and $ff;
//  writeln(Fout2, 'rboffset= ', offset);
end;

function TRSStream.ReadUnsigned: Integer;
var i: Integer;
begin
  i := ReadByte;
  SetOffset(offset - 1);
  if i < 128 then Result := ReadByte - 64
  else            Result := ReadUnsigned(2) - 49152;
//  Writeln(Fout2, 'ruoffset= ', offset);
end;

function TRSStream.ReadUnsigned(len: Integer): Integer;
begin
  Result := 0;
  if len =  4 then Result := Result + ReadByte Shl 24;
  if len >= 3 then Result := Result + ReadByte Shl 16;
  if len >= 2 then Result := Result + ReadByte Shl 8;
  Result := Result + ReadByte;
//  Writeln(Fout2, 'ru(2)offset = ', offset);
end;

procedure TRSStream.SetOffset(off: Integer);
begin
  if off < 0 then Exit;
  offset := off;
  Seek(F, off);
end;

procedure TRSStream.Close;
begin
  CloseFile(F);

end;








//this is the psrt of the unit that is public to the client program.
//this is what makes it work

procedure LoadRSM(FileName: String);
var
  NumVertices, NumTriangles, NumTexTriangles, Textured, i1,
  Transparent, k1, l1, XsSize, YsSize, ZsSize, TriangleDataLength: Integer;

  HeaderStream, stream0, stream1, stream2, stream3, stream4: TRSStream;

  i, CurrX, CurrY, CurrZ, LastX, LastY, LastZ, VertexDirection,
  V1, V2, V3, oV, TriangleType: Integer;

  DirOffset, XsOffset, YsOffset, ZsOffset, TexCoordsOffset, SomeOffset2, ColorOffset,
  FaceTypeOffset, SomeOffset5, AlphaOffset, SomeOffset7, TriangleDataOffset,
  TriangleTypeOffset, Offset: Integer;
  IsValid: Boolean;
begin
 GTextured := 0;
 GNumVertices := 0;
 GNumTriangles := 0;
 GNumTexTriangles := 0;
 Gi1 := 0;
 GTransparent := 0;
 Gk1 := 0;
 Gl1 := 0;
 GXsSize := 0;
 GYsSize := 0;
 GZsSize := 0;
 GTriangleDataLength := 0;

//  AssignFile(Fout2, 'debug.txt');
 // Rewrite(Fout2);
  {* Begin Validation*}
   HeaderStream.LoadFile(filename);
  if not HeaderStream.LoadFile(filename) then begin
    MessageBox(0, 'Unable to load file.', 'Error', 0);
    Exit;
  end;
  try
    IsValid := true;
    HeaderStream.SetOffset(FileSize(HeaderStream.F) - 18);

    HeaderStream.ReadUnsigned(2);
    HeaderStream.ReadUnsigned(2);
    HeaderStream.ReadByte;

    if(HeaderStream.ReadByte > 1) or
      (HeaderStream.ReadByte = 256) or
      (HeaderStream.ReadByte > 1) or
      (HeaderStream.ReadByte > 1) then
       IsValid := false;
  except
    IsValid := false;
  end;
  if not IsValid then begin
    MessageBox(0, 'Invalid file format.', 'Error', 0);
    Exit;
  end;
  {* End Validation*}

  {* Begin Header *}
  HeaderStream.LoadFile(filename);
  HeaderStream.SetOffset(FileSize(HeaderStream.F) - 18);
//  Writeln(Fout2, 'headeroffset= ', FileSize(HeaderStream.F) - 18);
  NumVertices := HeaderStream.ReadUnsigned(2);
  GNumVertices := NumVertices;
  NumTriangles := HeaderStream.ReadUnsigned(2);
  GNumTriangles := NumTriangles;
  NumTexTriangles := HeaderStream.ReadByte;
  GNumTexTriangles := NumTexTriangles;
  Textured := HeaderStream.ReadByte;
  GTextured := Textured;
  i1 := HeaderStream.ReadByte;
  Gi1 :=  i1;
  Transparent := HeaderStream.ReadByte;
  GTransparent := Transparent;
  k1 := HeaderStream.ReadByte;
  Gk1 := k1;
  l1 := HeaderStream.ReadByte;
  Gl1 := Gl1;
  XsSize := HeaderStream.ReadUnsigned(2);
  GXsSize := XsSize;
  YsSize := HeaderStream.ReadUnsigned(2);
  GYsSize := YsSize;
  ZsSize := HeaderStream.ReadUnsigned(2);
  GZsSize := ZsSize;
  TriangleDataLength := HeaderStream.ReadUnsigned(2);
  GTriangleDataLength := TriangleDataLength;
  Offset := 0;
  DirOffset := Offset;


  //  Writeln(Fout2, 'DirOffset= ', DirOffset);
  Offset := Offset + NumVertices;
  TriangleTypeOffset := Offset;
//  Writeln(Fout2, 'TriangleTypeOffset= ', TriangleTypeOffset);
  Offset := Offset + NumTriangles;
  SomeOffset5 := Offset;
//  Writeln(Fout2, 'SomeOffset5= ', SomeOffset5);

//  Writeln(Fout2, 'i1= ', i1);
  if i1 = 255 then
    Offset := Offset + NumTriangles
  else
    SomeOffset5 := -i1 - 1;
  SomeOffset7 := Offset;
//  Writeln(Fout2, 'SomeOffset7= ', SomeOffset7);
 // Writeln(Fout2, 'SomeOffset5= ', SomeOffset5);
  if k1 = 1 then
    Offset := Offset + NumTriangles
  else
    SomeOffset7 := -1;
  FaceTypeOffset := Offset;
//  Writeln(Fout2, 'FaceTypeOffset= ', FaceTypeOffset);
  if Textured = 1 then
    Offset := Offset + NumTriangles
  else
    FaceTypeOffset := -1;
  SomeOffset2 := Offset;
//  Writeln(Fout2, 'FaceTypeOffset= ', FaceTypeOffset);
//  Writeln(Fout2, 'SomeOffset2= ', SomeOffset2);
  if l1 = 1 then
    Offset := Offset + NumVertices
  else
    SomeOffset2 := -1;
  AlphaOffset := Offset;
//  Writeln(Fout2, 'AlphaOffset= ', AlphaOffset);
 // Writeln(Fout2, 'SomeOffset2= ', SomeOffset2);
  if Transparent = 1 then
    Offset := Offset + NumTriangles
  else
    AlphaOffset := -1;
 // Writeln(Fout2, 'AlphaOffset= ', AlphaOffset);
  TriangleDataOffset := Offset;
 // Writeln(Fout2, 'TriangleDataOffset= ', TriangleDataOffset);
  Offset := Offset + TriangleDataLength;
  ColorOffset := Offset;
//  Writeln(Fout2, 'ColorOffset= ', ColorOffset);
  Offset := Offset + NumTriangles * 2;
  TexCoordsOffset := Offset;
//  Writeln(Fout2, 'TexCoordsOffset= ', TexCoordsOffset);
  Offset := Offset + NumTexTriangles * 6;
  XsOffset := Offset;
//  Writeln(Fout2, 'XsOffset= ', XsOffset);
  Offset := Offset + XsSize;
  YsOffset := Offset;
 // Writeln(Fout2, 'YsOffset= ', YsOffset);
  Offset := Offset + YsSize;
  ZsOffset := Offset;
 // Writeln(Fout2, 'ZsOffset= ', ZsOffset);
  {* End Header *}

  SetLength(V, 0); SetLength(V, NumVertices);
  SetLength(F, 0); SetLength(F, NumTriangles);
   SetLength(Skin, 0);
IF SomeOffset2 > 0 then  SetLength(Skin, NumVertices);
  stream0.LoadFile(filename); stream0.SetOffset(DirOffset);
  stream1.LoadFile(filename); stream1.SetOffset(XsOffset);
  stream2.LoadFile(filename); stream2.SetOffset(YsOffset);
  stream3.LoadFile(filename); stream3.SetOffset(ZsOffset);
  stream4.LoadFile(filename); stream4.SetOffset(SomeOffset2);
  LastX := 0; LastY := 0; LastZ := 0;
//  Writeln(Fout2, '***vertex direction data***');
  for i := 0 to NumVertices - 1 do
  begin
//    Write(Fout2, 'dir= ');
    VertexDirection := stream0.ReadByte;
  IF SomeOffset2 > 0 then  Skin[i] := stream4.ReadByte;
    CurrX := 0; CurrY := 0; CurrZ := 0;
    if VertexDirection and 1 <> 0 then  CurrX := stream1.ReadUnsigned;
    if VertexDirection and 2 <> 0 then  CurrY := stream2.ReadUnsigned;
    if VertexDirection and 4 <> 0 then  CurrZ := stream3.ReadUnsigned;
    V[i][0] := LastX + CurrX;
    V[i][1] := LastY - CurrY;
    V[i][2] := LastZ - CurrZ;
    LastX := V[i][0];
    LastY := V[i][1];
    LastZ := V[i][2];
 //   Write(Fout2, 'X=',LastX);
 //   Write(Fout2, ' Y=',LastY);
 //   Writeln(Fout2, ' Z=',LastZ);
  end;
  stream0.SetOffset(ColorOffset);
  stream1.SetOffset(FaceTypeOffset);
  //stream2.SetOffset(SomeOffset5);
  stream3.SetOffset(AlphaOffset);
  stream4.SetOffset(SomeOffset7);
   SetLength(Fskin, 0);
IF SomeOffset7 > 0 then  SetLength(Fskin, NumTriangles);
  SetLength(A, 0); SetLength(A, NumTriangles);
  SetLength(C, 0); SetLength(C, NumTriangles);
  SetLength(M, 0); SetLength(M, NumTriangles);
  for i := 0 to NumTriangles - 1 do begin
    C[i] := stream0.readUnsigned(2);
      IF SomeOffset7 > 0 then  Fskin[i] := stream4.ReadByte;
    if FaceTypeOffset > -1 then
       begin
      M[i] := stream1.readByte;
      GTextured := 1;
      end;
    if Transparent = 1 then
      A[i] := stream3.readByte;
  end;
  stream0.SetOffset(TriangleDataOffset);
  stream1.SetOffset(TriangleTypeOffset);
  V1 := 0;
  V2 := 0;
  V3 := 0;
  oV := 0;
//  Writeln(Fout2, '***Triangle data***');
  for i := 0 to NumTriangles - 1 do
  begin
    TriangleType := stream1.ReadByte;
    if TriangleType = 1 then
    begin
      V1 := stream0.ReadUnsigned + oV;
      oV := V1;
      V2 := stream0.ReadUnsigned + oV;
      oV := V2;
      V3 := stream0.ReadUnsigned + oV;
      oV := V3;
      F[i][0] := V1;
      F[i][1] := V2;
      F[i][2] := V3;
    end;
    if TriangleType = 2 then
    begin
      V2 := V3;
      V3 := stream0.ReadUnsigned + oV;
      oV := V3;
      F[i][0] := V1;
      F[i][1] := V2;
      F[i][2] := V3;
    end;
    if TriangleType = 3 then
    begin
      V1 := V3;
      V3 := stream0.ReadUnsigned + oV;
      oV := V3;
      F[i][0] := V1;
      F[i][1] := V2;
      F[i][2] := V3;
    end;
    if TriangleType = 4 then
    begin
      V3 := stream0.ReadUnsigned + oV;
      oV := V1;
      V1 := V2;
      V2 := oV;
      oV := V3;
      F[i][0] := V1;
      F[i][1] := V2;
      F[i][2] := V3;
    end;
  end;

 if GTextured = 1 then
 begin
  SetLength(Tex, 0);SetLength(Tex, NumTexTriangles);
  stream0.SetOffset(TexCoordsOffset);
  for i := 0 to NumTexTriangles -1 do
    begin
     Tex[i][0] := Stream0.ReadUnsigned(2);
     Tex[i][1] := Stream0.ReadUnsigned(2);
     Tex[i][2] := Stream0.ReadUnsigned(2);
    end;
  end;

  CalcNormals;
   FileNamek := FileName;
 //     Writeln(Fout2, 'End of file');
 // CloseFile(Fout2);
end;

end.
