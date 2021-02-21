//----------------------------------------------------------------------------
//
// Author      : mrpotatohead
// Date        : 8 july 2008
// Description : A unit that calculates trig functions for UV coords
//
//----------------------------------------------------------------------------
unit trig;

interface

uses
  Windows, OpenGL, FileRSM, OpenGl1x, Math;

type
 Tex3Vx2UV = array[0..2] of TVector2d;

function SinRule(lenb,angA,angB : Double) : Double;
function len3D(x1,y1,z1,x2,y2,z2 : Integer) : Double;
function CosRule(len1,len2,len3 : Double) : Double;
procedure DoStuff;

var
  UV: array of Tex3Vx2UV;

implementation

//get texturetriangles from Tex[]
//create new array for modeltriangle - to store texture flags?
//                                   - store UV tripets?
//get texturedata from M[]
// for i = 0 to High(M)
// if M[i} > 1 then begin
// texure used = ((M[i}+2)/4)-1
// calculate U length and V length from Tex[texture used]
// ********could do above line all in one go?
// a,b,c = UV(0,0) U point, Vpoint
//
// for each vertex in model triangle


// procedure to calculate all of the UV coordinates in the model file
// Call after loading the model and before displaying
procedure DoStuff;
var
ti,i,k,testflag,s0,su,sv : Integer;
lenau,lenaq,lenuq,lenus,lenav,lenvq,lentv : Double;
Angle_U,Angle_V,U_number,V_number,Angle_A,Angle_B : Double;
Error_Angle : Double;
begin

SetLength(UV, 0); SetLength(UV, GNumTriangles);
//for i = 1 to High(F) do begin
//if m[i] >= 2 then
//begin
//  TriMapUsed = ((M[i}+2)/4)-1
//get lengths of trimap lines U and V
// for each point in model tri get lengths,
// do pre-test to ensure lengths don't match or length = 0
// get angles using cos and sin rules,
// Calculate U and V coords from length comparisons
// put in UV corrections??????  needed at start!!!!!

// for each triangle in model
for i := 0 to high(F) do
begin
 testflag := 0;
//for each point in model triangle.
for k := 0 to 2 do
begin

if M[i] >1 then
begin    //E1
//get U_number
//the texture triangle num should be calculated from m[]
ti := ( (M[i] + 2) div 4) -1;
lenau := len3D(V[Tex[ti][0]][0], V[Tex[ti][0]][1], V[Tex[ti][0]][2], V[Tex[ti][2]][0], V[Tex[ti][2]][1], V[Tex[ti][2]][2]) ;
lenaq := len3D(V[Tex[ti][0]][0], V[Tex[ti][0]][1], V[Tex[ti][0]][2], V[F[i][k]][0], V[F[i][k]][1], V[F[i][k]][2]) ;
lenuq := len3D(V[Tex[ti][2]][0], V[Tex[ti][2]][1], V[Tex[ti][2]][2], V[F[i][k]][0], V[F[i][k]][1], V[F[i][k]][2]) ;
lenav := len3D(V[Tex[ti][0]][0], V[Tex[ti][0]][1], V[Tex[ti][0]][2], V[Tex[ti][1]][0], V[Tex[ti][1]][1], V[Tex[ti][1]][2]) ;
lenvq := len3D(V[Tex[ti][1]][0], V[Tex[ti][1]][1], V[Tex[ti][1]][2], V[F[i][k]][0], V[F[i][k]][1], V[F[i][k]][2]) ;

//get angle A and B  for error correction.
Angle_A := CosRule(lenaq,lenau,lenuq) ;
Angle_B := CosRule(lenav,lenaq,lenvq) ;
Error_angle := (Angle_A + Angle_B) - 90;

//do pretests
//if lengths same then could be 0 or 1
//somewhere we need to test for a triangle, maybe after calculations?

if (lenau = lenaq ) AND (lenuq = 0) then U_number := 1.0
else if (lenaq = 0) OR (lenau-lenaq = 0 ) then U_number := 0.0
 else
 begin
 Angle_U := CosRule(lenau,lenuq,lenaq) ;
 lenus := SinRule(lenuq,(90-Angle_U - Error_Angle),90) ;
If lenau <> 0 then U_number := (lenau - lenus) * (1 / lenau);
 end;

//get V_number
//do pretests
if (lenav =lenaq) AND (lenvq = 0)  then V_number := 1.0
else if (lenaq = 0) OR (lenav-lenaq = 0) then V_number := 0.0
else
 begin
 Angle_V := CosRule(lenvq,lenav,lenaq);
 lentv := SinRule(lenvq, (90 - Angle_V - Error_Angle), 90);
If lenav <> 0 then  V_number := (lenav - lentv) * (1 / lenav);
 end;



 UV[i][k][0] := V_number;
 UV[i][k][1] := 1-U_number;

end else       //end E1
begin
//for when no texture is used
UV[i][k][0] := 0;
UV[i][k][1] := 0;
end ;

end;  //end of k loop


//now test for single triangle
if M[i] >1 then
begin
testflag := 0;  s0 := 0; su := 0; sv := 0;
 for k := 0 to 2 do
  begin
  If (V[Tex[ti][0]][0] = V[F[i][k]][0])
  AND (V[Tex[ti][0]][1] = V[F[i][k]][1])
  AND (V[Tex[ti][0]][2] = V[F[i][k]][2])
 then begin testflag := testflag + 1; s0 := k; end;
  If (V[Tex[ti][1]][0] = V[F[i][k]][0])
  AND (V[Tex[ti][1]][1] = V[F[i][k]][1])
  AND (V[Tex[ti][1]][2] = V[F[i][k]][2])
 then begin testflag := testflag + 1; su := k; end;
  If (V[Tex[ti][2]][0] = V[F[i][k]][0])
  AND (V[Tex[ti][2]][1] = V[F[i][k]][1])
  AND (V[Tex[ti][2]][2] = V[F[i][k]][2])
 then begin testflag := testflag + 1; sv := k; end;
 end; //end of k loop

 If testflag = 3 then
 begin
   UV[i][s0][0] := 0;
   UV[i][s0][1] := 0;
   UV[i][su][0] := 1;
   UV[i][su][1] := 0;
   UV[i][sv][0] := 0;
   UV[i][sv][1] := 1;
  end;   //end of if

 end; //end of upper if m[] >1
end; //end of i loop

end;  //end of procedure


function len3D(x1,y1,z1,x2,y2,z2 : Integer) : Double;
begin
Result := Sqrt( ((x1-x2)*(x1-x2))+ ((y1-y2)*(y1-y2))+ ((z1-z2)*(z1-z2)) );
end;


function CosRule(len1,len2,len3 : Double) : Double;
var
temp1, radtemp : Double;
// len1 = a, len2 = b, len3 = c
begin
temp1 := ((len1*len1)+(len2*len2)-(len3*len3))/(2*len1*len2);
radtemp := ArcCos(temp1);
Result := RadToDeg(ArcCos(temp1));
//Result := ArcCos(temp1);
end;

function SinRule(lenb,angA,angB: Double) : Double;
var
temp1, radtemp : Double;
begin
// a / Sin(A) = b / Sin(B)
// therefore a = (b * Sin(A))/ Sin(B)
Result := (lenb * Sin(DegToRad(angA)) ) / (Sin(DegToRad(angB)));
end;

end.
