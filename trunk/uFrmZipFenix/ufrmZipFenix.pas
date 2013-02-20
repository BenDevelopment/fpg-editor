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

unit ufrmZipFenix;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls,
  StdCtrls, Buttons, FileCtrl, ExtCtrls, FileUtil, uFPG, uLanguage, uTools,
  uFrmMessageBox, ShellCtrls;

type

  { TfrmZipFenix }

  TfrmZipFenix = class(TForm)
    bbCompress: TBitBtn;
    dlb: TShellTreeView;
    flb: TShellListView;
    imgAnimate: TImage;
    lbZipFile: TLabel;
    Panel1: TPanel;
    fcb: TFilterComboBox;
    Panel2: TPanel;
    Panel3: TPanel;
    pZip: TPanel;
    Splitter1: TSplitter;
    statusbar: TStatusBar;
    procedure dlbChange(Sender: TObject; Node: TTreeNode);
    procedure flbChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure flbClick(Sender: TObject);
    procedure bbCompressClick(Sender: TObject);
    procedure flbSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean
      );
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   old_file_size : Longint;
  end;

var
  frmZipFenix: TfrmZipFenix;

implementation

{$R *.lfm}

function FileExists(FileName: string): Boolean;

{ Boolean function that returns True if the file exists; otherwise,
  it returns False. Closes the file if it exists. }
var
  F: file;
begin
  {$I-}
  AssignFile(F, FileName);
  FileMode := 0;  { Set file access to read only }
  Reset(F);
  CloseFile(F);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

procedure TfrmZipFenix.flbClick(Sender: TObject);
var
 f : File of byte;
 filename : String;
begin
  if flb.Selected <> nil then
  begin
   filename:= flb.Root + DirectorySeparator+ flb.Selected.Caption;
   statusbar.Panels.Items[0].Text := filename;

   AssignFile(f, FileName);
   Reset(f);
   old_file_size := FileSize(FileName);
   CloseFile(f);

   statusbar.Panels.Items[1].Text := IntToStr(old_file_size) + ' Bytes';
   bbCompress.Enabled:=true;
  end else begin
   bbCompress.Enabled:=false;
  end;
end;

procedure TfrmZipFenix.flbChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  bbCompress.Enabled:=(flb.Selected <> nil);
end;

procedure TfrmZipFenix.dlbChange(Sender: TObject; Node: TTreeNode);
begin
   bbCompress.Enabled:=(flb.Selected <> nil);
end;


procedure TfrmZipFenix.bbCompressClick(Sender: TObject);
var
 temp_fpg_header : div_fpg_header;
 f : File of Byte;
 f1: TFileStream;
 is_fpg : Boolean;
 filename : String;
begin
 is_fpg := false;
 filename := flb.Root + DirectorySeparator+ flb.selected.caption;

 if flb.ItemIndex = -1 then
  Exit;

 if not FileExists(FileName) then
  Exit;
(*
 f1 := TFileStream.Create(FileName, fmOpenRead);

 f1.Read(temp_fpg_header.file_type, 3);
 f1.Read(temp_fpg_header.fpg_code , 4);
 f1.Read(temp_fpg_header.version, 1);

 f1.free;

 //Ficheros de 8 bits para DIV2, FENIX
  if (temp_fpg_header.file_type[0] = 'f') and (temp_fpg_header.file_type[1] = 'p') and
     (temp_fpg_header.file_type[2] = 'g') and (temp_fpg_header.fpg_code [0] = 26 ) and
     (temp_fpg_header.fpg_code [1] = 13 ) and (temp_fpg_header.fpg_code [2] = 10 ) and
     (temp_fpg_header.fpg_code [3] = 0) then
   is_fpg := true;

 //Ficheros de 16 bits para FENIX
  if (temp_fpg_header.file_type[0] = 'f') and (temp_fpg_header.file_type[1] = '1') and
     (temp_fpg_header.file_type[2] = '6') and (temp_fpg_header.fpg_code [0] = 26 ) and
     (temp_fpg_header.fpg_code [1] = 13 ) and (temp_fpg_header.fpg_code [2] = 10 ) and
     (temp_fpg_header.fpg_code [3] = 0) then
   is_fpg := true;

    //Ficheros de 32 bits para BenuGD
  if (temp_fpg_header.file_type[0] = 'f') and (temp_fpg_header.file_type[1] = '2') and
     (temp_fpg_header.file_type[2] = '4') and (temp_fpg_header.fpg_code [0] = 26 ) and
     (temp_fpg_header.fpg_code [1] = 13 ) and (temp_fpg_header.fpg_code [2] = 10 ) and
     (temp_fpg_header.fpg_code [3] = 0) then
   is_fpg := true;
    //Ficheros de 32 bits para BenuGD
  if (temp_fpg_header.file_type[0] = 'f') and (temp_fpg_header.file_type[1] = '3') and
     (temp_fpg_header.file_type[2] = '2') and (temp_fpg_header.fpg_code [0] = 26 ) and
     (temp_fpg_header.fpg_code [1] = 13 ) and (temp_fpg_header.fpg_code [2] = 10 ) and
     (temp_fpg_header.fpg_code [3] = 0) then
   is_fpg := true;

 if not is_fpg then
 begin
  feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOTFPG], 0, 0);
  Exit;
 end; *)

 pZip.Visible := true;

 {$IFDEF WINDOWS}
   RunExe(ExtractFileDir(Application.ExeName) + DirectorySeparator+'zlib'+DirectorySeparator+'zlib.exe -6 "'+ FileName + '"', GetTempDir(False)  );
 {$ENDIF}

 {$IFDEF Linux}
   RunExe('/bin/gzip -nc "'+ FileName + '"', GetTempDir(False),FileName +'.gz' );
 {$ENDIF}


 f1 := TFileStream.Create(FileName + '.gz', fmOpenRead);

 old_file_size := f1.Size;
 f1.free;

 AssignFile(f, FileName);
 Erase(f);

 RenameFileUTF8(FileName + '.gz',FileName); { *Converted from RenameFile*  }

 statusbar.Panels.Items[1].Text := IntToStr(old_file_size) + ' Bytes';

 pZip.Visible := False;
end;

procedure TfrmZipFenix.flbSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
    if not Selected then
      exit;
    bbCompress.Enabled:=(flb.Selected <> nil);
end;

procedure TfrmZipFenix.FormActivate(Sender: TObject);
begin
 frmZipFenix.Caption := LNG_STRINGS[125];
 lbZipFile.Caption   := LNG_STRINGS[123];
 bbCompress.Caption  := LNG_STRINGS[124];
 flb.Mask:='*.fpg';
end;

end.
