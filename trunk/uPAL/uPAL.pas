(*
 *  FPG EDIT : Edit FPG file from DIV2, FENIX and CDIV 
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 *)

unit uPAL;



interface

 uses LCLIntf, LCLType, classes, SysUtils, uFrmMessageBox, uFPG, uBMP, uPCX, uLanguage;

 function Load_PAL     ( name : string ) : boolean;
 function Load_JASP_pal( name : string ) : boolean;
 function Load_DIV2_pal( name : string ) : boolean;
 function Load_MS_pal  ( name : string ) : boolean;
 function Load_BMP_pal ( name : string ) : boolean;
 function Load_PCX_pal ( name : string ) : boolean;

 function Save_JASP_pal( name : string ) : boolean;
 function Save_DIV2_pal( name : string ) : boolean;
 function Save_MS_pal  ( name : string ) : boolean;
implementation

 function Load_PAL( name : string ) : boolean;
 var
  tmp: Integer;
 begin
  result := false;

  // Archivo PCX
  if ( AnsiPos( '.pcx',AnsiLowerCase(name)) > 0 ) then
  begin
   if not Load_PCX_pal(name) then
   begin
    feMessageBox( LNG_STRINGS[LNG_ERROR], 'PCX ' + LNG_STRINGS[LNG_NOT_FOUND_PALETTE], 0, 0);
    FPG_load_palette  := false;
    Exit;
   end;

   result := true;
   Exit;
  end;

  // Archivo BMP
  if ( AnsiPos(  '.bmp',AnsiLowerCase(name)) > 0 ) then
  begin
   if not Load_BMP_pal(name) then
   begin
    feMessageBox( LNG_STRINGS[LNG_ERROR],'BMP ' + LNG_STRINGS[LNG_NOT_FOUND_PALETTE], 0, 0);
    FPG_load_palette  := false;
    Exit;
   end;

   result := true;
   Exit;
  end;

  // Archivo FPG
  if ( AnsiPos( '.fpg',AnsiLowerCase(name)) > 0 ) then
  begin
   if not Load_DIV2_pal(name) then
   begin
    feMessageBox(LNG_STRINGS[LNG_ERROR], 'FPG ' + LNG_STRINGS[LNG_NOT_FOUND_PALETTE], 0, 0);
    FPG_load_palette  := false;
    Exit;
   end;

   result := true;
   Exit;
  end;

  // Archivos PAL
  if ( AnsiPos( '.pal', AnsiLowerCase(name)) > 0 ) then
  begin
   result := Load_DIV2_pal(name);

   if not result then
    result := Load_MS_pal(name);

   if not result then
    result := Load_JASP_pal(name);

   if not result then
   begin
    feMessageBox(LNG_STRINGS[LNG_ERROR], 'PAL ' + LNG_STRINGS[LNG_NOT_FOUND_PALETTE], 0, 0);
    FPG_load_palette  := false;
    Exit;
   end;

   result := true;
   Exit;
  end;
 end;

 function Load_JASP_pal( name : string ) : boolean;
 var
  f       : TextFile;
  tstring : string;
  r, g, b, i : byte;
 begin
  result := false;

  try
   AssignFile(f, name);
   Reset(f);
  except
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
   Exit;
  end;

  Readln(f, tstring);

  if AnsiPos('JASC-PAL',tstring) <= 0 then
  begin
   CloseFile(f);
   Exit;
  end;

  Readln(f);

  for i:= 0 to 255 do
   begin
    Read(f, r); Read(f, g); Readln(f, b);
    FPG_Header.palette[i*3]       := r shr 2;
    FPG_Header.palette[(i*3) + 1] := g shr 2;
    FPG_Header.palette[(i*3) + 2] := b shr 2;

    FPG_Header.palette[i*3]       := FPG_Header.palette[i*3] shl 2;
    FPG_Header.palette[(i*3) + 1] := FPG_Header.palette[(i*3) + 1] shl 2;
    FPG_Header.palette[(i*3) + 2] := FPG_Header.palette[(i*3) + 2] shl 2;
   end;

  FPG_load_palette := true;
  FPG_Create_hpal;
  
  result := true;

  CloseFile(f);
 end;


 function Load_DIV2_pal( name : string ) : boolean;
 var
  f       : TFileStream;
  temp_FPG_header  : div_fpg_header;
  i : Word;
 begin
  result := false;

  try
   f := TFileStream.Create(name, fmOpenRead);
  except
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
   Exit;
  end;

  try
   f.Read(temp_FPG_header.file_type, 3);
   f.Read(temp_FPG_header.fpg_code , 4);
   f.Read(temp_FPG_header.version, 1);
  except
   f.free;
   Exit;
  end;

  if not (
   (temp_FPG_header.fpg_code [0] = 26) and (temp_FPG_header.fpg_code [1] = 13) and
   (temp_FPG_header.fpg_code [2] = 10) and (temp_FPG_header.fpg_code [3] = 0) )then
  begin
   f.free;
   Exit;
  end;

  f.Read(temp_FPG_header.palette, 768);

  f.free;

  for i:=0 to 767 do
   FPG_header.palette[i] := temp_FPG_header.palette[i] shl 2;

  FPG_load_palette := true;
  FPG_Create_hpal;
  
  result := true;
 end;

 function Load_MS_pal( name : string ) : boolean;
 var
  f : TFileStream;
  i : LongInt;
  header : Array [0 .. 3] of char;
  ms_pal : Array [0 .. 1023] of byte;
 begin
  result := false;

  try
   f := TFileStream.Create(name, fmOpenRead);
  except
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
   Exit;
  end;

  f.Read(header, 4);
  f.Read(i, 4);

  if( (header[0] <> 'R') or (header[1] <> 'I') or (header[2] <> 'F') or
      (header[3] <> 'F') or ( i <> 1044) ) then
  begin
   f.free;
   Exit;
  end;

  f.Read(header, 4);
  f.Read(header, 4);
  f.Read(i, 4);
  f.Read(i, 4);
  f.Read(ms_pal, 1024);

  f.free;

  //Ajustamos la paleta
  for i:= 0 to 255 do
   begin
    FPG_Header.palette[i*3]       := ms_pal[(i * 4) + 2] shr 2;
    FPG_Header.palette[(i*3) + 1] := ms_pal[(i * 4) + 1] shr 2;
    FPG_Header.palette[(i*3) + 2] := ms_pal[i * 4] shr 2;

    FPG_Header.palette[i*3]       := FPG_Header.palette[i*3] shl 2;
    FPG_Header.palette[(i*3) + 1] := FPG_Header.palette[(i*3) + 1] shl 2;
    FPG_Header.palette[(i*3) + 2] := FPG_Header.palette[(i*3) + 2] shl 2;
   end;

   FPG_load_palette := true;
   FPG_Create_hpal;
   
   result := true;

 end;

 function Load_BMP_pal( name : string ) : Boolean;
 var
  f : TFileStream;
  i : word;
 begin
  result := false;

  load_BMP_header(name);

  if is_BMP then
  begin
   f := TFileStream.Create(name, fmOpenRead);

   f.Seek( 54, soFromBeginning);

   f.Read( BMP_palette, 1024 );

   f.free;

   //Ajustamos la paleta
   for i:= 0 to 255 do
   begin
    FPG_Header.palette[i*3]       := BMP_palette[(i * 4) + 2] shr 2;
    FPG_Header.palette[(i*3) + 1] := BMP_palette[(i * 4) + 1] shr 2;
    FPG_Header.palette[(i*3) + 2] := BMP_palette[i * 4] shr 2;

    FPG_Header.palette[i*3]       := FPG_Header.palette[i*3] shl 2;
    FPG_Header.palette[(i*3) + 1] := FPG_Header.palette[(i*3) + 1] shl 2;
    FPG_Header.palette[(i*3) + 2] := FPG_Header.palette[(i*3) + 2] shl 2;
   end;

   FPG_load_palette := true;
   FPG_Create_hpal;

   result := true;
  end;
 end;

 function Load_PCX_pal( name : string ) : Boolean;
 var
  f : TFileStream;
  i : integer;
 begin
  result := false;

  load_PCX_header(name);

  if is_PCX then
  begin
   f := TFileStream.Create(name, fmOpenRead);

   f.Seek( f.Size - 768, soFromBeginning);

   f.Read( FPG_Header.Palette, 768 );

   f.free;

   //Ajustamos la paleta
   for i:= 0 to 255 do
   begin
    FPG_Header.palette[i*3]       := FPG_Header.palette[i*3] shr 2;
    FPG_Header.palette[(i*3) + 1] := FPG_Header.palette[(i*3) + 1] shr 2;
    FPG_Header.palette[(i*3) + 2] := FPG_Header.palette[(i*3) + 2] shr 2;

    FPG_Header.palette[i*3]       := FPG_Header.palette[i*3] shl 2;
    FPG_Header.palette[(i*3) + 1] := FPG_Header.palette[(i*3) + 1] shl 2;
    FPG_Header.palette[(i*3) + 2] := FPG_Header.palette[(i*3) + 2] shl 2;
   end;

   FPG_load_palette := true;
   FPG_Create_hpal;

   result := true;
  end;
 end;

 function Save_JASP_pal( name : string ) : boolean;
 var
  f       : TextFile;
  i : byte;
 begin
  result := false;

  try
   AssignFile(f, name);
   ReWrite(f);
  except
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
   Exit;
  end;

  Writeln(f, 'JASC-PAL');
  Writeln(f, '0100');
  Writeln(f, '256');

  for i:= 0 to 255 do
   begin
    Write(f, FPG_Header.palette[i*3]);
    Write(f, ' ');
    Write(f, FPG_Header.palette[(i*3) + 1]);
    Write(f, ' ');
    WriteLn(f, FPG_Header.palette[(i*3) + 2]);
   end;

  result := true;

  CloseFile(f);
 end;

 function Save_DIV2_pal( name : string ) : boolean;
 var
  f        : file of byte;
  temp_byte: byte;
  i : Word;
 begin
  result := false;

  try
   AssignFile(f, name);
   ReWrite(f);
  except
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
   Exit;
  end;

  temp_byte := Ord('p'); Write(f, temp_byte);
  temp_byte := Ord('a'); Write(f, temp_byte);
  temp_byte := Ord('l'); Write(f, temp_byte);
  temp_byte := 26; Write(f, temp_byte);
  temp_byte := 13; Write(f, temp_byte);
  temp_byte := 10; Write(f, temp_byte);
  temp_byte := 0;  Write(f, temp_byte); Write(f, temp_byte);

  for i:=0 to 767 do
  begin
   temp_byte := FPG_header.palette[i] shr 2;
   Write(f, temp_byte);
  end;

  temp_byte := 0;

  for i:=0 to 575 do
   Write(f, temp_byte);

  CloseFile(f);

  result := true;
 end;

 function Save_MS_pal( name : string ) : boolean;
 var
  f : TFileStream;
  i : LongInt;
  header : Array [0 .. 7] of char;
  ms_pal : Array [0 .. 1023] of byte;
 begin
  result := false;

  try
   f := TFileStream.Create(name, fmCreate);
  except
   feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
   Exit;
  end;

  header := 'RIFF';
  f.Write(header, 4);
  i := 1044;
  f.Write(i, 4);
  header := 'PAL data';
  f.Write(header, 8);
  i := 1032;
  f.Write(i, 4);
  i := 16777984;
  f.Write(i, 4);

  //Ajustamos la paleta
  for i:= 0 to 255 do
   begin
    ms_pal[(i * 4) + 2] := 0;
    ms_pal[(i * 4) + 2] := FPG_Header.palette[i*3];
    ms_pal[(i * 4) + 1] := FPG_Header.palette[(i*3) + 1];
    ms_pal[ i * 4     ] := FPG_Header.palette[(i*3) + 2];
   end;

  f.Write(ms_pal, 1024);

  ms_pal[0] := 255;  ms_pal[1] := 255; ms_pal[2] := 255;  ms_pal[3] := 255;
  f.Write(ms_pal, 4);

  f.free;

  result := true;

 end;

end.
