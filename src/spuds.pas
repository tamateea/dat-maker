//----------------------------------------------------------------------------
//
// Author      : mrpotatohead
// Date        : 8 july 2008
// Description : A unit that generate false coloring of animation skins
//
//----------------------------------------------------------------------------
unit spuds;

interface

uses
  Windows, OpenGl1x ;


procedure Makecmap3;

var
  CMap3 : array[0..255] of TVector3f;

implementation

procedure Makecmap3;
var
i,k : Integer;
begin
k := 0;
for i := 0 to 7 do
  begin
   CMap3[0+k+i][0] := 1.0; CMap3[0+k+i][1] := 1.0; CMap3[0+k + i][2] := 0;
   CMap3[1+k+i][0] := 0;   CMap3[1+k+i][1] := 1.0; CMap3[1 + k + i][2] := 0;
   CMap3[2+k+i][0] := 0;   CMap3[2+k+i][1] := 0.5; CMap3[2 + k + i][2] := 1;
   CMap3[3+k+i][0] := 0;   CMap3[3+k+i][1] := 0;   CMap3[3 + k + i][2] := 1;
   CMap3[4+k+i][0] := 0.5; CMap3[4+k+i][1] := 0;   CMap3[4 + k + i][2] := 1;
   CMap3[5+k+i][0] := 1; CMap3[5+k+i][1] := 0;   CMap3[5 + k + i][2] := 1;
   CMap3[6+k+i][0] := 1; CMap3[6+k+i][1] := 0;   CMap3[6 + k + i][2] := 0;
   CMap3[7+k+i][0] := 1; CMap3[7+k+i][1] := 0.5; CMap3[7 + k + i][2] := 0;

   CMap3[8+k+i][0] := 1; CMap3[8+k+i][1] := 1; CMap3[8+k + i][2] := 0.25;
   CMap3[9+k+i][0] := 0.25;   CMap3[9+k+i][1] := 1; CMap3[9 + k + i][2] := 0.25;
   CMap3[10+k+i][0] := 0.25;   CMap3[10+k+i][1] := 0.5; CMap3[10 + k + i][2] := 1;
   CMap3[11+k+i][0] := 0.25;   CMap3[11+k+i][1] := 0.25;   CMap3[11 + k + i][2] := 1;
   CMap3[12+k+i][0] := 0.5; CMap3[12+k+i][1] := 0.25;   CMap3[12 + k + i][2] := 1;
   CMap3[13+k+i][0] := 1; CMap3[13+k+i][1] := 0.25;   CMap3[13 + k + i][2] := 1;
   CMap3[14+k+i][0] := 1; CMap3[14+k+i][1] := 0.25;   CMap3[14 + k + i][2] := 0.25;
   CMap3[15+k+i][0] := 1; CMap3[15+k+i][1] := 0.5; CMap3[15 + k + i][2] := 0.25;

   CMap3[16+k+i][0] := 1; CMap3[16+k+i][1] := 1; CMap3[16 +k + i][2] := 0;
   CMap3[17+k+i][0] := 0;   CMap3[17+k+i][1] := 1; CMap3[17 + k + i][2] := 0;
   CMap3[18+k+i][0] := 0;   CMap3[18+k+i][1] := 0.5; CMap3[18 + k + i][2] := 1;
   CMap3[19+k+i][0] := 0;   CMap3[19+k+i][1] := 0;   CMap3[19 + k + i][2] := 1;
   CMap3[20+k+i][0] := 0.5; CMap3[20+k+i][1] := 0;   CMap3[20 + k + i][2] := 1;
   CMap3[21+k+i][0] := 1; CMap3[21+k+i][1] := 0;   CMap3[21 + k + i][2] := 1;
   CMap3[22+k+i][0] := 1; CMap3[22+k+i][1] := 0;   CMap3[22 + k + i][2] := 0;
   CMap3[23+k+i][0] := 1; CMap3[23+k+i][1] := 0.5; CMap3[23 + k + i][2] := 0;

   CMap3[24+k+i][0] := 0.75; CMap3[24+k+i][1] := 0.75; CMap3[24 +k + i][2] := 0;
   CMap3[25+k+i][0] := 0;   CMap3[25+k+i][1] := 0.75; CMap3[25 + k + i][2] := 0;
   CMap3[26+k+i][0] := 0;   CMap3[26+k+i][1] := 0.5; CMap3[26 + k + i][2] := 0.75;
   CMap3[27+k+i][0] := 0;   CMap3[27+k+i][1] := 0;   CMap3[27 + k + i][2] := 0.75;
   CMap3[28+k+i][0] := 0.5; CMap3[28+k+i][1] := 0;   CMap3[28 + k + i][2] := 0.75;
   CMap3[29+k+i][0] := 0.75; CMap3[29+k+i][1] := 0;   CMap3[29 + k + i][2] := 0.75;
   CMap3[30+k+i][0] := 0.75; CMap3[30+k+i][1] := 0;   CMap3[30 + k + i][2] := 0;
   CMap3[31+k+i][0] := 0.75; CMap3[31+k+i][1] := 0.5; CMap3[31 + k + i][2] := 0;




   k := k + 31;
  end; //end of i loop

end;  //end of procedure


end.
