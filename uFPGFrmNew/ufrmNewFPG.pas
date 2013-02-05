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

unit ufrmNewFPG;


interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, Buttons, StdCtrls, uFPG, uPAL, uLanguage, uIniFile,
  uFrmMessageBox, Dialogs, FileUtil;

type
  TfrmNewFPG = class(TForm)
    gbName: TGroupBox;
    edNombre: TEdit;
    gbType: TGroupBox;
    cbTipoFPG: TComboBox;
    gbPalette: TGroupBox;
    btLoadPal: TButton;
    btViewPal: TButton;
    bbAceptar: TBitBtn;
    bbCancelar: TBitBtn;
    odPalette: TOpenDialog;
    procedure bbCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbTipoFPGChange(Sender: TObject);
    procedure bbAceptarClick(Sender: TObject);
    procedure btLoadPalClick(Sender: TObject);
    procedure btViewPalClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edNombreEnter(Sender: TObject);
    procedure edNombreExit(Sender: TObject);
    procedure cbTipoFPGEnter(Sender: TObject);
    procedure cbTipoFPGExit(Sender: TObject);
  private
    { Private declarations }
    _lng_str : string;

    procedure _set_lng;
  public
    { Public declarations }
  end;

var
  frmNewFPG: TfrmNewFPG;

implementation

uses ufrmPalette;

{$R *.lfm}

procedure TfrmNewFPG._set_lng;
begin
 if _lng_str = inifile_language then
  Exit;

 _lng_str := inifile_language;

 frmNewFPG.Caption := LNG_STRINGS[48] + ' ' + LNG_STRINGS[34];

 gbName.Caption := LNG_STRINGS[52];
 gbPalette.Caption := LNG_STRINGS[115];
 gbType.Caption := LNG_STRINGS[114];
 bbAceptar.Caption := LNG_STRINGS[93];
 bbCancelar.Caption := LNG_STRINGS[94];
 btLoadPal.Caption := LNG_STRINGS[116];
 btViewPal.Caption := LNG_STRINGS[117];
end;


procedure TfrmNewFPG.bbCancelarClick(Sender: TObject);
begin
 FPG_need_table := true;
 Hide;
end;

procedure TfrmNewFPG.FormShow(Sender: TObject);
begin
 cbTipoFPG.ItemIndex := 5;
 cbTipoFPGChange(Sender);
end;

procedure TfrmNewFPG.cbTipoFPGChange(Sender: TObject);
begin

 gbPalette.Visible := false;
 btLoadPal.Enabled := false;
 btViewPal.Enabled := false;

 if (cbTipoFPG.ItemIndex = 1) then
 begin
  btLoadPal.Enabled := true;
  gbPalette.Visible := true;
 end;

end;

procedure TfrmNewFPG.bbAceptarClick(Sender: TObject);
var
 i : integer;
 temp : string;
begin
 // Si no se cargo la paleta en un FPG de 8 bits
 if (cbTipoFPG.ItemIndex = 1) and (not FPG_load_palette) then
 begin
  feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOTLOAD_PALETTE], 0, 0);
  Exit;
 end;

 i := Length(edNombre.Text);

 temp := LowerCase(edNombre.Text);

 if((temp[i - 3] <> '.') or (temp[i - 2] <> 'f') or
    (temp[i - 1] <> 'p') or (temp[i] <> 'g')) then
  edNombre.Text := edNombre.Text + '.fpg';

 if FileExistsUTF8(edNombre.Text) { *Converted from FileExists*  } then
 begin
  feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_FILE_EXIST], 0, 0);
  Exit;
 end;

 FPG_type     := cbTipoFPG.ItemIndex;
 FPG_source   := edNombre.Text;
 FPG_active   := true;
 FPG_add_pos  := 1;
 FPG_last_code:= 0;

 FPG_header.fpg_code[0] := 26;
 FPG_header.fpg_code[1] := 13;
 FPG_header.fpg_code[2] := 10;
 FPG_header.fpg_code[3] := 0;
 FPG_header.version     := 0;

 case FPG_type of
  FPG1:
    FPG_header.file_type := 'f01';
  FPG8_DIV2:
    FPG_header.file_type := 'fpg';
  FPG16:
    FPG_header.file_type := 'f16';
  FPG16_CDIV:
    FPG_header.file_type := 'c16';
  FPG24:
    FPG_header.file_type := 'f24';
  FPG32:
    FPG_header.file_type := 'f32';
 end;

 ModalResult := mrOK;
 Hide;
end;

procedure TfrmNewFPG.btLoadPalClick(Sender: TObject);
begin
 if not odPalette.Execute then
  Exit;

 if not FileExistsUTF8(odPalette.FileName) then
 begin
  feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_FILE_NOTEXIST], 0, 0);
  Exit;
 end;

 if Load_PAL(odPalette.FileName) then
 begin
  FPG_load_palette  := true;
  btViewPal.Enabled := true;
 end
 else
 begin
  FPG_load_palette  := false;
  btViewPal.Enabled := false;
  Exit;
 end;

 // Crea la tabla de conversión de imagenes a 8 bits
 if FPG_load_palette then
  Create_FPG_table_16_to_8;
end;

procedure TfrmNewFPG.btViewPalClick(Sender: TObject);
begin
 frmPalette.ShowModal;
end;

procedure TfrmNewFPG.FormActivate(Sender: TObject);
begin
 _set_lng;
end;

procedure TfrmNewFPG.edNombreEnter(Sender: TObject);
begin
 edNombre.Color := clWhite;
end;

procedure TfrmNewFPG.edNombreExit(Sender: TObject);
begin
 edNombre.Color := clMedGray;
end;

procedure TfrmNewFPG.cbTipoFPGEnter(Sender: TObject);
begin
 cbTipoFPG.Color := clWhite;
end;

procedure TfrmNewFPG.cbTipoFPGExit(Sender: TObject);
begin
 cbTipoFPG.Color := clMedGray;
end;

end.
