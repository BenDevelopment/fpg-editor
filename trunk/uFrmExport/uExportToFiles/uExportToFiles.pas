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

unit uExportToFiles;

interface

uses LCLIntf, LCLType, ComCtrls, Forms, {Gauges,} Graphics, Controls, SysUtils, Classes,
     ClipBrd, FileUtil,
     uLanguage, uFPG, uPAL, uIniFile,
     uFrmMessageBox,
     //inserted by me
     uFrmExport {,GraphicEx};

 procedure export_to_bmp( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
 procedure export_to_png( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
 procedure export_to_map( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );

 procedure export_DIV2_PAL( path: string );
 procedure export_MS_PAL  ( path: string );
 procedure export_PSP_PAL ( path: string );

 procedure export_control_points( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );

implementation

procedure export_control_points( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 f : TextFile;
 i, j, k, icount: integer;
begin
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;


 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  for j := 0 to FPG_add_pos - 1 do
   if FPG_images[j].graph_code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    if FPG_images[j].points <= 0 then
     continue;

    try
     AssignFile(f, path + lvFPG.Items.Item[i].Caption + '.cpt');
     Rewrite(f);
    except
     feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_OPEN_FILE], 0, 0 );
     Exit;
    end;

    WriteLn(f, 'CTRL-PTS');

    WriteLn(f, FPG_images[j].points);

    for k := 0 to FPG_images[j].points - 1 do
    begin
     Write(f, FPG_images[j].control_points[k*2]); Write(f, ' ');
     WriteLn(f, FPG_images[j].control_points[(k*2) + 1]);
    end;

    CloseFile(f);

    break;
   end;

   gFPG.Position := (icount * 100) div lvFPG.SelCount;
   gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure export_to_bmp( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 i, j, icount : integer;
 imageName :String;
begin
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  case frmExport.rgFilename.ItemIndex of
   0: imageName:= lvFPG.Items.Item[i].Caption;
   1: imageName:= lvFPG.Items.Item[i].SubItems[0];
   2: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[0] +')';
  end;

  for j := 0 to FPG_add_pos - 1 do
   if FPG_images[j].graph_code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    //Se comprueba si existe el fichero
    if FileExistsUTF8(path + imagename + '.bmp') { *Converted from FileExists*  } then
    begin

     if feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_EXISTS_FILE_OVERWRITE], 4, 2) <> mrYes then
      break;
    end;

    FPG_images[j].bmp.SaveToFile(path + imagename + '.bmp');
    break;
   end;

  gFPG.Position := (icount * 100) div lvFPG.SelCount;
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure export_to_PNG( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 i, j, icount: integer;
 image :TPortableNetworkGraphic;
 imageName : String;
begin
 image := TPortableNetworkGraphic.Create;
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  case frmExport.rgFilename.ItemIndex of
   0: imageName:= lvFPG.Items.Item[i].Caption;
   1: imageName:= lvFPG.Items.Item[i].SubItems[0];
   2: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[0] +')';
   3: imageName:= lvFPG.Items.Item[i].SubItems[1];
   4: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[1] +')';
  end;

  for j := 0 to FPG_add_pos - 1 do
   if FPG_images[j].graph_code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    //Se comprueba si existe el fichero
    if FileExistsUTF8(path + imageName + '.png') { *Converted from FileExists*  } then
    begin
     if feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_EXISTS_FILE_OVERWRITE], 4, 2) <> mrYes then
      break;
    end;

    image.Assign(FPG_images[j].bmp);
    image.savetofile(path + imageName + '.png');

    break;
   end;

  gFPG.Position := (icount * 100) div lvFPG.SelCount;
  gFPG.Repaint;
 end;

 image.Destroy;
 gFPG.Hide;
end;


procedure export_to_map( lvFPG: TListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 i, j, icount : integer;
 imageName :String;
begin
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  case frmExport.rgFilename.ItemIndex of
   0: imageName:= lvFPG.Items.Item[i].Caption;
   1: imageName:= lvFPG.Items.Item[i].SubItems[0];
   2: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[0] +')';
  end;

  for j := 0 to FPG_add_pos - 1 do
   if FPG_images[j].graph_code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    //Se comprueba si existe el fichero
    if FileExistsUTF8(path + imagename + '.map') { *Converted from FileExists*  } then
    begin

     if feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_EXISTS_FILE_OVERWRITE], 4, 2) <> mrYes then
      break;
    end;

    //FPG_images[j].bmp.SaveToFile(path + imagename + '.map');
     MAP_Save(j,path + imagename + '.map');
    break;
   end;

  gFPG.Position := (icount * 100) div lvFPG.SelCount;
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure export_DIV2_PAL( path: string );
begin
 Save_DIV2_PAL( path + 'DIV2.pal' );
end;

procedure export_MS_PAL( path: string );
begin
 Save_MS_PAL( path + 'MS.pal' );
end;

procedure export_PSP_PAL( path: string );
begin
 Save_JASP_pal( path + 'PSP4.pal' );
end;

end.
