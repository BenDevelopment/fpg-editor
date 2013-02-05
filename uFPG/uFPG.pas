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

unit uFPG;

{$mode objfpc}{$H+}

interface

uses LCLIntf, LCLType, SysUtils, Forms, Classes,
  Graphics, FileUtil, ComCtrls, IntfGraphics,
  uFrmMessageBox, uLanguage, uColor16bits, uCopyPalette, uMap, Dialogs;

const
  MAX_NUM_IMAGES = 999;
  FPG_NULL = 255;
  FPG1 = 0;
  FPG8_DIV2 = 1;
  FPG16 = 2;
  FPG16_CDIV = 3;
  FPG24 = 4;
  FPG32 = 5;
  STRFPG1 = 'FPG 1 bit (All)';
  STRFPG8 = 'FPG 8 bits (All)';
  STRFPG16 = 'FPG 16 bits (Fenix/BennuGD)';
  STRFPGCDIV16 = 'FPG 16 bits (CDIV)';
  STRFPG24 = 'FPG 24 bits ';
  STRFPG32 = 'FPG 32 bits (BennuGD)';

type
  div_fpg_header = record
    file_type: array [0 .. 2] of char; {fpg, f16, c16}
    fpg_code: array [0 .. 3] of byte;
    version: byte;
    palette: array [0 .. 767] of byte;
    gamma: array [0 .. 575] of byte;
  end;

  div_fpg_bmp_header = record
    graph_code: longint;
    graph_size: longint;
    description: array [0 .. 31] of char;
    Name: array [0 .. 11] of char;
    Width: longint;
    Height: longint;
    points: longint;
  end;

  memory_header_bmp = record
    graph_code: longint;
    fpname: array [0 .. 11] of char;
    Name: array [0 .. 31] of char;
    Width: longint;
    Height: longint;
    points: longint;
    control_points: array [0 .. 2047] of short;
    bmp: TBitMap;
    graph_size: longint;
  end;

var
  FPG_header: div_fpg_header;
  FPG_images: array [1 .. 999] of memory_header_bmp;
  FPG_type: byte;
  FPG_active, FPG_update: boolean;
  FPG_source: string;
  FPG_hpal: HPALETTE;

  FPG_need_table: boolean;
  FPG_table_16_to_8: array [0 .. 31, 0 .. 63, 0 .. 31] of byte;

  FPG_add_pos, FPG_last_code: word;

  FPG_load_palette: boolean;

procedure FPG_init;
procedure FPG_Create_hpal;

function CodeExists(code: word): boolean;
function indexOfCode(code: word): word;
procedure DeleteWithCode(code: word);
procedure FPG_Free;
procedure FPG_Save(var frmMain: TForm; var gFPG: TProgressBar);
function FPG_Test(str: string): boolean;
function FPG_Load(str: string; var frmMain: TForm; var gFPG: TProgressBar): boolean;

procedure Create_FPG_table_16_to_8;
procedure Sort_Palette;
function Find_Color(index, rc, gc, bc: integer): integer;
procedure stringToArray(var inarray: array of char; str: string; len: integer);

procedure MAP_Save(index: integer; filename: string);
procedure writeBitmap( var f: TFileStream ;var bitmap : TBitmap; byte_size : word);


implementation

//-----------------------------------------------------------------------------
// init_FPG: Inicializa el FPG
//-----------------------------------------------------------------------------

procedure FPG_init;
begin
  FPG_need_table := False;
  FPG_hpal := 0;
end;

procedure FPG_Create_hpal;
var
  pal: PLogPalette;
  i: longint;
begin
  pal := nil;

  try
    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);

    pal^.palVersion := $300;
    pal^.palNumEntries := 256;

    for i := 0 to 255 do
    begin
      pal^.palPalEntry[i].peRed := FPG_header.palette[(i * 3)];
      pal^.palPalEntry[i].peGreen := FPG_header.palette[(i * 3) + 1];
      pal^.palPalEntry[i].peBlue := FPG_header.palette[(i * 3) + 2];
      pal^.palPalEntry[i].peFlags := 0;
    end;

    FPG_hpal := CreatePalette(pal^);

  finally
    FreeMem(pal);
  end;
end;

//-----------------------------------------------------------------------------
// CodeExists: Comprueba si existe el código del gráfico en el FPG
//-----------------------------------------------------------------------------

function CodeExists(code: word): boolean;
begin
   CodeExists:= (indexOfCode(code) <> 0);
end;

function indexOfCode(code: word): word;
var
  i: word;
begin
  indexOfCode := 0;

  if (code <= 0) or (code > 999) or (FPG_add_pos < 1) then
  begin
    indexOfCode := 0;
    Exit;
  end;

  for i := 1 to FPG_add_pos - 1 do
    if FPG_Images[i].graph_code = code then
    begin
      indexOfCode := i;
      break;
    end;
end;

//-----------------------------------------------------------------------------
// FreeFPG: Libera la memoria reservada e inicializa el FPG
//-----------------------------------------------------------------------------

procedure FPG_Free;
var
  i: word;
begin
  if FPG_type = FPG8_DIV2 then
    DeleteObject(FPG_hpal);

  if FPG_add_pos > 0 then
  begin
    for i := 1 to FPG_add_pos - 1 do
    begin
//      if FPG_type = FPG8_DIV2 then
//        DeleteObject(FPG_Images[i].bmp.Palette);
      if FPG_Images[i].bmp<> nil then
            FreeAndNil(FPG_Images[i].bmp);
    end;
  end;

  FPG_add_pos := 1;
  FPG_last_code := 0;
  FPG_load_palette := False;
  FPG_active := False;
end;


//-----------------------------------------------------------------------------
// DeleteWithCode: Elimina un elemento de FPG con el código
//-----------------------------------------------------------------------------

procedure DeleteWithCode(code: word);
var
  i: word;
begin
  if (FPG_add_pos <= 1) then
    Exit;

  for i := 1 to (FPG_add_pos - 1) do
  begin
    if FPG_Images[i].graph_code <> code then
      continue;

    FPG_Images[i].bmp.Destroy;

    FPG_add_pos := FPG_add_pos - 1;
    FPG_last_code := code - 1;

    FPG_Images[i] := FPG_Images[FPG_add_pos];

    break;
  end;

end;
function IntToBin ( value: LongInt; digits: integer ): string;
begin
  result := StringOfChar ( '0', digits ) ;
  while value > 0 do begin
    if ( value and 1 ) = 1 then
        result [ digits ] := '1';
    dec ( digits ) ;
    value := value shr 1;
  end;
end;

//-----------------------------------------------------------------------------
// FPG_Save: Guarda el FPG actual a disco.
//-----------------------------------------------------------------------------

procedure FPG_Save(var frmMain: TForm; var gFPG: TProgressBar);
var
  f: TFileStream;
  i, j, k: word;
  graph_size: longint;
  bytes_per_pixel: word;
  widthForFPG1: integer;

begin
  bytes_per_pixel := 0;
  case FPG_type of
    FPG1:
    begin
      bytes_per_pixel := 0;
    end;
    FPG8_DIV2:
    begin
      bytes_per_pixel := 1;
    end;
    FPG16, FPG16_CDIV:
    begin
      bytes_per_pixel := 2;
    end;
    FPG24:
    begin
      bytes_per_pixel := 3;
    end;
    FPG32:
    begin
      bytes_per_pixel := 4;
    end;
  end;

  f := TFileStream.Create(FPG_source, fmCreate);

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;

  f.Write(FPG_Header.file_type, 3);
  f.Write(FPG_Header.fpg_code, 4);
  f.Write(FPG_Header.version, 1);

  if FPG_type = FPG8_DIV2 then
  begin
    for i := 0 to 767 do
      FPG_Header.Palette[i] := FPG_Header.Palette[i] shr 2;

    f.Write(FPG_Header.Palette, 768);
    f.Write(FPG_Header.gamma, 576);

    for i := 0 to 767 do
      FPG_Header.Palette[i] := FPG_Header.Palette[i] shl 2;
  end;

  graph_size := 0;
  for i := 1 to FPG_add_pos - 1 do
  begin
    if FPG_type <> FPG1 then
    begin
      graph_size := (FPG_Images[i].Width * FPG_Images[i].Height * bytes_per_pixel) + 64;
    end else begin
      widthForFPG1 := FPG_Images[i].Width;
      if (FPG_Images[i].Width mod 8) <> 0 then
        widthForFPG1 := widthForFPG1 + 8 - (FPG_Images[i].Width mod 8);
      graph_size := (widthForFPG1 div 8) * FPG_Images[i].Height + 64;
    end;

    if ((FPG_Images[i].points > 0) and (FPG_Images[i].points <> 4096)) then
      graph_size := graph_size + (FPG_Images[i].points * 4);

    f.Write(FPG_Images[i].graph_code, 4);
    f.Write(graph_size, 4);
    f.Write(FPG_Images[i].Name, 32);
    f.Write(FPG_Images[i].fpname, 12);
    f.Write(FPG_Images[i].Width, 4);
    f.Write(FPG_Images[i].Height, 4);
    f.Write(FPG_Images[i].points, 4);

    if ((FPG_Images[i].points > 0) and (FPG_Images[i].points <> 4096)) then
      f.Write(FPG_Images[i].control_points, FPG_Images[i].points * 4);

    writeBitmap(f,FPG_Images[i].bmp,bytes_per_pixel );

    gFPG.Position := (i * 100) div (FPG_add_pos - 1);
    gFPG.Repaint;
  end;

  gFPG.Hide;

  f.Free;

  feMessageBox(LNG_STRINGS[LNG_INFO], LNG_STRINGS[LNG_CORRECT_SAVING], 0, 0);
end;

//Comprobamos si es un archivo FPG sin comprimir
function FPG_Test(str: string): boolean;
var
  f: TFileStream;
begin
  Result := False;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
    Exit;

  try
    f := TFileStream.Create(str, fmOpenRead);
  except
    Exit;
  end;

  try
    f.Read(FPG_header.file_type, 3);
    f.Read(FPG_header.fpg_code, 4);
    f.Read(FPG_header.version, 1);
  finally
    f.Free;
  end;

  // Ficheros de 1 bit
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '0') and
    (FPG_header.file_type[2] = '1') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
    Result := True;

  // Ficheros de 8 bits
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = 'p') and
    (FPG_header.file_type[2] = 'g') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
    Result := True;

  // Ficheros de 16 bits
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '1') and
    (FPG_header.file_type[2] = '6') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
    Result := True;

  // Ficheros de 16 bits para CDIV
  if (FPG_header.file_type[0] = 'c') and (FPG_header.file_type[1] = '1') and
    (FPG_header.file_type[2] = '6') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
    Result := True;

  // Ficheros de 24 bits
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '2') and
    (FPG_header.file_type[2] = '4') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
    Result := True;

  // Ficheros de 32 bits
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '3') and
    (FPG_header.file_type[2] = '2') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
    Result := True;

end;


//-----------------------------------------------------------------------------
// LoadFPG: Carga un FPG a memoria.
//-----------------------------------------------------------------------------


function FPG_Load(str: string; var frmMain: TForm; var gFPG: TProgressBar): boolean;
var
  f: TStream;
  frames, length, speed: word;
  byte_size: word;
  i : Integer;
begin
  FPG_type := FPG_NULL;

  Result := False;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
    Exit;

  //if not FPG_Test(str) then
  //begin
  //  zipfile:= TZipFile.Create(frmMain);
  //  zipfile.FileName:=str;
  //  zipfile.Activate;
  //  f:=zipfile.GetFileStream(ExtractFileNameOnly(str),bufflen);
  //  zipfile.Destroy;
  //end else
  begin
    try
      f := TFileStream.Create(str, fmOpenRead);
    except
      Exit;
    end;
  end;

  try
    f.Read(FPG_header.file_type, 3);
    f.Read(FPG_header.fpg_code, 4);
    f.Read(FPG_header.version, 1);
  except
    f.Free;
    Exit;
  end;

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;
  byte_size := 0;

  // Ficheros de 1 bit
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '0') and
    (FPG_header.file_type[2] = '1') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
  begin
    FPG_type := FPG1;
    byte_size := 0;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = 'p') and
    (FPG_header.file_type[2] = 'g') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
  begin
    FPG_type := FPG8_DIV2;
    byte_size := 1;
  end;
  // Ficheros de 16 bits para FENIX
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '1') and
    (FPG_header.file_type[2] = '6') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
  begin
    FPG_type := FPG16;
    byte_size := 2;
  end;

  // Ficheros de 16 bits para CDIV
  if (FPG_header.file_type[0] = 'c') and (FPG_header.file_type[1] = '1') and
    (FPG_header.file_type[2] = '6') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
  begin
    FPG_type := FPG16_CDIV;
    byte_size := 2;
  end;

  // Ficheros de 24 bits
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '2') and
    (FPG_header.file_type[2] = '4') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
  begin
    FPG_type := FPG24;
    byte_size := 3;
  end;

  // Ficheros de 32 bits
  if (FPG_header.file_type[0] = 'f') and (FPG_header.file_type[1] = '3') and
    (FPG_header.file_type[2] = '2') and (FPG_header.fpg_code[0] = 26) and
    (FPG_header.fpg_code[1] = 13) and (FPG_header.fpg_code[2] = 10) and
    (FPG_header.fpg_code[3] = 0) then
  begin
    FPG_type := FPG32;
    byte_size := 4;
  end;

  if (FPG_type = FPG_NULL) then
  begin
    feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_WRONG_FPG], 0, 0);
    f.Free;
    Exit;
  end;

  try
    if (FPG_type = FPG8_DIV2) then
    begin
      f.Read(FPG_header.palette, 768);
      f.Read(FPG_header.gamma, 576);

      for i := 0 to 767 do
        FPG_header.palette[i] := FPG_header.palette[i] shl 2;

      FPG_load_palette := True;
      FPG_Create_hpal;

      FPG_need_table := True;
    end;

    FPG_add_pos := 1;

    while f.Position < f.Size do
    begin

      // Establecemos la imagen
      with FPG_images[FPG_add_pos] do
      begin
        f.Read(graph_code, 4);
        f.Read(graph_size, 4);
        f.Read(Name, 32);
        f.Read(fpname, 12);
        f.Read(Width, 4);
        f.Read(Height, 4);
        f.Read(points, 4);

        // Leemos los puntos de control del bitmap
        if ((points > 0) and (points <> 4096)) then
        begin
          f.Read(control_points, points * 4);
        end;

        if (points = 4096) then
        begin
          f.Read(frames, 2);
          f.Read(length, 2);
          f.Read(speed, 2);
          f.Seek(length * 2, soFromCurrent);
        end;

        bmp:=loadDataBitmap(f,FPG_header.palette,width,height, byte_size, FPG_type=FPG16_CDIV);

        gFPG.Position := (f.Position * 100) div f.Size;
        gFPG.Repaint;
      end;  // end with

      FPG_add_pos := FPG_add_pos + 1;
    end; // end wile
    gFPG.Hide;
    Result := True;
  finally
    f.Free;
  end;
end;


function Find_Color(index, rc, gc, bc: integer): integer;
var
  dif_colors, temp_dif_colors, i: word;
begin
  dif_colors := 800;
  Result := 0;

  for i := index to 255 do
  begin
    temp_dif_colors :=
      Abs(rc - FPG_Header.palette[i * 3]) +
      Abs(gc - FPG_Header.palette[(i * 3) + 1]) +
      Abs(bc - FPG_Header.palette[(i * 3) + 2]);

    if temp_dif_colors <= dif_colors then
    begin
      Result := i;
      dif_colors := temp_dif_colors;

      if dif_colors = 0 then
        Exit;
    end;

  end;

end;

procedure Sort_Palette;
var
  R, G, B, i, color_index: integer;
begin
  i := 1;

  repeat
    // Buscamos el color que más se parece al anterior
    color_index := Find_Color(i, FPG_Header.palette[(i - 1) * 3],
      FPG_Header.palette[((i - 1) * 3) + 1], FPG_Header.palette[((i - 1) * 3) + 2]);
    // Intercambio de colores
    R := FPG_Header.palette[color_index * 3];
    G := FPG_Header.palette[(color_index * 3) + 1];
    B := FPG_Header.palette[(color_index * 3) + 2];

    FPG_Header.palette[color_index * 3] := FPG_Header.palette[i * 3];
    FPG_Header.palette[(color_index * 3) + 1] := FPG_Header.palette[(i * 3) + 1];
    FPG_Header.palette[(color_index * 3) + 2] := FPG_Header.palette[(i * 3) + 2];

    FPG_Header.palette[i * 3] := R;
    FPG_Header.palette[(i * 3) + 1] := G;
    FPG_Header.palette[(i * 3) + 2] := B;

    i := i + 1;
  until i >= 255;
end;

procedure Create_FPG_Table_16_to_8;
var
  i: byte;
  r, g, b: byte;
begin
  for r := 0 to 31 do
    for g := 0 to 63 do
      for b := 0 to 31 do
        FPG_table_16_to_8[r, g, b] := 0;

  for i := 0 to 255 do
    FPG_table_16_to_8[
      FPG_Header.palette[(i * 3)] shr 3,
      FPG_Header.palette[(i * 3) + 1] shr 2,
      FPG_Header.palette[(i * 3) + 2] shr 3] := i;
end;

procedure stringToArray(var inarray: array of char; str: string; len: integer);
var
  i: integer;
begin
  for i := 0 to len - 1 do
  begin
    if i >= length(str) then
      inarray[i] := char(0)
    else
      inarray[i] := str[i + 1];
  end;
end;

procedure writeBitmap( var f: TFileStream ;var bitmap : TBitmap; byte_size : word);
var
  lazBMP : TLazIntfImage;
  byte_line: array [0 .. 16383] of byte;
  byteForFPG1: byte;
  insertedBits: integer;
  p_bytearray: PByteArray;
  i, j, k: word;
begin
  lazBMP := bitmap.CreateIntfImage;

  for k := 0 to bitmap.Height - 1 do
  begin
    p_bytearray := lazBmp.GetDataLineStart(k);
    case FPG_type of
      FPG1:
      begin
          insertedBits := 0;
          byteForFPG1 := 0;
          for j := 0 to bitmap.Width - 1 do
          begin
            if (p_bytearray^[j * 3] shr 7) = 1 then
            begin
              byteForFPG1 := byteForFPG1 or 1; // bit más alto en 8 bits
            end;
            insertedBits := insertedBits + 1;
            if (insertedBits = 8) then
            begin
              f.Write(byteForFPG1, 1);
              byteForFPG1 := 0;
              insertedBits := 0;
            end else
              byteForFPG1 := byteForFPG1 shl 1;
          end;
          if insertedBits > 0 then
          begin
            byteForFPG1 := byteForFPG1 shl (7 - insertedBits);
            f.Write(byteForFPG1, 1);
          end;
     end;
     FPG8_DIV2:
     begin
        for j := 0 to bitmap.Width - 1 do
        begin
           byte_line[j]:=Find_Color(0,p_bytearray^[j * 3+2],p_bytearray^[j * 3+1],p_bytearray^[j * 3]);
        end;
        f.Write(byte_line, bitmap.Width);
     end;
     FPG16,
     FPG16_CDIV:
     begin
       for j := 0 to bitmap.Width - 1 do
       begin
         if FPG_type = FPG16 then
           set_BGR16(byte_line[j*2+1], byte_line[j*2],p_bytearray^[j * 3],p_bytearray^[j * 3+1],p_bytearray^[j * 3+2] )
         else
           set_RGB16(byte_line[j*2+1], byte_line[j*2],p_bytearray^[j * 3],p_bytearray^[j * 3+1],p_bytearray^[j * 3+2] );
       end;
       f.Write(byte_line, bitmap.Width*byte_size);
     end;
     else  // 24 y 32 bits
     begin
         f.Write(p_bytearray^, bitmap.Width * byte_size);
     end;
     end;

  end;
  lazBMP.Free;

end;

procedure MAP_Save(index: integer; filename: string);
var
  f: TFileStream;
  byte_size: word;
  header: file_str_map;
  i : word;
begin
  byte_size := 0;
  case FPG_type of
    FPG1:
    begin
      byte_size := 0;
      stringToArray(header.magic, 'm01', 3);
    end;
    FPG8_DIV2:
    begin
      byte_size := 1;
      stringToArray(header.magic, 'map', 3);
    end;
    FPG16, FPG16_CDIV:
    begin
      byte_size := 2;
      stringToArray(header.magic, 'm16', 3);
    end;
    FPG24:
    begin
      byte_size := 3;
      stringToArray(header.magic, 'm24', 3);
    end;
    FPG32:
    begin
      byte_size := 4;
      stringToArray(header.magic, 'm32', 3);
    end;
  end;

  f := TFileStream.Create(filename, fmCreate);


  f.Write(header.magic, 3);
  f.Write(FPG_Header.fpg_code, 4);
  f.Write(FPG_Header.version, 1);

  header.Width := FPG_Images[index].Width;
  header.Height := FPG_Images[index].Height;
  f.Write(header.Width, 2);
  f.Write(header.Height, 2);

  f.Write(FPG_Images[index].graph_code, 4);
  f.Write(FPG_Images[index].Name, 32);

  if FPG_type = FPG8_DIV2 then
  begin
    for i := 0 to 767 do
      FPG_Header.Palette[i] := FPG_Header.Palette[i] shr 2;

    f.Write(FPG_Header.Palette, 768);
    f.Write(FPG_Header.gamma, 576);

    for i := 0 to 767 do
      FPG_Header.Palette[i] := FPG_Header.Palette[i] shl 2;
  end;

  header.flags := FPG_Images[index].points;
  f.Write(header.flags, 2);

  if ((header.flags > 0) and (header.flags <> 4096)) then
    f.Write(FPG_Images[index].control_points, header.flags * 4);

  writeBitmap(f, FPG_Images[index].bmp,byte_size );

  f.Free;

end;



end.