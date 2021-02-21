(*
Metsequoia file exporter
*)

unit MQOout;
// list of all objects available to the client program. public usable stuff
interface

uses
  Windows, SysUtils, OpenGl1x, FileRSM;

type
  TRSStream = object

    offset: Integer;
//function SaveFile(FileName: String): Boolean;

  end;

Procedure MakeCMAP2;  
Procedure MQOoutput;
procedure SaveMQO;
procedure WriteHeader;
procedure WriteObj;
Procedure MQOopen(FileName: String);

CONST   // best to use mnemonics whenever possible
     CR  = #$0D;
     TB = #$09;
     ZF = '.0000';

var
  mqoFout: TextFile;
  NumColors,NumTriangles,NumVertices: Integer;
  MNumTriangles, MNumVertices : Integer;
  Vk2, Fk2: array of TVector3i;
  C2, C3, M2, A2: array of Integer;
  cmap2: array of TVector3f;
//end of list of objects available to client

implementation

Procedure MakeCMAP2;
Var
 i: Byte;
  f: Cardinal;
  index, y, x: Integer;
  color, saturation, cx, r, g, b, sat, sat2, rc, gc, bc: Single;
begin
  // Color Map Generation
  SetLength(cmap2, 512 * 128);
  index := 0;
  for y := 0 to 511 do begin
    color := y / 8 / 64 + 0.0078125;
    saturation := (y and 7) / 8 + 0.0625;
    for x := 0 to 127 do begin
      cx := x / 128;
      r := cx;
      g := cx;
      b := cx;
      if saturation <> 0.0 then begin
        if cx < 0.5 then
          sat := cx * (1 + saturation)
        else
          sat := (cx + saturation) - cx * saturation;
        sat2 := 2 * cx - sat;
        rc := color + 0.3;
        if rc > 1 then
          rc := rc - 1;
        gc := color;
        bc := color - 0.3;
        if bc < 0 then
          bc := bc + 1;
        if 6 * rc < 1 then
          r := sat2 + (sat - sat2) * 6 * rc
        else if 2 * rc < 1 then
          r := sat
        else if 3 * rc < 2 then
          r := sat2 + (sat - sat2) * (0.7 - rc) * 6
        else
          r := sat2;
        if 6 * gc < 1 then
          g := sat2 + (sat - sat2) * 6 * gc
        else if 2 * gc < 1 then
          g := sat
        else if 3 * gc < 2 then
          g := sat2 + (sat - sat2) * (0.7 - gc) * 6
        else
          g := sat2;
        if 6 * bc < 1 then
          b := sat2 + (sat - sat2) * 6 * bc
        else if 2 * bc < 1 then
          b := sat
        else if 3 * bc < 2 then
          b := sat2 + (sat - sat2) * (0.7 - bc) * 6
        else
          b := sat2;
      end;
      cmap2[index][0] := r;
      cmap2[index][1] := g;
      cmap2[index][2] := b;
      Inc(index);
    end;
  end;
end;

Procedure MQOoutput;
var
 i,NumColors,s,t,ExistsFlag,tempcol: Integer;
 temptest: TVector3i;
 A2,MatIndex: array of Integer;
begin

SetLength(C2, 0); SetLength(C2, GNumTriangles);
SetLength(A2, 0); SetLength(A2, GNumTriangles);
SetLength(MatIndex, 0); SetLength(MatIndex, 65536);
MQOopen(FileNamek);

//find number of colours
C2[0] := C[0];
A2[0] := A[0];
MatIndex[C[0]] := 0;
NumColors := 1;
for t := 1 to GNumTriangles -1  do
  begin
    ExistsFlag := 0;
    For s := 0 to NumColors -1 do
      begin
        if C[t] = C2[s] then ExistsFlag := 1;
      end;
    If ExistsFlag = 0 then
      begin
         C2[NumColors] := C[t];
         A2[NumColors] := A[t];
         MatIndex[C[t]] := NumColors;
         NumColors := NumColors + 1;
      end;
  end;

//glColor4f(cmap[C[i]][0], cmap[C[i]][1], cmap[C[i]][2], (255 - A[i]) / 255);

MNumTriangles := GNumTriangles;
MNumVertices := GNumVertices;


//WriteLn(Fout, 'Number of triangles = ', GNumTriangles);
//WriteLn(Fout, 'Number of colours = ', NumColors);

WriteHeader;

//write material list
writeLn(mqoFout, ' Material ', NumColors + 1 ,' {');
For t := 0 to NumColors -1 do
begin
write(mqoFout, TB+'"mat', C2[t], '" shader(3) col(');
write(mqoFout, cmap2[C2[t]][0]:5:3, ' ', cmap2[C2[t]][1]:5:3, ' ', cmap2[C2[t]][2]:5:3, ' ');
write(mqoFout, (255 - A2[t]) / 255:5:3);
write(mqoFout, ') dif(0.800) amb(0.000) emi(0.750) spc(0.000) power(5.00)');
writeln(mqoFout);
end;
writeln(mqoFout, '}');


WriteObj;
WriteLn(mqoFout, TB+'vertex ', MNumVertices, ' {');
//write object

for i := 0 to High(V) do
begin
WriteLn(mqoFout, TB+TB+' ', V[i][0],ZF, ' ',  V[i][1],ZF, ' ',  V[i][2],ZF );
end;
WriteLn(mqoFout,TB+'}');
WriteLn(mqoFout,TB+'face ', High(F)+1, ' {');

for i := 0 to High(F) do
begin
writeln(mqoFout, TB+TB+'3 V(', F[i][2], ' ', F[i][1], ' ', F[i][0], ') M(', MatIndex[C[i]],')');
end;
WriteLn(mqoFout,TB+'}');
WriteLn(mqoFout,'}');
SaveMQO;
end;


Procedure MQOopen(FileName: String);
var
  FileNameOut,FileName2: string;
  NameLen: Integer;
begin
  FileName2 := FileName;
  NameLen :=  Length(FileName2);
  SetLength(FileName2,NameLen - 4);
  FileNameOut := FileName2 + '.mqo';
  AssignFile(mqoFout, FileNameOut);
  Rewrite( mqoFout );

//writeheader
//writedata
//write EOF and closefile

end;

Procedure MakeObjs;
var
  cabbages,i : Integer;
begin

  for i := 0 to High(Fk2) do begin
//       glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
//       glEnable(GL_LIGHTING);
//       glBegin(GL_TRIANGLES);
//       glColor4f(cmap[C[i]][0], cmap[C[i]][1], cmap[C[i]][2], (255 - A[i]) / 255);
//        glNormal3fv(@N[F[i][0]]);
//        glVertex3f(V[F[i][0]][0], V[F[i][0]][1], V[F2[i][0]][2]);
write(mqoFout, '1', Vk2[Fk2[i][0]][0], Vk2[Fk2[i][0]][1], Vk2[Fk2[i][0]][2] );
write(mqoFout, '2', Vk2[Fk2[i][1]][0], Vk2[Fk2[i][1]][1], Vk2[Fk2[i][1]][2] );
write(mqoFout, '3', Vk2[Fk2[i][2]][0], Vk2[Fk2[i][2]][1], Vk2[Fk2[i][2]][2] );

//        glNormal3fv(@N[F[i][1]]);
//        glVertex3f(V[F[i][1]][0], V[F[i][1]][1], V[F[i][1]][2]);
//       glNormal3fv(@N[F[i][2]]);
//        glVertex3f(V[F[i][2]][0], V[F[i][2]][1], V[F[i][2]][2]);
//        glEnd;
      end;
Write(mqoFout, 'test', ' ', MNumTriangles, ' ', MNumVertices);
end;

Procedure MakeMatList;
var
ExistsFlag, t, s: Integer;

begin

C3[0] := C2[0];
NumColors := 1;
for t := 1 to NumTriangles do
  begin
    ExistsFlag := 0;
    For s := 0 to NumColors do
      begin
        if C2[t] = C3[s] then ExistsFlag := 1;
      end;
    If ExistsFlag = 0 then
      begin
        C3[NumColors] := C2[t];
        Inc(NumColors);
      end;
  end;
end;

procedure WriteHeader;
begin
WriteLn(mqoFout, 'Metasequoia Document');
WriteLn(mqoFout, 'Format Text Ver 1.0');
WriteLn(mqoFout);
WriteLn(mqoFout, 'Scene {');
WriteLn(mqoFout, '	pos 0.0000 0.0000 1500.0000');
WriteLn(mqoFout, '	lookat 0.0000 0.0000 0.0000');
WriteLn(mqoFout, '	head 0.2164');
WriteLn(mqoFout, '	pich 0.8036');
WriteLn(mqoFout, '	ortho 0');
WriteLn(mqoFout, '	zoom2 1.9531');
WriteLn(mqoFout, '	amb 0.500 0.500 0.500');
WriteLn(mqoFout, '}');

//materials
//objects
//EOF
end;

procedure WriteObj;
begin
WriteLn(mqoFout, 'Object "obj1" { ');
WriteLn(mqoFout, '	depth 0');
WriteLn(mqoFout, '	folding 0');
WriteLn(mqoFout, '	scale 1.000000 1.000000 1.000000');
WriteLn(mqoFout, '	rotation 0.000000 0.000000 0.000000');
WriteLn(mqoFout, '	translation 0.000000 0.000000 0.000000');
WriteLn(mqoFout, '	visible 15');
WriteLn(mqoFout, '	locking 0');
WriteLn(mqoFout, '	shading 1');
WriteLn(mqoFout, '	facet 120');
WriteLn(mqoFout, '	color 0.000 0.000 0.000');
WriteLn(mqoFout, '	color_type 0 ');
end;

// M[] = texture
// A[] = alpha



Procedure SaveMQO;
begin
//writeheader
WriteLn(mqoFout,'Eof');

CloseFile(mqoFout);

//writedata
//write EOF and closefile

end;

end.











