(*
 *  FPG Editor : Edit FPG file from DIV2, FENIX and CDIV
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

unit uFPGConvert;


interface

uses LCLIntf, LCLType, ComCtrls, Graphics, Controls, SysUtils, Classes,
     ClipBrd, Forms,
     uLanguage, uFPG, uIniFile, uTools,
     uSort, uColor16bits, uFPGListView, uFrmMessageBox, IntfGraphics;

const
 GMask = 63;

type
 two_bytes = record
  byte0, byte1 : byte;
 end;

var
 Table_FPG_Convert : array [0 .. 31, 0 .. 63, 0 .. 31] of LongWord;
 New_type          : Integer;

 procedure Convert_to_FPG1( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG8_DIV2( var lvFPG: TFPGListView;  var gFPG: TProgressBar);

 procedure Convert_to_FPG16_common( var lvFPG: TFPGListView;  var gFPG: TProgressBar; cdivformat:boolean =false);
 procedure Convert_to_FPG16_CDIV( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG16_FENIX( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG24( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG32( var lvFPG: TFPGListView;  var gFPG: TProgressBar);

 procedure Init_Table_FPG_Convert;

implementation

 procedure Init_Table_FPG_Convert;
 var
  r, g, b : byte;
 begin
  for r := 0 to 31 do
   for g := 0 to 63 do
    for b := 0 to 31 do
     Table_FPG_Convert[r, g, b] := 0;
 end;

procedure Convert_to_FPG8_DIV2( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 i, j, count,
 byte0, byte1  : Word;
 R16, G16, B16 : Byte;
 sort_pixels : TList;
 sort_pixel  : Table_Sort;
 table_pixels: Array [0 .. 65535] of Table_Sort;
 total_pixels, convert_pixels : LongWord;

 rgbLine : PRGBAQuad;

  lazBMP: TLazIntfImage;
  tmpBMP : TBitmap;

begin
 New_type := FPG8_DIV2;

 //Convert_to_FPG16_common(ilFPG, lvFPG, frmMain, gFPG );

 Init_Table_FPG_Convert;

 total_pixels   := 0;
 convert_pixels := 0;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count do
 begin
  with lvFPG.Fpg.images[count] do
  begin
   lazBMP:=TLazIntfImage.Create(0,0);
   lazBMP.LoadFromBitmap(bmp.Handle,bmp.MaskHandle);

   for j := 0 to height - 1 do
   begin
    rgbLine := lazBMP.GetDataLineStart(j);

    for i := 0 to width - 1 do
     begin
      R16 := rgbLine[i].Blue shr 3;
      G16 := rgbLine[i].Green shr 2;
      B16 := rgbLine[i].Red shr 3;

      Table_FPG_Convert[R16, G16, B16] := Table_FPG_Convert[R16, G16, B16] + 1;
     end;
   end;

   total_pixels := total_pixels + (width * height);

   bmp.LoadFromIntfImage(lazBMP);
   lazBMP.free;

  end;

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;

 end;

 sort_pixels := TList.Create;

 // Ordenamos los resultados del analisis
 for count := 0 to 65535 do
 begin
  //Carga los datos
  byte0 := count shr 8;
  byte1 := count - (byte0 shl 8);

  //Extrae el RGB de 16bits
  Calculate_RGB16(byte0, byte1, R16, G16, B16);

  table_pixels[count].nSort := Table_FPG_Convert[R16, G16, B16];
  table_pixels[count].nLink := count;

  sort_pixels.Add(@table_pixels[count]);
 end;

 sort_pixels.Sort(@SortCompare);

 gFPG.Hide;

 // Establecemos la paleta de colores
 i := 65535;

 lvFPG.Fpg.Header.palette[ 0 ] := 0;
 lvFPG.Fpg.Header.palette[ 1 ] := 0;
 lvFPG.Fpg.Header.palette[ 2 ] := 0;

 count := 0;

 while count < 256 do
 begin
  sort_pixel := Table_Sort(sort_pixels.Items[i]^);
  convert_pixels := convert_pixels + sort_pixel.nSort;

  if sort_pixel.nLink <> 0 then
  begin
   // Carga los datos
   byte0 := sort_pixel.nLink shr 8;
   byte1 := sort_pixel.nLink - (byte0 shl 8);

   // Extrae el RGB de 16bits ya convertido en 0-255 valores
   Calculate_RGB(byte0, byte1, R16, G16, B16);

   count := count + 1;

   lvFPG.Fpg.Header.palette[  count * 3      ] := R16;
   lvFPG.Fpg.Header.palette[ (count * 3) + 1 ] := G16;
   lvFPG.Fpg.Header.palette[ (count * 3) + 2 ] := B16;
  end;

  i := i - 1;
 end;

 // Ordenamos los colores de la paleta
 lvFPG.Fpg.Sort_Palette;

 //FPG_Create_hpal;

 lvFPG.Fpg.FPGtype             := FPG8_DIV2;
 lvFPG.Fpg.header.FileType := 'fpg';
 lvFPG.Fpg.loadpalette     := true;
 lvFPG.Fpg.update := true;

 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 //lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 //lvFPG.LargeImages.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 // Creamos la tabla de conversión
 lvFPG.Fpg.Create_table_16_to_8;

 for count:= 1 to lvFPG.Fpg.Count do
 begin
  tmpBMP:=lvFPG.Fpg.images[count].bmp;
  lvFPG.Fpg.images[count].bmp:=createBitmap8bpp(tmpBMP,lvFPG.Fpg.header.palette);
  FreeAndNil(tmpBMP);

  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;

 total_pixels := total_pixels div 100;

 // Si la precisión sobrepasa el 100%
 if ( convert_pixels div total_pixels ) > 100 then
 begin
  total_pixels   := 1;
  convert_pixels := 100;
 end;

 feMessageBox( LNG_STRINGS[LNG_INFO], LNG_STRINGS[LNG_PALETTE_PRECISION] + ' [ '
            + IntToStr(convert_pixels div total_pixels) + '% ]',
            0, 0);
end;

procedure Convert_to_FPG16_common( var lvFPG: TFPGListView;  var gFPG: TProgressBar; cdivformat : boolean = false);
var
 count   : LongInt;
 tmpBMP : TBitmap;
begin
 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 lvFPG.LargeImages.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count  do
 begin

  tmpBMP:=lvFPG.Fpg.images[count].bmp;
  lvFPG.Fpg.images[count].bmp:=createBitmap16bpp(tmpBMP,cdivformat);
  FreeAndNil(tmpBMP);
  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;


procedure Convert_to_FPG16_FENIX( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
begin
 New_type := FPG16;

 Convert_to_FPG16_common( lvFPG, gFPG);

 // Actualizamos los datos del FPG
 lvFPG.Fpg.FPGtype             := FPG16;
 lvFPG.Fpg.header.FileType := 'f16';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;
end;

procedure Convert_to_FPG16_CDIV( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
begin
 New_type := FPG16_CDIV;

 Convert_to_FPG16_common( lvFPG, gFPG, true);

 // Actualizamos los datos del FPG
 lvFPG.Fpg.FPGtype             := FPG16_CDIV;
 lvFPG.Fpg.header.FileType := 'c16';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;
end;

procedure Convert_to_FPG24( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 count   : LongInt;
 tmpBMP  : TBitmap;
begin
 New_type := FPG24;

 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 lvFPG.LargeImages.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count  do
 begin
  tmpBMP:= lvFPG.Fpg.images[count].bmp;
  lvFPG.Fpg.images[count].bmp:=createBitmap24bpp(tmpBMP);
  FreeAndNil(tmpBMP);
  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;
 // Actualizamos los datos del FPG
 lvFPG.Fpg.FPGtype             := FPG24;
 lvFPG.Fpg.header.FileType := 'f24';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;

end;

procedure Convert_to_FPG32( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
begin
 New_type := FPG32;

 // Actualizamos los datos del FPG
 lvFPG.Fpg.FPGtype             := FPG32;
 lvFPG.Fpg.header.FileType := 'f32';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;
end;

procedure Convert_to_FPG1( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 count   : LongInt;
 tmpBMP : TBitmap;

begin
 New_type := FPG1;


 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 lvFPG.LargeImages.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count do
 begin

  tmpBMP:=lvFPG.Fpg.images[count].bmp;
  lvFPG.Fpg.images[count].bmp:=createBitmap1bpp(tmpBMP);
  FreeAndNil(tmpBMP);
  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;
 // Actualizamos los datos del FPG
 lvFPG.Fpg.FPGtype             := FPG1;
 lvFPG.Fpg.header.FileType := 'f01';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;
end;


end.
