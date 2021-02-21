//----------------------------------------------------------------------------
//
// Author      : mrpotatohead
// Date        : 23 july 2008
// Description : A unit that generate false coloring of animation skins
//
//----------------------------------------------------------------------------
unit tricenters;

interface

uses
  Windows, OpenGL, FileRSM, OpenGl1x, Math;


procedure GetCenters;

var
   TriMids : array of TVector3i;

implementation


procedure GetCenters;
var
i : Integer;
tx,ty,tz : Double;
begin
  SetLength(TriMids, 0); SetLength(TriMids, GNumTriangles);

 for i := 0 to GNumTriangles-1 do
  begin
     tx := (V[F[i][0]][0] + V[F[i][1]][0] + V[F[i][2]][0])/3;
     ty := (V[F[i][0]][1] + V[F[i][1]][1] + V[F[i][2]][1])/3;
     tz := (V[F[i][0]][2] + V[F[i][1]][2] + V[F[i][2]][2])/3;
     TriMids[i][0] := Round(tx);
     TriMids[i][1] := Round(ty);
     TriMids[i][2] := Round(tz);
   end;
end;

end.
