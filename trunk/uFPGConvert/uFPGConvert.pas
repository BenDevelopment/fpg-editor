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

unit uFPGConvert;


interface

uses LCLIntf, LCLType, ComCtrls, Graphics, Controls, SysUtils, Classes,
     ClipBrd, Forms,
     uLanguage, uFPG, uIniFile, uTools,
     uSort, uColor16bits, uListViewFPG, uFrmMessageBox, IntfGraphics;

const
 GMask = 63;

type
 two_bytes = record
  byte0, byte1 : byte;
 end;

var
 Table_FPG_Convert : array [0 .. 31, 0 .. 63, 0 .. 31] of LongWord;
 New_type          : Integer;

 procedure Convert_to_FPG8_DIV2(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);

 procedure Convert_to_FPG16(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
 procedure Convert_to_FPG16_CDIV(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
 procedure Convert_to_FPG16_FENIX(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
 
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

procedure Convert_to_FPG8_DIV2(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
var
 i, j, count,
 byte0, byte1  : Word;
 R16, G16, B16 : Byte;
 sort_pixels : TList;
 sort_pixel  : Table_Sort;
 table_pixels: Array [0 .. 65535] of Table_Sort;
 total_pixels, convert_pixels : LongWord;

 rgbLine : pRGBLine;

  lazBMP: TLazIntfImage;
  ImgHandle,ImgMaskHandle: HBitmap;

begin
 New_type := FPG8_DIV2;

 if FPG_type = FPG16_CDIV then
  Convert_to_FPG16(ilFPG, lvFPG, frmMain, gFPG );

 Init_Table_FPG_Convert;

 total_pixels   := 0;
 convert_pixels := 0;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to FPG_add_pos - 1 do
 begin
  with FPG_images[count] do
  begin
   lazBMP:=TLazIntfImage.Create(0,0);
   lazBMP.LoadFromBitmap(bmp.Handle,bmp.MaskHandle);

   for j := 0 to height - 1 do
   begin
    rgbLine := lazBMP.GetDataLineStart(j);

    for i := 0 to width - 1 do
     begin
      R16 := rgbLine^[i].B shr 3;
      G16 := rgbLine^[i].G shr 2;
      B16 := rgbLine^[i].R shr 3;

      Table_FPG_Convert[R16, G16, B16] := Table_FPG_Convert[R16, G16, B16] + 1;
     end;
   end;

   total_pixels := total_pixels + (width * height);

   lazBMP.CreateBitmaps(imgHandle,imgMaskHandle,false);
   bmp.handle:=imgHandle;
   bmp.maskhandle:=imgMaskHandle;
   lazBMP.free;

  end;

  gFPG.Position:= (count * 100) div (FPG_add_pos - 1);
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

 FPG_Header.palette[ 0 ] := 0;
 FPG_Header.palette[ 1 ] := 0;
 FPG_Header.palette[ 2 ] := 0;

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

   // Extrae el RGB de 16bits
   Calculate_RGB16(byte0, byte1, R16, G16, B16);

   count := count + 1;

   FPG_Header.palette[  count * 3      ] := R16 shl 3;
   FPG_Header.palette[ (count * 3) + 1 ] := G16 shl 2;
   FPG_Header.palette[ (count * 3) + 2 ] := B16 shl 3;
  end;

  i := i - 1;
 end;

 // Ordenamos los colores de la paleta
 Sort_Palette;

 FPG_Create_hpal;

 FPG_type             := FPG8_DIV2;
 FPG_header.file_type := 'fpg';
 FPG_load_palette     := true;
 FPG_update := true;

 ilFPG.Clear;
 lvFPG.Items.Clear;

 ilFPG.Width  := inifile_sizeof_icon;
 ilFPG.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 // Creamos la tabla de conversión
 Create_FPG_table_16_to_8;

 for count:= 1 to FPG_add_pos - 1 do
 begin
  createBitmap8bpp(FPG_images[count].bmp,FPG_images[count].bmp);

  lvFPG_add_items( count, lvFPG, ilFPG);

  gFPG.Position:= (count * 100) div (FPG_add_pos - 1);
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

procedure Convert_to_FPG16(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
var
 count   : LongInt;
 i, j    : LongInt;
 rgbLine : pRGBLine;
 lazBMP: TLazIntfImage;
  ImgHandle,ImgMaskHandle: HBitmap;
begin
 ilFPG.Clear;
 lvFPG.Items.Clear;

 ilFPG.Width  := inifile_sizeof_icon;
 ilFPG.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to FPG_add_pos - 1 do
  FPG_images[count].bmp.PixelFormat := pf24bit;

 // Borramos la paleta creada ya que se va ha convertir a 16 bits
 if FPG_type = FPG8_DIV2 then
 begin
  DeleteObject(FPG_hpal);
  FPG_hpal := 0;

  for count:= 1 to FPG_add_pos - 1 do
  begin
   DeleteObject(FPG_images[count].bmp.Palette);
   FPG_images[count].bmp.Palette := 0;
  end;
 end;

 for count:= 1 to FPG_add_pos - 1 do
 begin
  with FPG_images[count] do
  begin
   lazBMP:=TLazIntfImage.Create(0,0);
   lazBMP.LoadFromBitmap(bmp.Handle,bmp.MaskHandle);
   // Tipo antiguo
   if FPG_type = FPG16_CDIV then
    for j := 0 to bmp.Height - 1 do
    begin
     rgbLine := lazBMP.GetDataLineStart(j);

     for i := 0 to bmp.Width - 1  do
      if( (rgbLine^[i].R >= 248) and (rgbLine^[i].G = 0) and (rgbLine^[i].B >= 248) ) then
      begin
       rgbLine^[i].R := 0;
       rgbLine^[i].G := 0;
       rgbLine^[i].B := 0;
      end;
    end;

   // Tipo nuevo
   if New_type = FPG16_CDIV then
    for j := 0 to bmp.Height - 1 do
    begin
     rgbLine := lazBMP.GetDataLineStart(j);

     for i := 0 to bmp.Width - 1  do
      if( (rgbLine^[i].R = 0) and (rgbLine^[i].G = 0) and (rgbLine^[i].B = 0) ) then
      begin
       rgbLine^[i].R := 248;
       rgbLine^[i].G := 0;
       rgbLine^[i].B := 248;
      end;
    end;

   if New_type <> FPG8_DIV2 then
    lvFPG_add_items(count, lvFPG, ilFPG);

   lazBMP.CreateBitmaps(imgHandle,imgMaskHandle,false);
   bmp.handle:=imgHandle;
   bmp.maskhandle:=imgMaskHandle;
   lazBMP.free;

  end;

  gFPG.Position:= (count * 100) div (FPG_add_pos - 1);
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure Convert_to_FPG16_FENIX(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
begin
 New_type := FPG16;

 Convert_to_FPG16( ilFPG, lvFPG, frmMain, gFPG);

 // Actualizamos los datos del FPG
 FPG_type             := FPG16;
 FPG_header.file_type := 'f16';
 FPG_load_palette     := false;
 FPG_update := true;
end;

procedure Convert_to_FPG16_CDIV(var ilFPG : TImageList; var lvFPG: TListView; var frmMain: TForm; var gFPG: TProgressBar);
begin
 New_type := FPG16_CDIV;

 Convert_to_FPG16( ilFPG, lvFPG, frmMain, gFPG);

 // Actualizamos los datos del FPG
 FPG_type             := FPG16_CDIV;
 FPG_header.file_type := 'c16';
 FPG_load_palette     := false;
 FPG_update := true;
end;



end.
