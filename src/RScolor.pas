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

unit RScolor;
// list of all objects available to the client program. public usable stuff
interface

uses
  Windows, SysUtils, OpenGl1x, FileRSM, StrUtils;

//function LoadFile(FileName: String): Boolean;
//procedure Close;
function GetColor (r, g, b: Double): Integer;

implementation


function Max (a, b : double): double;
  begin
    if a > b then
      Result := a
    else
      Result := b
  end;

function Min (a, b : double): double;
  begin
    if a < b then
      Result := a
    else
      Result := b
  end;

Function GetColor (r, g, b: Double): Integer;

var
 vmin, vmax, delta: Double;
 dr,dg,db: Double;
 h,s,l,h2,s2,l2 : Double;
 h_i, s_i, l_i, value: Integer;

begin

  vmin := Min (r, Min (g, b));
  vmax := Max (r, Max (g, b));
  delta := vmax - vmin;

  l := ( vmax + vmin ) / 2;

  if ( delta = 0 ) then
  begin
     h := 0;
     s := 0;
  end else
  begin
    if ( l < 0.5 ) then s := delta / ( vmax + vmin )
    else  s := delta / ( 2 - vmax - vmin );
     dr := ( ( ( vmax - r ) / 6 ) + ( delta / 2 ) ) / delta;
     dg := ( ( ( vmax - g ) / 6 ) + ( delta / 2 ) ) / delta;
     db := ( ( ( vmax - b ) / 6 ) + ( delta / 2 ) ) / delta;
     if      ( r = vmax ) then h := db - dg
     else if ( g = vmax ) then h := ( 1 / 3 ) + dr - db
     else if ( b = vmax ) then h := ( 2 / 3 ) + dg - dr;
     if ( h < 0 ) then h := h+1;
     if ( h > 1 ) then h := h-1;
     end;

//    l2 := l*(127);
//    s2 := ((s-(1/16)) * 7);
//    h2 := ((h-(1/128))*63);

    l2 := l*(127);
    s2 := (s * 7);
    h2 := (h*63);
    if l2 < 0.0 then l2 := 0.0;
    if s2 < 0.0 then s2 := 0.0;
    if h2 < 0.0 then h2 := 0.0;

    l_i := Trunc(l2);
    s_i := Trunc(s2);
    h_i := Trunc(h2);
    Value := l_i + (s_i*128) + (h_i*1024);
    If Value > 65535 then Value := 65535;
    If Value < 0 then Value := 0;

  Result := Value;
  end;

end.
