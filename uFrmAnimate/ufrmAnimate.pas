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

unit ufrmAnimate;


interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, uFPG,
  ExtCtrls, uLanguage, uIniFile;

const
 sFPG = 0;
 sIMG = 1;

type
  aBitmap = record
   bmp : TBitmap
  end;

  TfrmAnimate = class(TForm)
    tAnimate: TTimer;
    procedure tAnimateTimer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }

    _lng_str : string;

    procedure _set_lng;
  public
    { Public declarations }
    fpg_animate : Array [1 .. 999] of boolean;
    img_animate : Array [1 .. 99 ] of aBitmap;
    num_of_images : integer;
    source : integer;
    i : integer;
    procedure Draw_Image;
  end;

var
  frmAnimate: TfrmAnimate;
  bmp : TBitmap;

implementation

{$R *.lfm}

procedure TfrmAnimate._set_lng;
begin
 if _lng_str = inifile_language then
  Exit;

 _lng_str := inifile_language;

 frmAnimate.Caption := LNG_STRINGS[82];
end;

procedure TfrmAnimate.Draw_Image;
var
 CenterX, CenterY : word;
begin
 case source of
  sFPG :
  begin
   while (true) do
   begin
    i := i + 1;

    if fpg_animate[i] then
    begin
     CenterX := (ClientWidth  - FPG_images[i].bmp.Width ) div 2;
     CenterY := (ClientHeight - FPG_images[i].bmp.Height) div 2;

     bmp.Canvas.Brush.Color := clBlack;
     bmp.Canvas.FillRect( Rect(0,0, ClientWidth, ClientHeight ));
     bmp.Canvas.Draw(CenterX, CenterY, FPG_images[i].bmp);
     Canvas.Draw( 0, 0, bmp );
     break;
    end;

    if i = 999 then i := 0;
   end;


  end;
  sImg:
  begin
   while ( i < num_of_images ) do
   begin
    i := i + 1;

    CenterX := (ClientWidth  - IMG_animate[i].bmp.Width ) div 2;
    CenterY := (ClientHeight - IMG_animate[i].bmp.Height) div 2;

    bmp.Canvas.Brush.Color := clBlack;
    bmp.Canvas.FillRect( Rect(0,0, ClientWidth, ClientHeight ));
    bmp.Canvas.Draw(CenterX, CenterY, IMG_animate[i].bmp);
    Canvas.Draw( 0, 0, bmp );
    break;
   end;

   if ( i = num_of_images ) then i := 0;

  end;
 end;
end;


procedure TfrmAnimate.tAnimateTimer(Sender: TObject);
begin
 Draw_Image;
end;

procedure TfrmAnimate.FormDeactivate(Sender: TObject);
begin
 i := 0;
 tAnimate.Enabled := false;

 num_of_images := 0;
 Hide;
 ModalResult := mrOK;
end;

procedure TfrmAnimate.FormActivate(Sender: TObject);
begin
 _set_lng;

 i := 0;
 bmp.Width  := ClientWidth;
 bmp.Height := ClientHeight;
 tAnimate.Enabled := true;
end;

procedure TfrmAnimate.FormCreate(Sender: TObject);
begin
 bmp := TBitmap.Create;
 source := sFPG;
end;

procedure TfrmAnimate.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 FormDeactivate(Sender);
end;

procedure TfrmAnimate.FormKeyPress(Sender: TObject; var Key: Char);
begin
 FormDeactivate(Sender);
end;

end.
