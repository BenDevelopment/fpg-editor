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

unit uFrmMain;

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls,
  StdCtrls, ExtCtrls, Menus, Buttons, ClipBrd, uIniFile, ufrmView, uFPG,
  ufrmNewFPG, ufrmPalette, ufrmFPGImages, uLanguage, Dialogs, uTools,
  uFPGConvert, uLoadImage, uFrmExport, uFrmInputBox, uFrmMessageBox,
  uExportToFiles, uListViewFPG, FileUtil, ShellCtrls, ActnList, FileCtrl, Spin,
  types, uFrmZipFenix, ufrmMainFNT, uFrmAbout;

const
  DRAG_LVFPG    = 0;
  DRAG_LVIMAGES = 1;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    aAddImg: TAction;
    aConfig: TAction;
    aAbout: TAction;
    aCopyImg: TAction;
    aAnimImgs: TAction;
    aBennu: TAction;
    aCDiv: TAction;
    aAnimFPG: TAction;
    aFPG1: TAction;
    aFPG32: TAction;
    aFPG24: TAction;
    aReplazeImg: TAction;
    aFPG16f: TAction;
    aFPG16c: TAction;
    aFPG8: TAction;
    aOpenImg: TAction;
    aDIV2: TAction;
    aFenix: TAction;
    aGemix: TAction;
    aImgDetails: TAction;
    aImgList: TAction;
    aImgImages: TAction;
    aInvertSelImgs: TAction;
    aSelectAllImgs: TAction;
    aDeleteSelImg: TAction;
    aReload: TAction;
    aEditSelImg: TAction;
    aHideShowDirs: TAction;
    Action2: TAction;
    aInvertSel: TAction;
    aSelectAll: TAction;
    aEmpty: TAction;
    aPasteImg: TAction;
    aDelete: TAction;
    aExport: TAction;
    aEditSel: TAction;
    aFPGPalette: TAction;
    aFPGDetails: TAction;
    aFPGList: TAction;
    aFPGImages: TAction;
    aHideShowUpPanel: TAction;
    aSaveAs: TAction;
    aSave: TAction;
    aOpen: TAction;
    aExit: TAction;
    aNew: TAction;
    aZipTool: TAction;
    aFNTmaker: TAction;
    aClose: TAction;
    ActionList: TActionList;
    Bevel13: TBevel;
    miFPG1: TMenuItem;
    miFPG32: TMenuItem;
    miFPG24: TMenuItem;
    sbFilter: TSpeedButton;
    edFPGCODE: TSpinEdit;
    EFilter: TComboBox;
    gbFPG: TGroupBox;
    ilMenu: TImageList;
    lvFPG: TListView;
    lvImages: TListView;
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    miFPG16f: TMenuItem;
    miFPG16c: TMenuItem;
    mifpg8: TMenuItem;
    miConvert: TMenuItem;
    miSeparator11: TMenuItem;
    miDIV2: TMenuItem;
    miCDiv: TMenuItem;
    miFenix: TMenuItem;
    miGemix: TMenuItem;
    miBennu: TMenuItem;
    miInvertSelImgs: TMenuItem;
    miSelectAllImgs: TMenuItem;
    miSeparator10: TMenuItem;
    miDeleteSel: TMenuItem;
    miReload: TMenuItem;
    miEditSelImg: TMenuItem;
    miSeparator9: TMenuItem;
    miAnimImgs: TMenuItem;
    miSeparator8: TMenuItem;
    miImgDetails: TMenuItem;
    miImgList: TMenuItem;
    miImgImages: TMenuItem;
    miViewImg: TMenuItem;
    miSeparator7: TMenuItem;
    miSeparator6: TMenuItem;
    miEmptyImg: TMenuItem;
    miPasteImg: TMenuItem;
    miCopyImg: TMenuItem;
    miWallpaper: TMenuItem;
    miSeparator5: TMenuItem;
    miInverSel: TMenuItem;
    miEditSel: TMenuItem;
    miAddImgs: TMenuItem;
    miSeparator4: TMenuItem;
    miFPGPal: TMenuItem;
    miSeparator3: TMenuItem;
    miFPGDetails: TMenuItem;
    miFPGList: TMenuItem;
    miFPGImages: TMenuItem;
    miViewFPG: TMenuItem;
    miSeparator2: TMenuItem;
    miShowHideUPPanel: TMenuItem;
    miSeparator1: TMenuItem;
    miOpen: TMenuItem;
    miHideShowDirs: TMenuItem;
    miImages: TMenuItem;
    miNew: TMenuItem;
    miAbout: TMenuItem;
    miHelp: TMenuItem;
    miConfig: TMenuItem;
    miFNTmaker: TMenuItem;
    miZip: TMenuItem;
    miTools: TMenuItem;
    miSalir: TMenuItem;
    miFPG: TMenuItem;
    pFPGCODE: TPanel;
    sbFPGEdit: TStatusBar;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    tbFPG: TToolBar;
    ilImages: TImageList;
    sbFPGSaveAs: TSpeedButton;
    sbFPGNew: TSpeedButton;
    sbFPGOpen: TSpeedButton;
    sbFPGSave: TSpeedButton;
    Bevel1: TBevel;
    sbFPGAnimate: TSpeedButton;
    sbFPGReport: TSpeedButton;
    sbFPGList: TSpeedButton;
    Bevel2: TBevel;
    sbFPGEditBMP: TSpeedButton;
    sbFPGAdd: TSpeedButton;
    gbImages: TGroupBox;
    panelDirs: TPanel;
    pImagesList: TPanel;
    tbImages: TToolBar;
    sbImagesIcon: TSpeedButton;
    sbImagesList: TSpeedButton;
    sbImagesReport: TSpeedButton;
    spDiv: TSplitter;
    sbImagesViewDir: TSpeedButton;
    Bevel3: TBevel;
    sbFPGIcon: TSpeedButton;
    Bevel4: TBevel;
    sbFPGViewFrame: TSpeedButton;
    Bevel5: TBevel;
    ppImages: TPopupMenu;
    ppOpenImage: TMenuItem;
    ppEditImage: TMenuItem;
    ilFPG: TImageList;
    Bevel6: TBevel;
    sbImagesUpdate: TSpeedButton;
    sbImagesEdit: TSpeedButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ppFPGImages: TPopupMenu;
    ppFPGOpen: TMenuItem;
    MenuItem4: TMenuItem;
    ppFPGEdit: TMenuItem;
    ppFPGExport: TMenuItem;
    ppFPGRemove: TMenuItem;
    ppFPGAnimate: TMenuItem;
    N15: TMenuItem;
    ppCopyImage: TMenuItem;
    sbFPGExport: TSpeedButton;
    sbFPGRemove: TSpeedButton;
    sbImagesRemove: TSpeedButton;
    ppRemoveImages: TMenuItem;
    sbImagesAnimate: TSpeedButton;
    pbImages: TProgressBar;
    pbFPG: TProgressBar;
    Bevel8: TBevel;
    N20: TMenuItem;
    mmAniImg: TMenuItem;
    Bevel9: TBevel;
    Bevel10: TBevel;
    Bevel11: TBevel;
    Bevel12: TBevel;
    procedure aFPG16cExecute(Sender: TObject);
    procedure aFPG1Execute(Sender: TObject);
    procedure aFPG24Execute(Sender: TObject);
    procedure aFPG32Execute(Sender: TObject);
    procedure aFPG8Execute(Sender: TObject);
    procedure aFPG16fExecute(Sender: TObject);

    procedure aAboutExecute(Sender: TObject);
    procedure aAddImgExecute(Sender: TObject);
    procedure aAnimFPGExecute(Sender: TObject);
    procedure aAnimImgsExecute(Sender: TObject);
    procedure aBennuExecute(Sender: TObject);
    procedure aCDivExecute(Sender: TObject);
    procedure aConfigExecute(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
    procedure aDeleteSelImgExecute(Sender: TObject);
    procedure aDIV2Execute(Sender: TObject);
    procedure aEditSelExecute(Sender: TObject);
    procedure aEditSelImgExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aExportExecute(Sender: TObject);
    procedure aFenixExecute(Sender: TObject);
    procedure aFNTmakerExecute(Sender: TObject);
    procedure aFPGDetailsExecute(Sender: TObject);
    procedure aFPGImagesExecute(Sender: TObject);
    procedure aFPGListExecute(Sender: TObject);
    procedure aFPGPaletteExecute(Sender: TObject);
    procedure aGemixExecute(Sender: TObject);
    procedure aHideShowDirsExecute(Sender: TObject);
    procedure aHideShowUpPanelExecute(Sender: TObject);
    procedure aImgDetailsExecute(Sender: TObject);
    procedure aImgImagesExecute(Sender: TObject);
    procedure aImgListExecute(Sender: TObject);
    procedure aInvertSelExecute(Sender: TObject);
    procedure aInvertSelImgsExecute(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure aCloseExecute(Sender: TObject);
    procedure aOpenExecute(Sender: TObject);
    procedure aOpenImgExecute(Sender: TObject);
    procedure aReloadExecute(Sender: TObject);
    procedure aReplazeImgExecute(Sender: TObject);
    procedure aSaveAsExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure aSelectAllExecute(Sender: TObject);
    procedure aSelectAllImgsExecute(Sender: TObject);
    procedure aZipToolExecute(Sender: TObject);
    procedure sbFilterClick(Sender: TObject);
    procedure edFPGCODEChange(Sender: TObject);
    procedure EFilterKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure pbImagesContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lvImagesDblClick(Sender: TObject);
    procedure lvFPGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvFPGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvFPGDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvFPGMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure lvFPGKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ppImagesPopup(Sender: TObject);
    procedure ppFPGImagesPopup(Sender: TObject);
    procedure mmPasteImageClick(Sender: TObject);
    procedure mmCopyImageClick(Sender: TObject);
    procedure mmClearClipBoardClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
//    procedure sbImagesFilterClick(Sender: TObject);
    procedure sbFPGCODEClick(Sender: TObject);
    procedure edFPGCODEKeyPress(Sender: TObject; var Key: Char);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    _lng_str : string;
    sFilter  : string;

    procedure _set_lng;
    procedure _flat_buttons;
  public
    { Public declarations }

   old_sizeof_icon : longint;
   //DragOver : byte;
   QueryResult : longint;

   procedure lvFPG_Load_Bitmaps;
   procedure OpenFPG( sfile: string );

   procedure Update_Panels;

   procedure lvBMP_add_text;
   procedure lvBMP_add_icons;
  end;

var
  frmMain : TfrmMain;
  cancel_load_icons : Boolean = False;

implementation

uses ufrmAnimate, ufrmConfig, uFrmSplahs;

{$R *.lfm}

procedure TfrmMain._set_lng;
begin
 if _lng_str = inifile_language then
  Exit;

 _lng_str := inifile_language;

 miFPG.Caption := LNG_STRINGS[0];
 miNew.Caption := LNG_STRINGS[4];
 aExit.Caption := LNG_STRINGS[162];
 miTools.Caption := LNG_STRINGS[2];
 miHelp.Caption := LNG_STRINGS[3];
 aConfig.Caption := LNG_STRINGS[26];
 aZipTool.Caption := LNG_STRINGS[27];
 aClose.Caption := LNG_STRINGS[6];

 miOpen.Caption := LNG_STRINGS[5];
// miSave.Caption := LNG_STRINGS[7];
// miSaveAsFPG.Caption := LNG_STRINGS[8];
 miConvert.Caption := LNG_STRINGS[9];
 miShowHideUPPanel.Caption := LNG_STRINGS[10];
 miViewFPG.Caption := LNG_STRINGS[11];
 miFPGImages.Caption := LNG_STRINGS[12];
 miFPGList.Caption := LNG_STRINGS[13];
 miFPGDetails.Caption := LNG_STRINGS[14];
 miFPGPal.Caption := LNG_STRINGS[15];
 miAnimImgs.Caption := LNG_STRINGS[16];
 (*
 miFPGCCInsertImages.Caption := LNG_STRINGS[17];
 mmAddImages.Caption := LNG_STRINGS[18];
 mmEditImages.Caption := LNG_STRINGS[19];
 mmExportImages.Caption := LNG_STRINGS[20];
 mmRemoveImages.Caption := LNG_STRINGS[21];
 mmFPGSelectAll.Caption := LNG_STRINGS[22];
 mmFPGInvertSelect.Caption := LNG_STRINGS[23];
 mmImages.Caption := LNG_STRINGS[1];
 mmAnimateImg.Caption := LNG_STRINGS[16];
 mmAniImg.Caption := LNG_STRINGS[42];
 mmDeleteImages.Caption := LNG_STRINGS[21];
 mmImagesHideDir.Caption := LNG_STRINGS[24];
 mmViewImages.Caption := LNG_STRINGS[11];
 mmImagesViewIcon.Caption := LNG_STRINGS[12];
 mmImagesViewList.Caption := LNG_STRINGS[13];
 mmImagesViewReport.Caption := LNG_STRINGS[14];
 mmImagesEdit.Caption := LNG_STRINGS[19];
 mmImagesUpdate.Caption := LNG_STRINGS[25];
 mmImagesSelectAll.Caption := LNG_STRINGS[22];
 mmImagesInvertSelect.Caption := LNG_STRINGS[23];

 mmClipBoard.Caption := LNG_STRINGS[135];
 mmCopyImage.Caption := LNG_STRINGS[132];
 mmPasteImage.Caption := LNG_STRINGS[133];
 mmClearClipBoard.Caption := LNG_STRINGS[139];
 *)

 sbImagesEdit.Caption := LNG_STRINGS[29];
 sbImagesEdit.Hint := LNG_STRINGS[39];
 sbImagesUpdate.Caption := LNG_STRINGS[30];
 sbImagesUpdate.Hint := LNG_STRINGS[40];
 sbImagesAnimate.Caption := LNG_STRINGS[42];
 sbImagesAnimate.Hint := LNG_STRINGS[43];
 sbImagesIcon.Hint := LNG_STRINGS[36];
 sbImagesList.Hint := LNG_STRINGS[37];
 sbImagesReport.Hint := LNG_STRINGS[38];
 sbImagesRemove.Caption := LNG_STRINGS[33];
 sbImagesRemove.Hint := LNG_STRINGS[47];
 sbImagesViewDir.Hint := LNG_STRINGS[35];

 panelDirs.Caption := LNG_STRINGS[36];
 gbFPG.Caption := LNG_STRINGS[34];

 lvImages.Columns[0].Caption := LNG_STRINGS[52];
 lvImages.Columns[1].Caption := LNG_STRINGS[53];
 lvImages.Columns[2].Caption := LNG_STRINGS[54];

 lvFPG.Columns[0].Caption := LNG_STRINGS[55];
 lvFPG.Columns[1].Caption := LNG_STRINGS[52];
 lvFPG.Columns[2].Caption := LNG_STRINGS[56];
 lvFPG.Columns[3].Caption := LNG_STRINGS[53];
 lvFPG.Columns[4].Caption := LNG_STRINGS[54];
 lvFPG.Columns[5].Caption := LNG_STRINGS[57];

 sbFPGAdd.Caption := LNG_STRINGS[31];
 sbFPGAdd.Hint := LNG_STRINGS[44];
 sbFPGAnimate.Caption := LNG_STRINGS[42];
 sbFPGAnimate.Hint := LNG_STRINGS[43];
 sbFPGEditBMP.Caption := LNG_STRINGS[29];
 sbFPGEditBMP.Hint := LNG_STRINGS[45];
 sbFPGExport.Caption := LNG_STRINGS[32];
 sbFPGExport.Hint := LNG_STRINGS[46];
 sbFPGRemove.Caption := LNG_STRINGS[33];
 sbFPGRemove.Hint := LNG_STRINGS[47];
 sbFPGViewFrame.Hint := LNG_STRINGS[41];

 sbFPGIcon.Hint := LNG_STRINGS[36];
 sbFPGList.Hint := LNG_STRINGS[37];
 sbFPGReport.Hint := LNG_STRINGS[38];
 sbFPGNew.Hint := LNG_STRINGS[48];
 sbFPGOpen.Hint := LNG_STRINGS[49];
 sbFPGSave.Hint := LNG_STRINGS[50];
 sbFPGSaveAs.Hint := LNG_STRINGS[51];

 ppOpenImage.Caption := LNG_STRINGS[49];
 ppEditImage.Caption := LNG_STRINGS[29];
 ppFPGOpen.Caption := LNG_STRINGS[49];
 ppFPGAnimate.Caption := LNG_STRINGS[42];
 ppFPGEdit.Caption := LNG_STRINGS[29];
 ppFPGExport.Caption := LNG_STRINGS[32];
 ppFPGRemove.Caption := LNG_STRINGS[33];
 ppRemoveImages.Caption := LNG_STRINGS[33];
 ppCopyImage.Caption := LNG_STRINGS[136];

 pFPGCODE.Caption := LNG_STRINGS[153];
 edFPGCODE.Hint   := LNG_STRINGS[154];
// edImagesFilter.Hint := LNG_STRINGS[155];
end;


procedure TfrmMain.Update_Panels;
begin
  sbFPGEdit.Panels[0].Text := FPG_source;

  case FPG_type of
   FPG1:
    begin
     sbFPGEdit.Panels[1].Text := 'RGB(0, 0, 0)';
     sbFPGEdit.Panels[2].Text := STRFPG1;
    end;
   FPG8_DIV2:
    begin
     sbFPGEdit.Panels[1].Text := 'RGB(0, 0, 0)';
     sbFPGEdit.Panels[2].Text := STRFPG8;
    end;
   FPG16:
    begin
     sbFPGEdit.Panels[1].Text := 'RGB(0, 0, 0)';
     sbFPGEdit.Panels[2].Text := STRFPG16;
    end;
   FPG16_CDIV:
    begin
     sbFPGEdit.Panels[1].Text := 'RGB(255, 0, 255)';
     sbFPGEdit.Panels[2].Text := STRFPGCDIV16;
    end;
   FPG24:
    begin
     sbFPGEdit.Panels[1].Text := 'RGB(0, 0, 0)';
     sbFPGEdit.Panels[2].Text := STRFPG24;
    end;
   FPG32:
    begin
     sbFPGEdit.Panels[1].Text := 'Alpha Channel';
     sbFPGEdit.Panels[2].Text := STRFPG32;
    end;
  end;

  (*
  mmFPG8.Enabled       := (FPG_type <> FPG8_DIV2);
  mmFPG16FENIX.Enabled := (FPG_type <> FPG16);
  mmFPG16CDIV.Enabled  := (FPG_type <> FPG16_CDIV);

  mmFPG8.Checked       := not mmFPG8.Enabled;
  mmFPG16FENIX.Checked := not mmFPG16FENIX.Enabled;
  mmFPG16CDIV.Checked  := not mmFPG16CDIV.Enabled;

  mmCopyImage.Enabled  := true;
  mmPasteImage.Enabled := true;

  mmViewFPGPalette.Enabled := FPG_load_palette;
  *)
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
 if width  < 640 then width  := 640;
 if height < 480 then height := 480;
end;

procedure TfrmMain.pbImagesContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings);
begin
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   Strings.StrictDelimiter := true;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := Input;
end;



procedure TfrmMain.aAnimFPGExecute(Sender: TObject);
var
 i, j : integer;
begin
 //Debe seleccionar más de una imagen para hacer la animación
 if lvFPG.SelCount <= 1 then
 begin
  feMessageBox( LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_SELECT_MORE_IMAGES_FOR_ANIMATE], 0, 0);
  Exit;
 end;

 frmAnimate.ClientWidth := 0;
 frmAnimate.ClientHeight:= 0;
 frmAnimate.source := sFPG;

 //Ponemos las animaciones a nulo
 for i := 1 to 999 do
  frmAnimate.fpg_animate[i] := false;

 //Establecemos las imagenes para hacer la animación
 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  //Si no esta seleccionada continuamos el bucle
  if not lvFPG.Items.Item[i].Selected then
   continue;

  //Buscamos la imagen del FPG seleccionada
  for j := 0 to FPG_add_pos - 1 do
   if FPG_images[j].graph_code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    if FPG_images[j].bmp.width > frmAnimate.ClientWidth then
     frmAnimate.ClientWidth := FPG_images[j].bmp.width;

    if FPG_images[j].bmp.height > frmAnimate.ClientHeight then
     frmAnimate.ClientHeight := FPG_images[j].bmp.Height;

    frmAnimate.fpg_animate[j] := true;
   end;
 end;

 frmAnimate.Left := (Screen.Width - frmAnimate.Width) div 2;
 frmAnimate.Top  := (Screen.Height- frmAnimate.Height)div 2;
 frmAnimate.tAnimate.Interval := inifile_animate_delay;

 frmAnimate.Show;

end;

procedure TfrmMain.aAnimImgsExecute(Sender: TObject);
var
  i, j : integer;
 filename,
 file_source : string;
 bmp_src : TBitmap;
begin
 if lvImages.SelCount <= 1 then
 begin
  feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_SELECT_MORE_IMAGES_FOR_ANIMATE], 0, 0);
  Exit;
 end;

 bmp_src := TBitmap.Create;
 bmp_src.PixelFormat := pf32bit;

 frmAnimate.ClientWidth := 0;
 frmAnimate.ClientHeight:= 0;
 frmAnimate.source := sIMG;
 frmAnimate.num_of_images := lvImages.SelCount;
 j := 1;
 pbImages.Position := 0;
 pbImages.Show;
 pbImages.Repaint;


 for i := 0 to lvImages.Items.Count - 1 do
 begin
  if not lvImages.Items.Item[i].Selected then
   continue;

  filename := lvImages.Items.Item[i].Caption;

  // Se prepara la ruta del fichero
  file_source := prepare_file_source(ShellListView1.Root, filename);
  // Se carga la imagen
  loadImageFile(bmp_src, file_source);

  if bmp_src.width > frmAnimate.ClientWidth then
     frmAnimate.ClientWidth := bmp_src.width;

  if bmp_src.height > frmAnimate.ClientHeight then
     frmAnimate.ClientHeight := bmp_src.Height;

  frmAnimate.img_animate[j].bmp := TBitmap.Create;

  frmAnimate.img_animate[j].bmp.PixelFormat := pf32bit;

  frmAnimate.img_animate[j].bmp.SetSize(bmp_src.Width,bmp_src.Height);

  frmAnimate.img_animate[j].bmp.Canvas.Draw(0, 0, bmp_src);

  pbImages.Position := (j * 100) div lvImages.SelCount;
  pbImages.Repaint;

  j := j + 1;
 end;
 pbImages.Hide;

 frmAnimate.Left := (Screen.Width - frmAnimate.Width) div 2;
 frmAnimate.Top  := (Screen.Height- frmAnimate.Height)div 2;
 frmAnimate.tAnimate.Interval := inifile_animate_delay;

 frmAnimate.ShowModal;

 for i := 0 to frmAnimate.num_of_images - 1 do
  frmAnimate.img_animate[i].bmp.Destroy;

 bmp_src.Destroy;
 pbImages.Hide;

end;


procedure TfrmMain.aAboutExecute(Sender: TObject);
begin
    frmAbout.showModal;
end;

(*
procedure TfrmMain.aAddImgExecute(Sender: TObject);
var
 InputString : String;
 InputValue  : LongInt;
begin
 if lvFPG.visible then
 begin
  while true do
   try
    InputString := IntToStr(FPG_last_code + 1);

    if feInputBox(LNG_STRINGS[156], LNG_STRINGS[55] + ':', InputString, 1) = mrOK then
    begin
     InputValue  := StrToInt(InputString);

     if ( (InputValue <= 0) or (InputValue > 999) ) then
     begin
      feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[157], 0, 1);
      continue;
     end;

     FPG_last_code := InputValue - 1;

     // Pone el código de inserción actual
     edFPGCode.Text := NumberTo3Char(FPG_last_code + 1);
    end;

    break;
   except
    feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[157], 0, 1);
    continue;
   end;
 end;

end;
*)

procedure TfrmMain.aAddImgExecute(Sender: TObject);
var
  lItems : TStringList;
  i      : LongInt;

begin
   if lvFPG.Visible then
   begin
     // Si no hay imagenes seleccionadas
     if (lvImages.SelCount <= 0) then
      Exit;

      if not lvFPG.visible then
         Exit;

      FPG_last_code:=edFPGCode.Value;

     lItems := TStringList.Create;

     for i := 0 to lvImages.Items.Count - 1 do
     begin


      // Si la imagen no ha sido selecionada pasamos
      // a la siguiente imagen
      if not lvImages.Items.Item[i].Selected then
       continue;


      lItems.Add(lvImages.Items.Item[i].Caption);
     end;

     lvFPG_insert_images(lItems, ShellListView1.Root, TForm(frmMain), ilFPG, lvFPG, pbFPG);

     // Pone el código de inserción actual
     edFPGCode.Value  := FPG_last_code + 1;
   end;
end;


procedure TfrmMain.aConfigExecute(Sender: TObject);
var
 bmp_dst : TBitMap;
 i, j : integer;
begin
 bmp_dst := TBitmap.Create;


 with frmConfig do
 begin
  edProgram.Text  := inifile_program_edit;
  edLanguage.Text := inifile_language;
  seAnimateDelay.Value := inifile_animate_delay;
  seSizeOfIcon.Value   := inifile_sizeof_icon;
  cbAutoLoadImages.Checked := inifile_autoload_images;
  cbAutoLoadRemove.Checked := inifile_autoload_remove;
  cbFlat.Checked   := inifile_show_flat;
  cbSplash.Checked := inifile_show_splash;
  cbbgcolor.Selected        := inifile_bg_color;
  cbbgcolorFPG.Selected        := inifile_bg_colorFPG;

 end;

 old_sizeof_icon := inifile_sizeof_icon;

 frmConfig.ShowModal;

 if frmConfig.ModalResult = mrYes then
 begin
  _set_lng;
  _flat_buttons;

  if inifile_sizeof_icon <> old_sizeof_icon then
  begin
   old_sizeof_icon := inifile_sizeof_icon;

   ShellListView1.Update;


   ilFPG.Clear;

   ilFPG.Width := inifile_sizeof_icon;
   ilFPG.Height:= inifile_sizeof_icon;

   bmp_dst.Width := inifile_sizeof_icon;
   bmp_dst.Height:= inifile_sizeof_icon;

   for i := 0 to lvFPG.Items.Count - 1 do
    for j := 0 to FPG_add_pos - 1 do
     if FPG_images[j].graph_code = StrToInt(lvFPG.Items.Item[i].Caption) then
     begin
      DrawProportional(FPG_images[j].bmp, bmp_dst,lvFPG.Color);
      lvFPG.Items.Item[i].ImageIndex := ilFPG.add(bmp_dst, nil);
     end;

   lvFPG.ViewStyle := vsList;
   lvFPG.ViewStyle := vsIcon;
  end;
  lvImages.Color:=inifile_bg_color;
  lvImages.Refresh;
  lvFPG.Color:=inifile_bg_colorFPG;
  lvFPG.Refresh;
 end;

 bmp_dst.Destroy;

end;

procedure TfrmMain.aDeleteExecute(Sender: TObject);
var
 i : integer;
begin
 if lvFPG.SelCount <= 0 then
  Exit;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  DeleteWithCode( StrToInt(lvFPG.Items.Item[i].Caption));
 end;

 while(lvFPG.SelCount > 0) do
  lvFPG.Items.Delete(lvFPG.Selected.Index);

 FPG_update := true;

 // Pone el código de inserción actual
 edFPGCode.Value := FPG_last_code + 1;
 lvFPG.Repaint;
end;

procedure TfrmMain.aDeleteSelImgExecute(Sender: TObject);
var
 path : string;
 i : integer;
begin
 if (lvImages.SelCount <= 0) then
 begin
  feMessageBox( LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_WILL_BE_SELECT_IMAGE], 0, 0);
  Exit;
 end;

 if feMessageBox( LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_ARE_YOU_SURE_DELETE_IMAGES], 4, 2) <> mrYes then
  Exit;

 path := ShellListView1.Root;

 if Length(ShellListView1.Root) > 3 then
  path := path + DirectorySeparator;

 for i := 0 to lvImages.Items.Count - 1 do
 begin
  if not lvImages.Items.Item[i].Selected then
   continue;

  FileDeleteRB(path + lvImages.Items.Item[i].Caption);
 end;

 lvImages.Selected.Delete;

 feMessageBox( LNG_STRINGS[LNG_INFO], LNG_STRINGS[LNG_IMAGES_MOVED_RECICLEDBIN], 0, 0);

 // Si esta activo el auto recargado al borrar imágenes
 if inifile_autoload_remove then
  ShellListView1.Update;

end;


procedure TfrmMain.aEditSelExecute(Sender: TObject);
var
 i : word;
begin
 if lvFPG.SelCount <> 1 then
 begin
  feMessageBox( LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_FPG_SELECT_ONLY_ONE], 0, 0);
  Exit;
 end;

 for i := 1 to FPG_add_pos - 1 do
  if FPG_images[i].graph_code = StrToInt(lvFPG.Selected.Caption) then
  begin
   frmFPGImages.fpg_index   := i;
   break;
  end;

 frmFPGImages.ShowModal;

 if frmFPGImages.ModalResult = mrYes then
 begin
  lvFPG.Selected.Caption    := frmFPGImages.edCode.Text;
  lvFPG.Selected.SubItems.Strings[0] := frmFPGImages.edName.Text;
  lvFPG.Selected.SubItems.Strings[1] := frmFPGImages.edDescription.Text;
  lvFPG.Selected.SubItems.Strings[4] := IntToStr(frmFPGImages.lvControlPoints.Items.Count);
//  lvFPG.Repaint;
 end;


end;

procedure TfrmMain.aEditSelImgExecute(Sender: TObject);
begin
 chdir(prepare_file_source(ShellListView1.Root,''));

 if (lvImages.SelCount <= 0) then
 begin
  feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_WILL_BE_SELECT_IMAGE], 0, 0);
  Exit;
 end;

 if (lvImages.SelCount > 1) then
 begin
  feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_ONLY_ONE_IMAGE_EDIT], 0, 0);
  Exit;
 end;

 RunExe(inifile_program_edit+' '+lvImages.Selected.Caption,'');
end;

procedure TfrmMain.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.aExportExecute(Sender: TObject);
var
 path : string;
begin
 if not lvFPG.visible then
  Exit;

 if ((lvFPG.SelCount <= 0) and (FPG_type <> FPG8_DIV2)) then
  Exit;

 with frmExport do
 begin
  rgResType.Items.Clear;

  if lvFPG.SelCount > 0 then
  begin
   rgResType.Items.Add(LNG_STRINGS[LNG_IMAGE_TO] + ' PNG');
   rgResType.Items.Add(LNG_STRINGS[LNG_IMAGE_TO] + ' BMP');
   rgResType.Items.Add(LNG_STRINGS[LNG_IMAGE_TO] + ' MAP');
  end;

  if FPG_type = FPG8_DIV2 then
  begin
   rgResType.Items.Add(LNG_STRINGS[LNG_PALETTE_TO] + ' PAL (DIV2)');
   rgResType.Items.Add(LNG_STRINGS[LNG_PALETTE_TO] + ' PAL (PSP4)');
   rgResType.Items.Add(LNG_STRINGS[LNG_PALETTE_TO] + ' PAL (Microsoft)');
  end
  else
   if last_itemindex > 3 then
    last_itemindex := 0;

  if lvFPG.SelCount > 0 then
   rgResType.Items.Add(LNG_STRINGS[57]);

  rgResType.ItemIndex := last_itemindex;
 end;

 {frmExport.DirectoryListBox1.se := ShellListView1.Root;}

 frmExport.ShowModal;

 path := frmExport.DirectoryListBox1.Selected.GetTextPath;

 path := path + DirectorySeparator;

// Repaint;

 if frmExport.ModalResult <> mrOk then
  Exit;

 if lvFPG.SelCount <= 0 then
 begin
  case frmExport.rgResType.ItemIndex of
   0 : export_DIV2_PAL(path);
   1 : export_PSP_PAL(path);
   2 : export_MS_PAL(path);
  end;

  Exit;
 end;

 case frmExport.rgResType.ItemIndex of
  0: export_to_PNG(lvFPG, path, TForm(frmMain), pbFPG);
  1: export_to_BMP(lvFPG, path, TForm(frmMain), pbFPG);
  2: export_to_MAP(lvFPG, path, TForm(frmMain), pbFPG);
 end;

 if FPG_type = FPG8_DIV2 then
  case frmExport.rgResType.ItemIndex of
   3: export_DIV2_PAL(path);
   4: export_PSP_PAL(path);
   5: export_MS_PAL(path);
   6: export_control_points(lvFPG, path, TForm(frmMain), pbFPG);
  end
 else
   if frmExport.rgResType.ItemIndex = 3 then
     export_control_points(lvFPG, path, TForm(frmMain), pbFPG);

 aReloadExecute(sender);


end;



procedure TfrmMain.aFNTmakerExecute(Sender: TObject);
begin
  frmMainFNT.show;
end;

procedure TfrmMain.aFPGDetailsExecute(Sender: TObject);
begin
   // Se desactiva el pulsado
 (*
 mmViewFPGImages.Enabled := true;
 mmViewFPGList.Enabled   := true;
 mmViewFPGReport.Enabled := false;

 mmViewFPGImages.Checked := not mmViewFPGImages.Enabled;
 mmViewFPGList.Checked   := not mmViewFPGList.Enabled;
 mmViewFPGReport.Checked := not mmViewFPGReport.Enabled;
 *)
 lvFPG.ViewStyle := vsReport;

 sbFPGIcon.Enabled   := true;
 sbFPGList.Enabled   := true;
 sbFPGReport.Enabled := false;

end;




procedure TfrmMain.aFPGImagesExecute(Sender: TObject);
begin
   // Se desactiva el pulsado
 (*
 mmViewFPGImages.Enabled := false;
 mmViewFPGList.Enabled   := true;
 mmViewFPGReport.Enabled := true;

 mmViewFPGImages.Checked := not mmViewFPGImages.Enabled;
 mmViewFPGList.Checked   := not mmViewFPGList.Enabled;
 mmViewFPGReport.Checked := not mmViewFPGReport.Enabled;
 *)
 lvFPG.ViewStyle := vsIcon;

 sbFPGIcon.Enabled   := false;
 sbFPGList.Enabled   := true;
 sbFPGReport.Enabled := true;

end;

procedure TfrmMain.aFPGListExecute(Sender: TObject);
begin
   // Se desactiva el pulsado
 (*
 mmViewFPGImages.Enabled := true;
 mmViewFPGList.Enabled   := false;
 mmViewFPGReport.Enabled := true;

 mmViewFPGImages.Checked := not mmViewFPGImages.Enabled;
 mmViewFPGList.Checked   := not mmViewFPGList.Enabled;
 mmViewFPGReport.Checked := not mmViewFPGReport.Enabled;
 *)
 lvFPG.ViewStyle := vsList;

 sbFPGIcon.Enabled   := true;
 sbFPGList.Enabled   := false;
 sbFPGReport.Enabled := true;

end;

procedure TfrmMain.aFPGPaletteExecute(Sender: TObject);
begin
   frmPalette.ShowModal;
end;


procedure TfrmMain.aHideShowUpPanelExecute(Sender: TObject);
begin
 spDiv.Visible := not gbImages.Visible;
 gbImages.Visible  := not gbImages.Visible;
end;

procedure TfrmMain.aImgDetailsExecute(Sender: TObject);
begin
   // Se desactiva el pulsado
 aImgImages.Enabled   := true;
 aImgList.Enabled   := true;
 aImgDetails.Enabled := false;
 lvImages.ViewStyle := vsReport;
end;

procedure TfrmMain.aImgImagesExecute(Sender: TObject);
begin
 // Se desactiva el pulsado
 aImgImages.Enabled   := false;
 aImgList.Enabled   := true;
 aImgDetails.Enabled := true;
 lvImages.ViewStyle := vsIcon;

 (*
 mmImagesViewIcon.Checked   := not mmImagesViewIcon.Enabled;
 mmImagesViewList.Checked   := not mmImagesViewList.Enabled;
 mmImagesViewReport.Checked := not mmImagesViewReport.Enabled;
*)
end;

procedure TfrmMain.aImgListExecute(Sender: TObject);
begin
 // Se desactiva el pulsado
 aImgImages.Enabled   := true;
 aImgList.Enabled   := false;
 aImgDetails.Enabled := true;
 lvImages.ViewStyle := vsList;
end;

procedure TfrmMain.aInvertSelExecute(Sender: TObject);
var
 i : integer;
begin
 if lvFPG.Items.Count <= 0 then
  Exit;

 lvFPG.SetFocus;

 for i := 0 to lvFPG.Items.Count - 1 do
  lvFPG.Items.Item[i].Selected := not lvFPG.Items.Item[i].Selected;

end;

procedure TfrmMain.aInvertSelImgsExecute(Sender: TObject);
var
 i : integer;
begin
 if lvImages.Items.Count <= 0 then
  Exit;

 lvImages.SetFocus;

 for i := 0 to lvImages.Items.Count - 1 do
  lvImages.Items.Item[i].Selected := not lvImages.Items.Item[i].Selected;

end;

procedure TfrmMain.aNewExecute(Sender: TObject);
begin
 QueryResult := mrYes;
 aCloseExecute(Sender);
 // Si se cancela guardar archivo
 if QueryResult = mrCancel then
  Exit;

 FPG_source := prepare_file_source(ShellListView1.Root, LNG_STRINGS[48] + '.fpg');

 frmNewFPG.edNombre.Text := FPG_source;
 frmNewFPG.ShowModal;

 if (FPG_active) then
 begin
  lvFPG.Visible := true;
  Update_Panels;
  edFPGCODE.Value:=1;
 end;
end;

procedure TfrmMain.aCloseExecute(Sender: TObject);
begin
  if not lvFPG.visible then
   Exit;

  //FPG no esta actualizado o no tiene elementos
  if not FPG_update then
  begin
   lvFPG.visible := FPG_active;

   FPG_Free;
   FPG_update := false;

   lvFPG.Items.Clear;
   sbFPGEdit.Panels[0].Text := '';
   sbFPGEdit.Panels[1].Text := '';
   sbFPGEdit.Panels[2].Text := '';

   (*
   mmViewFPGPalette.Enabled := FPG_load_palette;
   mmFPG8.Enabled       := false;
   mmFPG16FENIX.Enabled := false;
   mmFPG16CDIV.Enabled  := false;

   mmCopyImage.Enabled  := false;
   mmPasteImage.Enabled := false;
   *)
   Exit;
  end;

  QueryResult := feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_SAVE_CHANGES], 3, 1);

  //Si se cancela la operación
  if QueryResult = mrCancel then
   Exit;

  //Si se acepta guardar
  if QueryResult = mrOK then
   aSaveAsExecute(Sender);

  FPG_Free;

  FPG_update := false;
  lvFPG.Items.Clear;
  lvFPG.visible := FPG_active;
  sbFPGEdit.Panels[0].Text := '';
  sbFPGEdit.Panels[1].Text := '';
  sbFPGEdit.Panels[2].Text := '';

  (*
  mmViewFPGPalette.Enabled := FPG_load_palette;
  mmFPG8.Enabled       := false;
  mmFPG16FENIX.Enabled := false;
  mmFPG16CDIV.Enabled  := false;

  mmCopyImage.Enabled  := false;
  mmPasteImage.Enabled := false;
  *)

end;

procedure TfrmMain.aOpenExecute(Sender: TObject);
begin
   // Cerramos el FPG actual abierto
 QueryResult := mrYes;

 aCloseExecute(Sender);

 if QueryResult = mrCancel then
  Exit;

 // Si se cancela la apertura del fichero
 if not OpenDialog.Execute then
  Exit;

 // Comprobamos si existe o no
 if not FileExistsUTF8(OpenDialog.Filename) { *Converted from FileExists*  } then
  Exit;

 OpenFPG(OpenDialog.Filename);

end;

procedure TfrmMain.aOpenImgExecute(Sender: TObject);
begin
   if lvImages.SelCount <> 1 then
  Exit;

 frmView.FPG := false;
 frmView.file_selected :=
  prepare_file_source(ShellListView1.Root, lvImages.Selected.Caption);

 frmView.Show;
end;

procedure TfrmMain.aReloadExecute(Sender: TObject);
begin
 // Si esta cargando imagenes no se actualiza
 if pbImages.Visible then Exit;

 ShellListView1.Update;
end;

procedure TfrmMain.aReplazeImgExecute(Sender: TObject);
begin

end;

procedure TfrmMain.aSaveAsExecute(Sender: TObject);
begin
   if not lvFPG.visible then
  Exit;

 //Sale si no se pulsa cancelar
 if not SaveDialog.Execute then
  Exit;

 //Se comprueba si existe el fichero
 if FileExistsUTF8(SaveDialog.FileName) { *Converted from FileExists*  } then
 begin

  if feMessageBox(LNG_STRINGS[LNG_WARNING], LNG_STRINGS[LNG_EXISTS_FILE_OVERWRITE], 4, 2) <> mrYes then
   Exit;
 end;

 //Establecemos la dirección donde debe ser guardado
 FPG_source := SaveDialog.FileName;

 //Comprobamos que se indicó el tipo de fichero
 if( AnsiPos( '.fpg',AnsiLowerCase(SaveDialog.FileName)) <= 0 ) then
  FPG_source := FPG_source + '.fpg';

 //Mensaje en Panel inferior
 sbFPGEdit.Panels.Items[0].Text := FPG_source;

 //Guardamos el fichero y desactivamos FPG_update
 FPG_Save(TForm(frmMain), pbFPG);
 FPG_update := false;
end;

procedure TfrmMain.aSaveExecute(Sender: TObject);
begin
   if not lvFPG.visible then
  Exit;

 FPG_Save(TForm(frmMain), pbFPG);
 FPG_update := false;

end;

procedure TfrmMain.aSelectAllExecute(Sender: TObject);
var
 i : integer;
begin
 if lvFPG.Items.Count <= 0 then
  Exit;

 lvFPG.SetFocus;

 for i := 0 to lvFPG.Items.Count - 1 do
  lvFPG.Items.Item[i].Selected := true;

end;

procedure TfrmMain.aSelectAllImgsExecute(Sender: TObject);
var
 i : integer;
begin
 if lvImages.Items.Count <= 0 then
  Exit;

 lvImages.SetFocus;

 for i := 0 to lvImages.Items.Count - 1 do
  lvImages.Items.Item[i].Selected := true;

end;

procedure TfrmMain.aZipToolExecute(Sender: TObject);
begin
  frmZipFenix.Show;
end;

procedure TfrmMain.sbFilterClick(Sender: TObject);
begin
  if EFilter.Text<>'' then
  begin
   ShellListView1.Mask:=EFilter.Text;
   ShellTreeView1Change(sender, nil);
  end;
end;

procedure TfrmMain.edFPGCODEChange(Sender: TObject);
begin
 if not lvFPG.visible then
  Exit;
 FPG_last_code := edFPGCODE.Value;
end;

procedure TfrmMain.EFilterKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
  begin
    sbFilterClick(sender);
  end;
end;


procedure TfrmMain.lvBMP_add_text;
var
 list_bmp : TListItem;
 i : Integer;
begin

 // Limpiamos las listas de imagenes
 ilImages.Clear;
 lvImages.Items.Clear;

 // Si no hay elemento salimos
 if ShellListView1.Items.Count <= 0 then
  Exit;

 for i := 1 to ShellListView1.Items.Count do
 begin
  list_bmp := lvImages.Items.Add;
  list_bmp.Caption := ShellListView1.Items[i - 1].Caption;
 end;

end;

procedure TfrmMain.lvBMP_add_icons;
var
 bmp_dst,
 bmp_src  : TBitmap;
 list_bmp : TListItem;
 i : Integer;
 FileCount : LongInt;
 WorkDir,
 filename,
 file_source : String;
 bpp_src : Byte;

begin
 FileCount := ShellListView1.Items.Count;
 WorkDir   := ShellListView1.root;

 // Limpiamos las listas de imagenes
 ilImages.Clear;
 lvImages.Items.Clear;

 // Si no hay elemento salimos
 if FileCount <= 0 then
  Exit;

 pbImages.Position := 0;
 pbImages.Repaint;


 ilImages.Width  := inifile_sizeof_icon;
 ilImages.Height := inifile_sizeof_icon;

 i := 1;

 cancel_load_icons := false;
 while (i <= FileCount) and not cancel_load_icons do
 begin
  // Creamos el bitmap de carga
  bmp_src := TBitmap.Create;

  filename := ShellListView1.Items[i-1].Caption;
  file_source := prepare_file_source( WorkDir, filename );


  if loadImageFile(bmp_src,file_source ) then
   begin

    list_bmp := lvImages.Items.Add;

    DrawProportional(bmp_src, bmp_dst, lvImages.Color);

    list_bmp.ImageIndex := ilImages.add(bmp_dst, nil);

    list_bmp.Caption := filename;
    list_bmp.SubItems.Add(IntToStr( bmp_src.Width  ));
    list_bmp.SubItems.Add(IntToStr( bmp_src.Height ));
    list_bmp.SubItems.Add(IntToStr(PIXELFORMAT_BPP[bmp_src.PixelFormat]));
   end;

  pbImages.Position := (i * 100) div FileCount;
  //Application.ProcessMessages;
  pbImages.Repaint;


  bmp_src.free;

  i := i + 1;
 end;

 pbImages.Hide;
end;

//-----------------------------------------------------------------------------
// lvImagesDblClick: Al hacer doble click en la lista de imagenes.
//-----------------------------------------------------------------------------

procedure TfrmMain.lvImagesDblClick(Sender: TObject);
begin
 aOpenImgExecute(Sender);
end;

procedure TfrmMain.lvFPGDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin

end;

procedure TfrmMain.lvFPGDragDrop(Sender, Source: TObject; X, Y: Integer);
begin

end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
 if lvFPG.visible then
  FPG_Free;
end;

//-----------------------------------------------------------------------------
// FormCloseQuery: Al intentar cerrar el programa comprueba si se guardaron
//                 los cambios.
//-----------------------------------------------------------------------------

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 QueryResult := mrYes;

 aCloseExecute(Sender);

 if QueryResult = mrCancel then
  CanClose := false;
end;

procedure TfrmMain.OpenFPG( sfile: string );
var
 WorkDir: string;
 BinDir: string;
 error : boolean;
 f : TextFile;
begin
 FPG_source := sfile;

 // Comprobamos si es un formato sin comprimir
 if not FPG_Test(FPG_source) then
 begin

 WorkDir := GetTempDir(False) ;
 BinDir := ExtractFilePath(Application.ExeName);

 {$IFDEF WINDOWS}
  RunExe(BinDir + DirectorySeparator+'\zlib\zlib.exe -d "'+ FPG_source + '"', WorkDir );
 {$ENDIF}

 {$IFDEF Linux}
   RunExe('/bin/gzip -dc "'+ FPG_source+'"', WorkDir,WorkDir +'________.uz' );
 {$ENDIF}


  error := not FPG_Load( WorkDir +'________.uz', TForm(frmMain), pbFPG);

  AssignFile(f, WorkDir +'________.uz');
  Erase(f);

  if error then Exit;

  lvFPG_Load_Bitmaps;
 end
 else
  if FPG_Load(FPG_source, TForm(frmMain), pbFPG) then
  begin
   lvFPG_Load_Bitmaps;
  end;
end;


//-----------------------------------------------------------------------------
// LoadFPGImages: Carga de imagenes de un FPG.
//-----------------------------------------------------------------------------

procedure TfrmMain.lvFPG_Load_Bitmaps;
begin
 FPG_active    := true;
 lvFPG.visible := true;

 Update_Panels;

 lvFPG_Load_Images(ilFPG, lvFPG, TForm(frmMain), pbFPG);
end;




//-----------------------------------------------------------------------------
// lvFPGDblClick: Al hacer doble click en el ventana de imagenes del FPG
//-----------------------------------------------------------------------------

procedure TfrmMain.lvFPGDblClick(Sender: TObject);
var
 i : word;
begin
 if lvFPG.SelCount <> 1 then
  Exit;

 if FPG_add_pos <= 1 then
  Exit;

 frmView.FPG := true;
 frmView.file_selected := lvFPG.Selected.Caption;

 for i := 0 to FPG_add_pos - 1 do
  if StrToInt(lvFPG.Selected.Caption) = FPG_images[i].graph_code then
   begin
    frmView.Image.Picture.Bitmap := FPG_images[i].bmp;
    break;
   end;

 frmView.Show;
end;

//-----------------------------------------------------------------------------
// FormCreate: Al crear la ventana carga el fichero "ini" si esto es posible.
//-----------------------------------------------------------------------------

procedure TfrmMain.FormCreate(Sender: TObject);
begin
// DragOver := 255;

 load_inifile;

 FPG_init;

 load_language;

 _lng_str := '';

  ShellListView1.Root:= DirectorySeparator;
  EFilter.ItemIndex:=0;
  ShellListView1.Mask:= EFilter.Text;
  lvImages.Color:=inifile_bg_color;
  lvFPG.Color:=inifile_bg_colorFPG;
  FPG_last_code:=0;

end;


//-----------------------------------------------------------------------------
// lvFPGMouseDown: Al pulsar el ratón sirver para detectar eventos del ratón y
//                 lanzar su respectiva acción
//-----------------------------------------------------------------------------

procedure TfrmMain.lvFPGMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;



//-----------------------------------------------------------------------------
// FormShow: Cuando se muestra el programa comprobamos si hay parametros de
//           entrada, para habrir un FPG.
//-----------------------------------------------------------------------------

procedure TfrmMain.FormShow(Sender: TObject);
begin
 // Si se quiere mostrar la pantalla de incio
 if inifile_show_splash then
 begin
  Application.CreateForm(TfrmSplash, frmSplash);
  frmSplash.ShowModal;
  frmSplash.Destroy;
 end;

 _flat_buttons;

 // Si no hay un parametro
 if ParamCount <> 1 then
  Exit;

 // Comprobamos si existe o no
 if not FileExistsUTF8(ParamStr(1)) { *Converted from FileExists*  } then
  Exit;

 OpenFPG(ParamStr(1));
end;

procedure TfrmMain.lvFPGKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 // Si se pulsa la tecla suprimir
 if key = 46 then aDeleteExecute(Sender);
end;


procedure TfrmMain.aFPG8Execute(Sender: TObject);
begin
 if lvFPG.Items.Count <= 0 then
 begin
  feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_IMAGES_FOR_CONVERT], 0, 0);
  Exit;
 end;

 Convert_to_FPG8_DIV2(ilFPG, lvFPG, TForm(frmMain), pbFPG);

 Update_Panels;
end;


procedure TfrmMain.aFPG16cExecute(Sender: TObject);
begin
 Convert_to_FPG16_CDIV(ilFPG, lvFPG, TForm(frmMain), pbFPG);
 Update_Panels;
end;

procedure TfrmMain.aFPG1Execute(Sender: TObject);
begin
 Convert_to_FPG1(ilFPG, lvFPG, TForm(frmMain), pbFPG);
 Update_Panels;
end;

procedure TfrmMain.aFPG24Execute(Sender: TObject);
begin
 Convert_to_FPG24(ilFPG, lvFPG, TForm(frmMain), pbFPG);
 Update_Panels;
end;

procedure TfrmMain.aFPG32Execute(Sender: TObject);
begin
 Convert_to_FPG32(ilFPG, lvFPG, TForm(frmMain), pbFPG);
 Update_Panels;

end;

procedure TfrmMain.aFPG16fExecute(Sender: TObject);
begin
 Convert_to_FPG16_FENIX(ilFPG, lvFPG, TForm(frmMain), pbFPG);
 Update_Panels;
end;


procedure TfrmMain.ppImagesPopup(Sender: TObject);
var
 view_items : boolean;
begin
 view_items := (lvImages.SelCount = 1);

 ppOpenImage.Visible := view_items;
 ppEditImage.Visible := view_items;
end;

procedure TfrmMain.ppFPGImagesPopup(Sender: TObject);
var
 view_simple_items,
 view_multip_items : Boolean;
begin
 view_simple_items := (lvFPG.SelCount = 1);
 view_multip_items := (lvFPG.SelCount > 1);

 ppFPGOpen.Visible    := view_simple_items;
 ppFPGAnimate.Visible := view_multip_items;
 ppFPGEdit.Visible    := view_simple_items;
 ppFPGRemove.Visible  := view_simple_items or view_multip_items;
 ppFPGExport.Visible  := view_simple_items or view_multip_items;
 ppCopyImage.Visible  := view_simple_items;
end;

procedure TfrmMain.mmPasteImageClick(Sender: TObject);
begin
 if lvFPG.visible then
  lvFPG_insert_imagescb(ilFPG, lvFPG, TForm(frmMain), pbFPG);
end;

procedure TfrmMain.mmCopyImageClick(Sender: TObject);
var
 j : integer;
 MyFormat : Word;
begin
 if not lvFPG.visible then
 begin
  feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_EXIST_FPG], 0, 0);
  Exit;
 end;

 if (lvFPG.SelCount <> 1) then
 begin
  feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_FPG_SELECT_ONLY_ONE], 0, 0);
  Exit;
 end;

 for j := 0 to FPG_add_pos - 1 do
   if FPG_images[j].graph_code = StrToInt(lvFPG.Selected.Caption) then
   begin
    MyFormat := cf_Bitmap;

    FPG_images[j].bmp.SaveToClipboardFormat(MyFormat);
    {ClipBoard.SetFormat (MyFormat );}

    feMessageBox( LNG_STRINGS[LNG_INFO], LNG_STRINGS[LNG_IMAGE_TO_CLIPBOARD], 0, 0);
    break;
   end;
end;

procedure TfrmMain.mmClearClipBoardClick(Sender: TObject);
begin
 ClipBoard.Clear;
end;


procedure TfrmMain.aFenixExecute(Sender: TObject);
begin
 OpenURL('http://fenix.divsite.net/');
end;

procedure TfrmMain.aCDivExecute(Sender: TObject);
begin
 OpenURL('http://cdiv.sourceforge.net/');
end;

procedure TfrmMain.aDIV2Execute(Sender: TObject);
begin
 OpenURL('http://www.div-arena.com/');
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
 _set_lng;
end;

procedure TfrmMain.sbFPGCODEClick(Sender: TObject);
begin

end;

//procedure TfrmMain.sbImagesFilterClick(Sender: TObject);
//begin
// ShellListView1.Mask := edImagesFilter.Text;
 //if not sbImagesFilter.Flat then
 //begin
 // sFilter := ShellListView1.Mask;
 //
 // sbImagesFilter.Flat := true;
 //
 // edImagesFilter.ReadOnly := true;
 // edImagesFilter.Color := clMedGray;
 //
 // ShellListView1.Mask := edImagesFilter.Text;
 //end
 //else
 //begin
 // sbImagesFilter.Flat := False;
 //
 // edImagesFilter.ReadOnly := false;
 // edImagesFilter.Color := clWhite;
 //
 // ShellListView1.Mask := sFilter;
 //end;
// ShellListView1.Refresh;
//end;

(*
procedure TfrmMain.sbFPGCODEClick(Sender: TObject);
begin
 if not lvFPG.visible then
  Exit;

 if CodeExists( StrToInt(edFPGCODE.Text) ) then
 begin
  feMessageBox( LNG_STRINGS[LNG_ERROR], LNG_STRINGS[158], 0, 1);
  Exit;
 end;

 edFPGCODE.Color := clMedGray;

 FPG_last_code := StrToInt(edFPGCODE.Text) - 1;

end;
*)

procedure TfrmMain.edFPGCODEKeyPress(Sender: TObject; var Key: Char);
begin
 case key of
  '0' .. '9', chr(8): begin end;
  chr(13) : sbFPGCODEClick(Sender);
 else
  key := chr(13);
 end; 
end;




procedure TfrmMain._flat_buttons;
begin
 sbImagesViewDir.Flat := inifile_show_flat;
 sbImagesIcon.Flat    := inifile_show_flat;
 sbImagesList.Flat    := inifile_show_flat;
 sbImagesReport.Flat  := inifile_show_flat;
 sbImagesAnimate.Flat := inifile_show_flat;
 sbImagesEdit.Flat    := inifile_show_flat;
 sbImagesUpdate.Flat  := inifile_show_flat;
 sbImagesRemove.Flat  := inifile_show_flat;
 sbFilter.Flat:= inifile_show_flat;

 lvImages.FlatScrollBars := inifile_show_flat;

 sbFPGNew.Flat       := inifile_show_flat;
 sbFPGOpen.Flat      := inifile_show_flat;
 sbFPGSave.Flat      := inifile_show_flat;
 sbFPGSaveAs.Flat    := inifile_show_flat;
 sbFPGViewFrame.Flat := inifile_show_flat;
 sbFPGIcon.Flat      := inifile_show_flat;
 sbFPGList.Flat      := inifile_show_flat;
 sbFPGReport.Flat    := inifile_show_flat;
 sbFPGAnimate.Flat   := inifile_show_flat;
 sbFPGAdd.Flat       := inifile_show_flat;
 sbFPGEditBMP.Flat   := inifile_show_flat;
 sbFPGExport.Flat    := inifile_show_flat;
 sbFPGRemove.Flat    := inifile_show_flat;

 lvFPG.FlatScrollBars := inifile_show_flat;

end;

procedure TfrmMain.aGemixExecute(Sender: TObject);
begin
   OpenURL('http://www.gemixstudio.com');
end;

procedure TfrmMain.aHideShowDirsExecute(Sender: TObject);
begin
  panelDirs.Visible := not panelDirs.Visible;
end;

procedure TfrmMain.aBennuExecute(Sender: TObject);
begin
  OpenURL('http://bennugd.org/');

end;


procedure TfrmMain.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
 if inifile_autoload_images then
 begin
  cancel_load_icons := true;
  lvBMP_add_icons
 end
 else
  lvBMP_add_text;

end;

end.