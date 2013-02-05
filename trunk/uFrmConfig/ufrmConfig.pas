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

unit ufrmConfig;


interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, ComCtrls, {Tabnotbk,} uinifile, Dialogs, uLanguage, uFrmMessageBox,
  ExtCtrls, Spin, ColorBox;

type

  { TfrmConfig }

  TfrmConfig = class(TForm)
    bbAcept: TBitBtn;
    bbCancel: TBitBtn;
    cbbgcolor: TColorBox;
    cbbgcolorFPG: TColorBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog: TOpenDialog;
    pcConfig: TPageControl;
    tsEnviroment: TTabSheet;
    gbImageEdit: TGroupBox;
    edProgram: TEdit;
    bbLocateFile: TBitBtn;
    gbLanguaje: TGroupBox;
    edLanguage: TEdit;
    bbLanguaje: TBitBtn;
    gbEnviroment: TGroupBox;
    cbAutoloadImages: TCheckBox;
    cbFlat: TCheckBox;
    cbSplash: TCheckBox;
    lbSizeOfIcon: TLabel;
    seSizeOfIcon: TSpinEdit;
    lbPixels: TLabel;
    gbTimeAnimate: TGroupBox;
    lbMiliseconds: TLabel;
    seAnimateDelay: TSpinEdit;
    cbAutoloadRemove: TCheckBox;
    cbAlfaNegro: TCheckBox;
    procedure edSizeIconKeyPress(Sender: TObject; var Key: Char);
    procedure bbAceptClick(Sender: TObject);
    procedure bbLocateFileClick(Sender: TObject);
    procedure bbLanguajeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure lbcolorClick(Sender: TObject);
    procedure seSizeOfIconEnter(Sender: TObject);
    procedure seSizeOfIconExit(Sender: TObject);
    procedure seAnimateDelayEnter(Sender: TObject);
    procedure seAnimateDelayExit(Sender: TObject);
    procedure edProgramEnter(Sender: TObject);
    procedure edProgramExit(Sender: TObject);
    procedure edLanguageEnter(Sender: TObject);
    procedure edLanguageExit(Sender: TObject);
  private
    { Private declarations }
    _lng_str : string;

    procedure _set_lng;
  public
    { Public declarations }
   //strinifile : string;
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.lfm}

procedure TfrmConfig._set_lng;
begin
 if _lng_str = inifile_language then
  Exit;

 _lng_str := inifile_language;

 frmConfig.Caption := LNG_STRINGS[84];
 tsEnviroment.Caption := LNG_STRINGS[85];
 gbEnviroment.Caption := LNG_STRINGS[85];

 lbSizeOfIcon.Caption := LNG_STRINGS[88];
 lbPixels.Caption := LNG_STRINGS[89];
 gbTimeAnimate.Caption := LNG_STRINGS[90];
 lbMiliseconds.Caption := LNG_STRINGS[91];
 bbAcept.Caption := LNG_STRINGS[93];
 bbCancel.Caption := LNG_STRINGS[94];
 gbImageEdit.Caption := LNG_STRINGS[86];
// bbLocateFile.Caption := LNG_STRINGS[95];
 gbLanguaje.Caption := LNG_STRINGS[87];
// bbLanguaje.Caption := LNG_STRINGS[96];

 cbAutoLoadImages.Caption := LNG_STRINGS[92];
 cbAutoLoadRemove.Caption := LNG_STRINGS[161];
 cbFlat.Caption := LNG_STRINGS[159];
 cbSplash.Caption := LNG_STRINGS[160];
end;

procedure TfrmConfig.edSizeIconKeyPress(Sender: TObject; var Key: Char);
begin
 case key of
  '0' .. '9', chr(8): begin end;
 else
  key := chr(13);
 end;
end;

procedure TfrmConfig.bbAceptClick(Sender: TObject);
begin
 inifile_sizeof_icon     := seSizeOfIcon.Value;
 inifile_program_edit    := edProgram.Text;
 inifile_animate_delay   := seAnimateDelay.Value;
 inifile_autoload_images := cbAutoLoadImages.Checked;
 inifile_autoload_remove := cbAutoLoadRemove.Checked;
 inifile_language        := edLanguage.Text;
 inifile_show_flat       := cbFlat.Checked;
 inifile_show_splash     := cbSplash.Checked;
 inifile_bg_color     := cbbgcolor.Selected;
 inifile_bg_colorFPG     := cbbgcolorFPG.Selected;

 write_inifile;

 load_language;

 frmConfig.ModalResult := mrYes;
end;

procedure TfrmConfig.bbLocateFileClick(Sender: TObject);
begin
 OpenDialog.Filter := 'EXE|*.EXE|(*.*)|*.*';
 if OpenDialog.Execute then
  edProgram.Text := OpenDialog.FileName;
end;


procedure TfrmConfig.bbLanguajeClick(Sender: TObject);
var
 temp : string;
begin
 OpenDialog.Filter := 'INI|*.INI|(*.*)|*.*';
 OpenDialog.InitialDir := ExtractFileDir(Application.ExeName) + DirectorySeparator+'lng';
 
 if OpenDialog.Execute then
 begin
  temp := inifile_language;

  inifile_language := OpenDialog.FileName;
  load_lnginfo;

  if ((LNG_INF = 'NULL') or (LNG_DESCRIPTION = 'NULL')) then
  begin
   inifile_language := temp;
   feMessageBox( LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_FILE_LANGUAGE_INCORRECT], 0, 0);
   Exit;
  end;

  feMessageBox( LNG_STRINGS[LNG_INFO], LNG_DESCRIPTION + #13#10 + LNG_INF, 0, 0);

  edLanguage.Text := OpenDialog.FileName;
 end;
end;

procedure TfrmConfig.FormActivate(Sender: TObject);
begin
 _set_lng;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin

end;

procedure TfrmConfig.GroupBox1Click(Sender: TObject);
begin

end;

procedure TfrmConfig.Label1Click(Sender: TObject);
begin

end;

procedure TfrmConfig.lbcolorClick(Sender: TObject);
begin

end;

procedure TfrmConfig.seSizeOfIconEnter(Sender: TObject);
begin
 seSizeOfIcon.Color := clWhite;
end;

procedure TfrmConfig.seSizeOfIconExit(Sender: TObject);
begin
 seSizeOfIcon.Color := clMedGray;
end;

procedure TfrmConfig.seAnimateDelayEnter(Sender: TObject);
begin
 seAnimateDelay.Color := clWhite;
end;

procedure TfrmConfig.seAnimateDelayExit(Sender: TObject);
begin
 seAnimateDelay.Color := clMedGray;
end;

procedure TfrmConfig.edProgramEnter(Sender: TObject);
begin
 edProgram.Color := clWhite;
end;

procedure TfrmConfig.edProgramExit(Sender: TObject);
begin
 edProgram.Color := clMedGray;
end;

procedure TfrmConfig.edLanguageEnter(Sender: TObject);
begin
 edLanguage.Color := clWhite;
end;

procedure TfrmConfig.edLanguageExit(Sender: TObject);
begin
 edLanguage.Color := clMedGray;
end;

end.
