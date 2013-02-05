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

unit uListViewFPG;


interface

uses LCLIntf, LCLType,  ComCtrls, Graphics, Controls, SysUtils, Classes,
     ClipBrd, Forms, Dialogs,
     uLanguage, uFPG, uTools, uIniFile,
      uLoadImage, uColor16bits, uFrmMessageBox ,IntfGraphics;

 procedure lvFPG_Insert_Images(lImages : TStringList; dir : string; var frmMain: TForm;
                            var ilFPG: TImageList; var lvFPG : TListView; var gFPG : TProgressBar);

 procedure lvFPG_Insert_Imagescb(var ilFPG: TImageList; var lvFPG : TListView; var frmMain : TForm; var gFPG : TProgressBar);

 procedure lvFPG_Load_Images(var ilFPG: TImageList; var lvFPG: TListView; var frmMain: TForm; var progressBar: TProgressBar);

 procedure lvFPG_add_bitmap( index : LongInt; name, description : String; var bmp_src: TBitmap );
 procedure lvFPG_add_items( index : Word; var lvFPG: TListView; var ilFPG: TImageList);
 procedure lvFPG_replace_bitmap( index : LongInt; name, description : String; var bmp_src: TBitmap );
 procedure lvFPG_replace_item( index : Word; var lvFPG: TListView; var ilFPG: TImageList);

implementation

procedure lvFPG_Load_Images(var ilFPG: TImageList; var lvFPG: TListView; var frmMain: TForm; var progressBar: TProgressBar);
var
 count   : Integer;
begin
 //Limpiamos la lista de imagenes
 ilFPG.Clear;
 lvFPG.Items.Clear;

 ilFPG.Width  := inifile_sizeof_icon;
 ilFPG.Height := inifile_sizeof_icon;

 progressBar.Position := 0;
 progressBar.Show;
 progressBar.Repaint;
 for count:= 1 to FPG_add_pos - 1 do
 begin
  with FPG_images[count] do
  begin
   lvFPG_add_items(count, lvFPG, ilFPG);
   if (count mod inifile_repaint_number) = 0 then
   begin
    progressBar.Position:= (count * 100) div (FPG_add_pos - 1);
    progressBar.Repaint;
   end;
  end;
 end;

 progressBar.Hide;
end;


// Añadir index
procedure lvFPG_add_bitmap( index : LongInt; name, description : String; var bmp_src: TBitmap );
var
 j, k    : LongInt;
 pDst : pRGBLine;
 lazBMP: TLazIntfImage;
  ImgHandle,ImgMaskHandle: HBitmap;

begin
  // Establece el código
  FPG_images[index].graph_code  := FPG_last_code;

  // Se establecen los datos de la imagen
  stringToArray(FPG_images[index].fpname,name,12);
  stringToArray(FPG_images[index].name,description,32);
  FPG_images[index].width  := bmp_src.Width;
  FPG_images[index].height := bmp_src.Height;
  FPG_images[index].points := 0;

  // Se crea la imagen resultante
  FPG_images[index].bmp    := TBitMap.Create;

  if FPG_type <> FPG32 then
    FPG_images[index].bmp.PixelFormat:=pf24bit
  else
    FPG_images[index].bmp.PixelFormat:=pf32bit;

  FPG_images[index].bmp.SetSize(bmp_src.Width, bmp_src.Height);

  CopyPixels(FPG_images[index].bmp,bmp_src,0,0);
  case FPG_type of
     FPG1:
     begin
           simulate1bppIn24bpp(FPG_images[index].bmp);
     end;
     FPG8_DIV2:
     begin
           simulate8bppIn24bpp(FPG_images[index].bmp);
     end;(*
     FPG16, FPG16_CDIV:
     begin
           simulate16bppIn24bpp(FPG_images[index].bmp);
     end;*)
  end;

  if FPG_type <> FPG32 then
  begin
   if FPG_type = FPG16_CDIV then
      FPG_images[index].bmp.TransparentColor:=clFuchsia;
   if (FPG_type = FPG16) OR (FPG_type = FPG24) then
      FPG_images[index].bmp.TransparentColor:=clBlack;
   if FPG_type = FPG8_DIV2 then
      FPG_images[index].bmp.TransparentColor:=RGBToColor(FPG_Header.palette[0],FPG_Header.palette[1],FPG_Header.palette[2]);
   FPG_images[index].bmp.Transparent:=true;
  end;

end;

// Añadir index
procedure lvFPG_replace_bitmap( index : LongInt; name, description : String; var bmp_src: TBitmap );
var
 j, k    : LongInt;
 pDst : pRGBLine;
 lazBMP: TLazIntfImage;
 ImgHandle,ImgMaskHandle: HBitmap;

begin
  // Establece el código
  FPG_images[index].graph_code  := FPG_last_code;

  // Se establecen los datos de la imagen
  stringToArray(FPG_images[index].fpname,name,12);
  stringToArray(FPG_images[index].name,description,32);
  FPG_images[index].width  := bmp_src.Width;
  FPG_images[index].height := bmp_src.Height;

  //FPG_images[index].points := 0;

  // Se crea la imagen resultante
  FPG_images[index].bmp    := TBitMap.Create;

  if FPG_type <> FPG32 then
    FPG_images[index].bmp.PixelFormat:=pf24bit
  else
    FPG_images[index].bmp.PixelFormat:=pf32bit;

  FPG_images[index].bmp.SetSize(bmp_src.Width, bmp_src.Height);

  CopyPixels(FPG_images[index].bmp,bmp_src,0,0);
  case FPG_type of
     FPG1:
     begin
           simulate1bppIn24bpp(FPG_images[index].bmp);
     end;
     FPG8_DIV2:
     begin
           simulate8bppIn24bpp(FPG_images[index].bmp);
     end;(*
     FPG16, FPG16_CDIV:
     begin
           simulate16bppIn24bpp(FPG_images[index].bmp);
     end;*)
  end;

    if FPG_type <> FPG32 then
    begin
     if FPG_type = FPG16_CDIV then
        FPG_images[index].bmp.TransparentColor:=clFuchsia;
     if (FPG_type = FPG16) OR (FPG_type = FPG24) then
        FPG_images[index].bmp.TransparentColor:=clBlack;
     if FPG_type = FPG8_DIV2 then
        FPG_images[index].bmp.TransparentColor:=RGBToColor(FPG_Header.palette[0],FPG_Header.palette[1],FPG_Header.palette[2]);
     FPG_images[index].bmp.Transparent:=true;
    end;

end;

procedure lvFPG_Insert_Images(lImages : TStringList; dir : string; var frmMain: TForm;
                            var ilFPG: TImageList; var lvFPG : TListView; var gFPG : TProgressBar);
var
 i : Integer;
 bmp_src  : TBitmap;
 file_source, filename : string;
 index : word;
begin
 // Creamos el bitmap fuente y destino
 bmp_src := TBitmap.Create;
 // Se inializa la barra de progresión
 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;


 for i := 0 to lImages.Count - 1 do
 begin

  index:=indexOfCode( FPG_last_code);
  if index<>0 then
  begin
   if MessageDlg('El código: '+intToStr(FPG_last_code)+' ya existe. ¿Desea sobrescribirlo?',mtConfirmation,[mbYes,mbNo],0) = mrNo then
         continue;
  end;

  filename := lImages.Strings[i];

  // Se prepara la ruta del fichero
  file_source := prepare_file_source(Dir, filename);

  // Se carga la imagen
  loadImageFile(bmp_src, file_source);

  (*
  // Se incrementa el código de la imagen
  FPG_last_code := FPG_last_code + 1;

  // Busca hasta que encuentre un código libre
  while CodeExists(FPG_last_code) do
    FPG_last_code := FPG_last_code + 1;
  *)

  // ver como meter fpgedit2009
  if index<>0 then
  begin
   lvFPG_replace_bitmap( index, ChangeFileExt(filename,''), ChangeFileExt(filename,''), bmp_src );
   lvFPG_replace_item( index, lvFPG, ilFPG);
  end else begin
      lvFPG_add_bitmap( FPG_add_pos, ChangeFileExt(filename,''), ChangeFileExt(filename,''), bmp_src );
      lvFPG_add_items( FPG_add_pos, lvFPG, ilFPG);
  end;

  FPG_add_pos := FPG_add_pos + 1;
  FPG_last_code := FPG_last_code + 1;

  //bmp_src.FreeImage;
  gFPG.Position:= ((i+1) * 100) div lImages.Count;
  gFPG.Repaint;

 end;
 FPG_last_code := FPG_last_code - 1;
 bmp_src.Free;
 FPG_update := true;
 lvFPG.Repaint;
 gFPG.Hide;
end;

procedure lvFPG_Insert_Imagescb(var ilFPG: TImageList; var lvFPG : TListView; var frmMain : TForm; var gFPG : TProgressBar);
var
 bmp_src : TBitmap;
begin
 // Se inializa la barra de progresión
 gFPG.Position := 50;
 gFPG.Show;
 gFPG.Repaint;

 bmp_src := TBitmap.Create;
 bmp_src.PixelFormat := pf32bit;

 try
   bmp_src.LoadFromClipBoardFormat( cf_BitMap);
 except
   bmp_src.Destroy;
   gFPG.Hide;
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_CLIPBOARD_IMAGE], 0, 0);
   Exit;
 end;

 ilFPG.Width  := inifile_sizeof_icon;
 ilFPG.Height := inifile_sizeof_icon;

 // Se incrementa el código de la imagen
  FPG_last_code := FPG_last_code + 1;

  // Busca hasta que encuentre un código libre
  while CodeExists(FPG_last_code) do
   FPG_last_code := FPG_last_code + 1;

  // ver como meter fpgedit2009
 lvFPG_add_bitmap( FPG_add_pos, 'ClipBoard', 'ClipBoard', bmp_src );
 lvFPG_add_items( FPG_add_pos, lvFPG, ilFPG);

 FPG_add_pos := FPG_add_pos + 1;

 gFPG.Hide;

 bmp_src.Destroy;

 FPG_update := true;
end;

procedure lvFPG_add_items( index : Word; var lvFPG: TListView; var ilFPG: TImageList);
var
 list_bmp : TListItem;
 bmp_dst: TBitMap;
 color : TColor;
begin

 // Pintamos el icono
 DrawProportional(FPG_images[index].bmp, bmp_dst, lvFPG.color);

 list_bmp := lvFPG.Items.Add;

 list_bmp.ImageIndex := ilFPG.add(bmp_dst, nil);

 // Se establece el código del FPG
 list_bmp.Caption := NumberTo3Char( FPG_images[index].graph_code );

 // Se añaden los datos de la imagen a la lista
 list_bmp.SubItems.Add(FPG_images[index].fpname);
 list_bmp.SubItems.Add(FPG_images[index].name);

 list_bmp.SubItems.Add(IntToStr(FPG_images[index].width));
 list_bmp.SubItems.Add(IntToStr(FPG_images[index].height));
 list_bmp.SubItems.Add(IntToStr(FPG_images[index].points));

end;

procedure lvFPG_replace_item( index : Word; var lvFPG: TListView; var ilFPG: TImageList);
var
 list_bmp : TListItem;
 bmp_dst: TBitMap;
 color : TColor;
begin

 // Pintamos el icono
 DrawProportional(FPG_images[index].bmp, bmp_dst, lvFPG.color);

 list_bmp := lvFPG.Items.Item[index -1];

 ilFPG.Replace(index-1, bmp_dst, Nil);
 //list_bmp.ImageIndex :=

 // Se añaden los datos de la imagen a la lista
 list_bmp.SubItems.Strings[0]:=FPG_images[index].fpname;
 list_bmp.SubItems.Strings[1]:=FPG_images[index].name;

 list_bmp.SubItems.Strings[2]:=IntToStr(FPG_images[index].width);
 list_bmp.SubItems.Strings[3]:=IntToStr(FPG_images[index].height);
// list_bmp.SubItems.Strings[4]:=IntToStr(FPG_images[index].points);

end;

end.
