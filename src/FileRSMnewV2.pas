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

unit FileRSMnewV2;
// list of all objects available to the client program. public usable stuff
interface

uses
  Windows, SysUtils, OpenGl1x, FileRSM;

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


procedure LoadRSMnew(FileName: String);

var
cabbage : Integer;
//end of list of objects available to client

{*
  the main fileRSM file must contain arrays to load all model data
  more than one model must be catered for
  original data must be loaded to enable conversion.
*}

implementation


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


//******need header test here******


procedure LoadRSMnew(FileName: String);
var
t : Integer;
HeaderStream,stream,stream_11,stream_12,stream_13,stream_14,stream_15,stream_16 : TRSStream;
IsValid : Boolean;

begin
   HeaderStream.LoadFile(FileName);
  if not HeaderStream.LoadFile(FileName) then begin
    MessageBox(0, 'Unable to load file.', 'Error', 0);
    Exit;
  end;
  try
    IsValid := true;
        HeaderStream.SetOffset(FileSize(HeaderStream.F) - 23);
        
  	inumvert := HeaderStream.ReadUnsigned(2); // word  num_vert
	inumtri := HeaderStream.ReadUnsigned(2);  // word  num_tri
	i_18 := HeaderStream.ReadByte;            // byte  header_length_num_textures
	i_19 := HeaderStream.ReadByte;            // byte  ??? numtrilen
	i_20 := HeaderStream.ReadByte;            // byte  tri_priority
	i_21 := HeaderStream.ReadByte;            // byte  alpha
	i_22 := HeaderStream.ReadByte;            // byte  tri skins
	i_23 := HeaderStream.ReadByte;            // byte  ??? numtrilen*2  relates to unknown
	i_24 := HeaderStream.ReadByte;            // byte  vertex skins
	i_25 := HeaderStream.ReadUnsigned(2);     // word  x_data_len
	i_26 := HeaderStream.ReadUnsigned(2);     // word  y_data_len
	i_27 := HeaderStream.ReadUnsigned(2);     // word  z_data_len
	i_28 := HeaderStream.ReadUnsigned(2);     // word  tri_data_len
	i_29 := HeaderStream.ReadUnsigned(2);     // word  unknown

    if(inumvert < 1) or
      (inumtri < 1) or
      (HeaderStream.ReadByte <> 255) or
      (HeaderStream.ReadByte <> 255) then
       IsValid := false;
  except
    IsValid := false;
  end;
  if not IsValid then begin
    MessageBox(0, 'Invalid file format.', 'Error', 0);
    Exit;
  end;
  {* End Validation*}


   i_30 := 0;
   i_31 := 0;
   i_32 := 0;

// if i_18 > 0 then read header block
if i_18 > 0 then begin SetLength(tex_header, 0); SetLength(tex_header, i_18); end;

		if (i_18 > 0) then
                begin
		  stream.offset := 0;
		  for t := 0 to i_18 -1 do
                     begin
		      tex_header[t] := stream.ReadByte;
                      if (tex_header[t] = 0) then inc(i_30);
		      if (tex_header[t] >= 1) AND (tex_header[t] <= 3) then inc(i_31);
		      if (tex_header[t] = 2) then inc(i_32);
		     end;//of for
		end;


		tempval := i_18;
		i_36 := tempval;                  //i36=vertex_direction_offset
		tempval := tempval + inumvert;
		i_37 := tempval;                  //i37 = tri_type
		if (i_19 = 1) then tempval := tempval + inumtri;

		i_38 := tempval;                  //i38 = (numtrilen) ??????
		tempval := tempval + inumtri;
		i_39 := tempval;                  //i39= tri_pri_data
		if (i_20 = 255) then tempval := tempval + inumtri;

		i_40 := tempval;                  //i40=(numtrilen) tri skins
		if (i_22 = 1) then tempval := tempval + inumtri;

		i_41 := tempval;                  //i41=(numvertlen) vert_skins
		if (i_24 = 1) then tempval := tempval + inumvert;

		i_42 := tempval;                  //i42=(numtrilen)  alpha
		if (i_21 = 1) then tempval := tempval + inumtri;

		i_43 := tempval;                  //i43= triangle_data
		tempval := tempval + i_28;

		i_44 := tempval;                  //i44=(numtrilen*2)   ?????
		if (i_23 = 1) then tempval := tempval + (inumtri * 2);

		i_45 := tempval;                  //i45=(unknownlen) ?????
     		tempval := tempval + i_29;
		i_46 := tempval;                  //i46=colordata
		tempval := tempval + inumtri * 2;
		i_47 := tempval;                  //i47=xdataoffset
		tempval := tempval + i_25;
		i_48 := tempval;                  //i48=ydataoffset
		tempval := tempval + i_26;
		i_49 := tempval;                  //i49=zdataoffset
		tempval := tempval + i_27;
		i_50 := tempval;                  //i50=oldstyletexturesoffset
		tempval := tempval + (i_30 * 6);
		i_51 := tempval;                  //151=proctextures1
		tempval := tempval + (i_31 * 6);
		i_52 := tempval;                  //152=proctextures2
		tempval := tempval + (i_31 * 6);
		i_53 := tempval;                  //153=procdata1
		tempval := tempval + i_31;
		i_54 := tempval;                  //154=procdata2
		tempval := tempval + i_31;
		i_55 := tempval;                  //155=procdata3
		tempval := tempval + i_31 + (i_32 * 2);            ///not needed
//end of header
//assign arrays
//load each model into small raw data array and then copy contents in FileRSM unit
//or at end of this unit
// load raw data into arrays, then create usable array data.



//  footer,vert_dir,tri_type,dunno1,tri_pri : array of Integer;
//  tri_skin,vert_skin,color_alpha,tri_data : array of Integer;
//  dunno2,color_data,xdata,ydata,zdata : array fo Integer;
//  tex1,tex2,tex3,tex4,tex5,tex6 : array of Integer;
// tri1,tri2,tri3 : Integer;

//begin raw data block load


SetLength(vert_dir, 0); SetLength(vert_dir, inumvert);
SetLength(vert_list, 0); SetLength(vert_list, inumvert);

SetLength(tri_type, 0); SetLength(tri_type, inumtri);
if i_19 = 1 then begin SetLength(dunno1,0); SetLength(dunno1,inumtri); end;
if i_20 = 255 then begin SetLength(tri_pri,0); SetLength(tri_pri,inumtri); end;
if i_22 = 1 then begin SetLength(tri_skin,0); SetLength(tri_skin,inumtri); end;
if i_24 = 1 then begin SetLength(vert_skin,0); SetLength(vert_skin,inumvert); end;
if i_21 = 1 then begin SetLength(alpha,0); SetLength(alpha,inumtri); end;
SetLength(tri_data, 0); SetLength(tri_data, i_28);
SetLength(tri_list, 0); SetLength(tri_list, inumtri);
if i_23 = 1 then begin SetLength(dunno2,0); SetLength(dunno2,inumtri); end;
if i_23 = 1 then begin SetLength(dunno2_raw,0); SetLength(dunno2_raw,inumtri); end;
if (i_23 = 1) AND (i_18 > 0) then begin SetLength(dunno3,0); SetLength(dunno3,i_29); end;
SetLength(tri_color, 0); SetLength(tri_color, inumtri);
SetLength(xdata, 0); SetLength(xdata, i_25);
SetLength(ydata, 0); SetLength(ydata, i_26);
SetLength(zdata, 0); SetLength(zdata, i_27);


//set texture arrays after reading rest of file. then read textures


 		stream.SetOffset(i_36);
		stream_11.SetOffset(i_47);
		stream_12.SetOffset(i_48);
		stream_13.SetOffset(i_49);
		stream_14.SetOffset(i_41);

		i_56 := 0; i_57 := 0; i_58 := 0;
                ic1 := 0; ic2 := 0; ic3 := 0;
                //read vertices and vertex skins from file
                //read into raw data arrays AND useful data arrays
		for t := 0 to inumvert do
                   begin
			i_60 := stream.ReadByte; vert_dir[t] := i_60;

                        i_61 := 0;
			if ((i_60 AND $01) <> 0) then begin
                        i_61 := stream_11.ReadUnsigned;
                        xdata[ic1] := i_61; inc(ic1);
                        end;

			i_62 := 0;
			if ((i_60 AND $02) <> 0) then begin
                        i_62 := stream_12.ReadUnsigned;
                        ydata[ic2] := i_62; inc(ic2);
                        end;

			i_63 := 0;
			if ((i_60 AND $04) <> 0) then begin
                        i_63 := stream_13.ReadUnsigned;
                        zdata[ic3] := i_63; inc(ic3);
                        end;

			vert_list[t][0] := i_56 + i_61;
			vert_list[t][1] := i_57 + i_62;
			vert_list[t][2] := i_58 + i_63;
			i_56 := vert_list[t][0];
			i_57 := vert_list[t][1];
			i_58 := vert_list[t][2];
			if (i_24 = 1) then vert_skin[t] := stream_14.ReadByte;
	          end;



 		stream.SetOffset(i_46);
		stream_11.SetOffset(i_37);
		stream_12.SetOffset(i_39);
		stream_13.SetOffset(i_42);
		stream_14.SetOffset(i_40);
		stream_15.SetOffset(i_44);
		stream_16.SetOffset(i_45);
                dc3:=0;

		for t := 0 to inumtri-1 do
                  begin
			color_data[t] := stream.ReadUnsigned(2);     //color
			if (i_19 = 1) then dunno1[t] := stream_11.ReadByte;  //dunno1

			if (i_20 = 255) then tri_pri[t] := stream_12.ReadByte;  //tri priority

			if (i_21 = 1) then alpha[t] := stream_13.ReadByte; //alpha

			if (i_22 = 1) then tri_skin[t] := stream_14.ReadByte; //triangle skins

			if (i_23 = 1) then begin
                        dunno2[t] := stream_15.ReadUnsigned(2) - 1;
                        dunno2_raw[t] := dunno2[t];
                        end;
 // i_29 must be an over-ride for i_23
   			if (i_23 = 1) AND(i_18 > 0) then
				if (dunno2[t] <> -1) then
                                     begin
					dunno2[t] := (stream_16.ReadByte - 1);
                                        dunno3[dc3] := dunno2[t];
                                        inc(dc3);
                                     end
				        else dunno2[t] := -1;
  
		end;//of for loop


                //read triangle data 

 		stream.SetOffset(i_43);
		stream_11.SetOffset(i_38);
		i_65 := 0; i_66 := 0; i_67 := 0; i_68 := 0;
                tdc :=0; 

		for  t := 0 to num_tri - 1 do
                begin
			i_70 := stream_11.ReadByte;
                        tri_type[t] := i_70;
			if (i_70 = 1) then begin
				i_65 := stream.ReadUnsigned + i_68;
                                tri_data[tdc]:=(i_65 - i_68); inc(tdc);
				i_68 := i_65;
				i_66 := stream.ReadUnsigned + i_68;
                                tri_data[tdc]:=(i_66 - i_68); inc(tdc);
				i_68 := i_66;
				i_67 := stream.ReadUnsigned + i_68;
                                tri_data[tdc]:=(i_67 - i_68); inc(tdc);
				i_68 := i_67;
				tri_list[t][0] := i_65;
				tri_list[t][1] := i_66;
				tri_list[t][2] := i_67;
			end;
			if (i_70 = 2) then begin
				i_66 := i_67;
				i_67 := stream.ReadUnsigned + i_68;
                                tri_data[tdc]:=(i_67 - i_68); inc(tdc);
				i_68 := i_67;
				tri_list[t][0] := i_65;
				tri_list[t][1] := i_66;
				tri_list[t][2] := i_67;
			end;
			if (i_70 = 3) then begin
				i_65 := i_67;
				i_67 := stream.ReadUnsigned + i_68;
                                tri_data[tdc]:=(i_67 - i_68); inc(tdc);
				i_68 := i_67;
				tri_list[t][0] := i_65;
				tri_list[t][1] := i_66;
				tri_list[t][2] := i_67;
			end;
			if (i_70 = 4) then begin
				i_71 := i_65;
				i_65 := i_66;
				i_66 := i_71;
				i_67 := stream.ReadUnsigned + i_68;
                                tri_data[tdc]:=(i_67 - i_68); inc(tdc);
				i_68 := i_67;
				tri_list[t][0] := i_65;
				tri_list[t][1] := i_66;
				tri_list[t][2] := i_67;
			end;
		end;//of for loop


//   read textures
//end raw data block load


	if (i_18 > 0) then begin
               SetLength(tex_v1, 0); SetLength(tex_v1, i_18);
               SetLength(tex_v2, 0); SetLength(tex_v2, i_18);
               SetLength(tex_v3, 0); SetLength(tex_v3, i_18);
		if (i_31 > 0) then begin
                     SetLength(tex1, 0); SetLength(tex1, i_31);
                     SetLength(tex2, 0); SetLength(tex2, i_31);
                     SetLength(tex3, 0); SetLength(tex3, i_31);
                     SetLength(tex4, 0); SetLength(tex4, i_31);
                     SetLength(tex5, 0); SetLength(tex5, i_31);
                     SetLength(tex6, 0); SetLength(tex6, i_31);
         	   end;
   		if (i_32 > 0) then begin
                     SetLength(tex7, 0); SetLength(tex7, i_32);
                     SetLength(tex8, 0); SetLength(tex8, i_32);
   		   end;



		stream.SetOffset(i_50);
		stream_11.SetOffset(i_51);
		stream_12.SetOffset(i_52);
		stream_13.SetOffset(i_53);
		stream_14.SetOffset(i_54);
		stream_15.SetOffset(i_55);
		for t := 0 to i_18 -1 do
                 begin
                  if (tex_header[t] = 0) then begin
                        tex_v1[t] := stream.ReadUnsigned(2);
                        tex_v2[t] := stream.ReadUnsigned(2);
                        tex_v3[t] := stream.ReadUnsigned(2);
			end;

		  if (tex_header[t] = 1) then begin
                        tex_v1[t] := stream_11.ReadUnsigned(2);
                        tex_v2[t] := stream_11.ReadUnsigned(2);
                        tex_v3[t] := stream_11.ReadUnsigned(2);
                        tex1[t] := stream_12.ReadUnsigned(2);
                        tex2[t] := stream_12.ReadUnsigned(2);
                        tex3[t] := stream_12.ReadUnsigned(2);
                        tex4[t] := stream_13.ReadByte;
                        tex5[t] := stream_14.ReadByte;
                        tex6[t] := stream_15.ReadByte;
	      // 	aShortArray3084[i_72_] = (short) stream_12_.method326(-17162);
	       //	aShortArray3101[i_72_] = (short) stream_12_.method326(-17162);
	       //	aShortArray3102[i_72_] = (short) stream_12_.method326(-17162);
	       //	aByteArray3091[i_72_] = stream_13_.method323((byte) -58);
		//	aByteArray3086[i_72_] = stream_14_.method323((byte) -58);
		//	aByteArray3085[i_72_] = stream_15_.method323((byte) -58);
			end;

		  if (tex_header[t] = 2) then begin
                        tex_v1[t] := stream_11.ReadUnsigned(2);
                        tex_v2[t] := stream_11.ReadUnsigned(2);
                        tex_v3[t] := stream_11.ReadUnsigned(2);
                        tex1[t] := stream_12.ReadUnsigned(2);
                        tex2[t] := stream_12.ReadUnsigned(2);
                        tex3[t] := stream_12.ReadUnsigned(2);
                        tex4[t] := stream_13.ReadByte;
                        tex5[t] := stream_14.ReadByte;
                        tex6[t] := stream_15.ReadByte;
                        tex7[t] := stream_15.ReadByte;
                        tex8[t] := stream_15.ReadByte;
			end;

		  if (tex_header[t] = 3) then begin
                        tex_v1[t] := stream_11.ReadUnsigned(2);
                        tex_v2[t] := stream_11.ReadUnsigned(2);
                        tex_v3[t] := stream_11.ReadUnsigned(2);
                        tex1[t] := stream_12.ReadUnsigned(2);
                        tex2[t] := stream_12.ReadUnsigned(2);
                        tex3[t] := stream_12.ReadUnsigned(2);
                        tex4[t] := stream_13.ReadByte;
                        tex5[t] := stream_14.ReadByte;
                        tex6[t] := stream_15.ReadByte;
			end;
		end;//of for loop
	end;//of if i_18 > 0




end;




end.
