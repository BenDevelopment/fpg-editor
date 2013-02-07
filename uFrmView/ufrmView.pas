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

unit ufrmView;


interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ClipBrd, dialogs, Spin,
  uinifile, uLanguage, uLoadImage;

const
 MIN_CLIENT_WIDTH  = 269;
 HEIGHT_DETAILS = 49;

type

  { TfrmView }

  TfrmView = class(TForm)
    Image: TImage;
    gbDetails: TGroupBox;
    lbBpp: TLabel;
    lZoom: TLabel;
    lbWidth: TLabel;
    lbHeight: TLabel;
    lbAncho: TLabel;
    lbAlto: TLabel;
    lBPP: TLabel;
    seZoom: TSpinEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure seZoomChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    file_selected: String;
    FPG, control_points, point_active : Boolean;
    pointX, pointY: Integer;
  end;

var
  frmView: TfrmView;

implementation


{$R *.lfm}

procedure TfrmView.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    Deactivate;
end;


procedure TfrmView.FormShow(Sender: TObject);
var
 bmp  : TBitmap;
begin
 Caption := file_selected;

 if not FPG then
 begin
  bmp := Image.Picture.Bitmap;
  loadImageFile(bmp, file_selected);
 end;

 lbAncho.Caption := IntToStr(Image.Picture.Bitmap.Width);
 lbAlto.Caption  := IntToStr(Image.Picture.Bitmap.Height);
 lbBpp.Caption  := IntToStr(PIXELFORMAT_BPP[Image.Picture.Bitmap.PixelFormat]);

 seZoom.Value:=100;
 seZoomChange(Sender);

end;



procedure TfrmView.FormDeactivate(Sender: TObject);
begin
 control_points := false;
 point_active   := false;
 Hide;
end;

procedure TfrmView.FormResize(Sender: TObject);
begin
 if (ClientWidth < MIN_CLIENT_WIDTH) then
  ClientWidth := MIN_CLIENT_WIDTH;
end;

procedure TfrmView.FormCreate(Sender: TObject);
begin
 control_points := false;
 point_active   := false;
end;

procedure TfrmView.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if( control_points and (not point_active) ) then
 begin
  Image.Picture.Bitmap.Canvas.Pen.Color := inifile_color_points;

  pointX := ( X * 100 ) div sezoom.Value;
  pointY := ( Y * 100 ) div sezoom.Value;

  //Image1.Picture.Bitmap.Canvas.Ellipse( pointX - 1, pointY - 1, pointX + 1, pointY + 1);

  if( (pointX >= 0) and (pointX < Image.Picture.Bitmap.width) and
      (pointY >= 0) and (pointY < Image.Picture.Bitmap.height) ) then
   Image.Picture.Bitmap.Canvas.Pixels[pointX, pointY] := inifile_color_points;

  point_active := true;
 end;
end;

procedure TfrmView.FormActivate(Sender: TObject);
begin
 gbDetails.Caption := LNG_STRINGS[122];

 lbWidth.Caption  := LNG_STRINGS[53] + ' :';
 lbHeight.Caption := LNG_STRINGS[54] + ' :';
end;


procedure TfrmView.seZoomChange(Sender: TObject);
begin
 if  sezoom.Value > 0 then
 begin
   Image.Width := (Image.Picture.Bitmap.Width  * sezoom.Value) div 100;
   Image.Height:= (Image.Picture.Bitmap.Height * sezoom.Value) div 100;

   ClientWidth  := Image.Width;
   ClientHeight := Image.Height + gbDetails.Height;

   if (ClientWidth < MIN_CLIENT_WIDTH) then
    ClientWidth := MIN_CLIENT_WIDTH;
 end;
end;


end.