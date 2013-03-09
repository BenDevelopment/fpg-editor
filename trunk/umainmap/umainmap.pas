unit umainmap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ExtCtrls, ExtDlgs, Spin, StdCtrls, Buttons, ColorBox,
  IntfGraphics, FPimage, lazcanvas, ComCtrls, FPCanvas, typinfo ,math, uLanguage;

type

  { TfrmMapEditor }

  TfrmMapEditor = class(TForm)
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Action5: TAction;
    Action6: TAction;
    Action7: TAction;
    Action8: TAction;
    ActionList1: TActionList;
    BrushStyleCombo: TComboBox;
    cbPen: TColorButton;
    cbBrush: TColorButton;
    cbBackground: TColorButton;
    cbPen1: TColorButton;
    cbBrush1: TColorButton;
    ColorDialog1: TColorDialog;
    FigureCombo: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PColor1: TPanel;
    PenStyleCombo: TComboBox;
    PenModeCombo: TComboBox;
    SavePictureDialog1: TSavePictureDialog;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    sePenAlpha: TSpinEdit;
    seBrushAlpha: TSpinEdit;
    SpinEdit1: TSpinEdit;
    sePen: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ToolBar1: TToolBar;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure Action8Execute(Sender: TObject);
    procedure BrushStyleComboChange(Sender: TObject);
    procedure cbBrush1ColorChanged(Sender: TObject);
    procedure cbBrushColorChanged(Sender: TObject);
    procedure cbBackgroundColorChanged(Sender: TObject);
    procedure cbPen1ColorChanged(Sender: TObject);
    procedure cbPenColorChanged(Sender: TObject);
    procedure ColorButton27Click(Sender: TObject);
    procedure FigureComboChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseLeave(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PColor1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PenModeComboChange(Sender: TObject);
    procedure PenStyleComboChange(Sender: TObject);
    procedure seBrushAlphaChange(Sender: TObject);
    procedure sePenAlphaChange(Sender: TObject);
    procedure sePenChange(Sender: TObject);
    procedure SpeedButton1DblClick(Sender: TObject);
    procedure SpeedButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpinEdit1Change(Sender: TObject);
    procedure pencil(X,Y: integer);
    procedure copyColor(X,Y: integer);
    procedure line(X,Y: integer; X2,Y2:Integer);
    procedure Splitter1CanOffset(Sender: TObject; var NewOffset: Integer;
      var Accept: Boolean);
    procedure triangle(X,Y: integer; X2,Y2:Integer);
    procedure rectangle(X,Y: integer; X2,Y2:Integer);
    procedure circle(X,Y: integer; X2,Y2:Integer);
//    procedure paintPenImage;
//    procedure paintBrushImage;
    procedure updatePen;
    procedure updateBrush;
  private
    x1,y1 : Integer;
    FPen : TFPCustomPen;
    FBrush : TFPCustomBrush;
    undoImage : TPicture;
    primeraVez : Boolean;
   { private declarations }
  public
    { public declarations }
    imageSource : TPicture;
  end;

var
  frmMapEditor: TfrmMapEditor;

resourcestring
  LNG_MAPEDIT_HELP = 'Con control pulsado y haciendo clic, puedes cambiar los colores de la paleta.';

implementation

{$R *.lfm}

{ TfrmMapEditor }

procedure TfrmMapEditor.Action4Execute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMapEditor.Action8Execute(Sender: TObject);
begin
  image1.Picture.Assign(undoImage);
end;

procedure TfrmMapEditor.BrushStyleComboChange(Sender: TObject);
begin
    updateBrush;

end;

procedure TfrmMapEditor.cbBrush1ColorChanged(Sender: TObject);
begin
  cbBrush.ButtonColor:=cbBrush1.ButtonColor;
  updateBrush;
end;

procedure TfrmMapEditor.cbBrushColorChanged(Sender: TObject);
begin
  cbBrush1.ButtonColor:=cbBrush.ButtonColor;
  updateBrush;
end;

procedure TfrmMapEditor.cbBackgroundColorChanged(Sender: TObject);
begin
  ScrollBox1.Color:=cbBackground.ButtonColor;
end;

procedure TfrmMapEditor.cbPen1ColorChanged(Sender: TObject);
begin
  cbPen.ButtonColor:=cbPen1.ButtonColor;
  updatePen;
end;

procedure TfrmMapEditor.cbPenColorChanged(Sender: TObject);
begin
  cbPen1.ButtonColor:=cbPen.ButtonColor;
  updatePen;
end;

procedure TfrmMapEditor.ColorButton27Click(Sender: TObject);
begin
  ShowMessage('a');
end;


procedure TfrmMapEditor.FigureComboChange(Sender: TObject);
begin
  case FigureCombo.ItemIndex of
  0: MenuItem7.Checked := true;
  1: MenuItem8.Checked := true;
  2: MenuItem12.Checked := true;
  3: MenuItem13.Checked := true;
  4: MenuItem9.Checked := true;
  5: MenuItem14.Checked := true;
  end;
end;

procedure TfrmMapEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin

end;

procedure TfrmMapEditor.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if MessageDlg(LNG_WARNING,LNG_SAVE_CHANGES,mtWarning,mbYesNo,0) = mrYes  then
  begin
     imageSource.Assign(Image1.Picture);
  end;
end;

(*
procedure TfrmMapEditor.paintPenImage;
var
  bmp : TBitmap;
  lazBMP : TLazIntfImage;
  imgCanvas : TFPImageCanvas;
begin
  bmp:= TBitmap.Create;
  bmp.SetSize(16,16);
  lazBMP := bmp.CreateIntfImage;

  imgCanvas := TFPImageCanvas.create(lazBMP);
  imgCanvas.Brush.FPColor:=FPen.FPColor;
  imgCanvas.Brush.Style:=bsSolid;
  imgCanvas.FillRect(0,0,16,16);

  bmp.LoadFromIntfImage(lazBMP);
  SpeedButton1.Glyph.Assign(bmp);
  FreeAndNil(lazBMP);
  freeandnil(bmp);
end;
*)
(*
procedure TfrmMapEditor.paintBrushImage;
var
  bmp : TBitmap;
  lazBMP : TLazIntfImage;
  imgCanvas : TFPImageCanvas;
begin
  bmp:= TBitmap.Create;
  bmp.SetSize(16,16);
  lazBMP := bmp.CreateIntfImage;

  imgCanvas := TFPImageCanvas.create(lazBMP);
  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;
  imgCanvas.FillRect(0,0,16,16);

  bmp.LoadFromIntfImage(lazBMP);
  SpeedButton2.Glyph.Assign(bmp);
  FreeAndNil(lazBMP);
  freeandnil(bmp);
end;
*)

procedure TfrmMapEditor.updatePen;
var
  tmpColor : TFPColor;
begin
  FPen.Style:=TFPPenStyle(PenStyleCombo.ItemIndex);
  FPen.Width:=sePen.Value;
  tmpColor:=TColorToFPColor(cbPen.ButtonColor);
  tmpColor.alpha:=High(word) * (sePenAlpha.value div 100);
  FPen.FPColor:=tmpColor;
  FPen.Mode:=TFPPenMode(PenModeCombo.ItemIndex);

end;

procedure TfrmMapEditor.updateBrush;
var
  tmpColor : TFPColor;
begin
  FBrush.Style:=TFPBrushStyle(BrushStyleCombo.ItemIndex);
  tmpColor:=TColorToFPColor(cbBrush.ButtonColor);
  tmpColor.alpha:=High(word)* (seBrushAlpha.value div 100);
  FBrush.FPColor:=tmpColor;

end;

procedure TfrmMapEditor.FormCreate(Sender: TObject);
var
  ps: TFPPenStyle;
  bs: TFPBrushStyle;
  pm: TFPPenMode;
  tmpPanel : TPanel;
  i : Integer;
begin
  FPen := TFPCustomPen.Create;
  FBrush := TFPCustomBrush.Create;

  undoImage:= TPicture.Create;

  PenStyleCombo.Items.BeginUpdate;
  for ps := Low(ps) to High(ps) do
    PenStyleCombo.Items.Add(GetEnumName(TypeInfo(TFPPenStyle), Ord(ps)));
  PenStyleCombo.Items.EndUpdate;
  PenStyleCombo.ItemIndex := 0;

  PenModeCombo.Items.BeginUpdate;
  for pm := Low(pm) to High(pm) do
    PenModeCombo.Items.Add(GetEnumName(TypeInfo(TFPPenMode), Ord(pm)));
  PenModeCombo.Items.EndUpdate;
  PenModeCombo.ItemIndex := 1;


  BrushStyleCombo.Items.BeginUpdate;
  for bs := Low(bs) to High(bs) do
    BrushStyleCombo.Items.Add(GetEnumName(TypeInfo(TFPBrushStyle), Ord(bs)));
  BrushStyleCombo.Items.EndUpdate;
  BrushStyleCombo.ItemIndex := 0;

  updatePen;
  updateBrush;

  cbBackground.ButtonColor:=ScrollBox1.Color;
  primeraVez:=true;
end;

procedure TfrmMapEditor.FormShow(Sender: TObject);
var
  i : Integer;
  tmpPanel : TPanel;
begin
  BeginFormUpdate;
  if primeraVez then
  begin
    for i:=1 to 255 do
    begin
      tmpPanel:= TPanel.Create(Owner);
      tmpPanel.OnMouseDown:= @PColor1MouseDown;
      tmpPanel.Width:=ToolBar1.ButtonHeight;
      tmpPanel.Parent:=ToolBar1;
    end;
    primeraVez:=false;
  end;
  EndFormUpdate;

end;

procedure TfrmMapEditor.pencil(X,Y: integer);
var
  lazBMP : TLazIntfImage;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  lazBMP.Colors[x,y]:=FPen.FPColor;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.copyColor(X,Y: integer);
var
  lazBMP : TLazIntfImage;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  FPen.FPColor:=lazBMP.Colors[x,y];

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);

  cbPen.ButtonColor:=FPColorToTColor(FPen.FPColor);
  cbPen1.ButtonColor:=cbPen.ButtonColor;

  sePenAlpha.Value:= (FPen.FPColor.alpha * 100) div high(Word) ;


end;

procedure TfrmMapEditor.line(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);

  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;
  imgCanvas.Line(x,y,x2,y2);

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.Splitter1CanOffset(Sender: TObject;
  var NewOffset: Integer; var Accept: Boolean);
begin

end;

procedure TfrmMapEditor.circle(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);


  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;

  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;
  imgCanvas.EllipseC(x,y,abs(x-x2),abs(y-y2));

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.triangle(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
  Points: array of TPoint;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);


  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;

  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;

  SetLength(Points, 4);
  Points[0] := Point(x, y2);
  Points[3] := Points[0];
  Points[1] := Point((x + x2) div 2, y);
  Points[2] := point(x2,y2);

  imgCanvas.Polygon(points);

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.rectangle(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);


  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;

  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;
  imgCanvas.Rectangle(x,y,x2,y2);

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  X1 := (X * 100 )div SpinEdit1.Value;
  Y1 := (Y * 100 )div SpinEdit1.Value;
  undoImage.Assign(Image1.Picture);
  if FigureCombo.ItemIndex = 5 then
     copyColor(x1,y1);

end;

procedure TfrmMapEditor.Image1MouseLeave(Sender: TObject);
begin
(*
  if MenuItem6.Checked then
  begin
     undoImage.Assign(Image1.Picture);
     pencil(X1,Y1);
 end;*)
end;

procedure TfrmMapEditor.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  X2,Y2: integer;
begin
  if   ssLeft in  Shift then
  begin
    if FigureCombo.ItemIndex = 0 then
    begin
       X1 := (X * 100 )div SpinEdit1.Value;
       Y1 := (Y * 100 )div SpinEdit1.Value;
       pencil(x1,y1);
    end;
    if FigureCombo.ItemIndex = 1 then
    begin
       X2 := (X * 100 )div SpinEdit1.Value;
       Y2 := (Y * 100 )div SpinEdit1.Value;
       image1.Picture.assign(undoImage);
       line(x1,y1,x2,y2);
    end;
    if FigureCombo.ItemIndex = 2 then
    begin
       X2 := (X * 100 )div SpinEdit1.Value;
       Y2 := (Y * 100 )div SpinEdit1.Value;
       image1.Picture.assign(undoImage);
       triangle(x1,y1,x2,y2);
    end;
    if FigureCombo.ItemIndex = 3 then
    begin
       X2 := (X * 100 )div SpinEdit1.Value;
       Y2 := (Y * 100 )div SpinEdit1.Value;
       image1.Picture.assign(undoImage);
       rectangle(x1,y1,x2,y2);
    end;
    if FigureCombo.ItemIndex = 4 then
    begin
       X2 := (X * 100 )div SpinEdit1.Value;
       Y2 := (Y * 100 )div SpinEdit1.Value;
       image1.Picture.assign(undoImage);
       circle(x1,y1,x2,y2);
    end;

  end;
end;

procedure TfrmMapEditor.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  x2,y2: Integer;
begin
  X2 := (X * 100 )div SpinEdit1.Value;
  Y2 := (Y * 100 )div SpinEdit1.Value;
  if FigureCombo.ItemIndex = 0 then
     pencil(x1,y1);
  if FigureCombo.ItemIndex = 1 then
     line(x1,y1,x2,y2);
  if FigureCombo.ItemIndex = 2 then
     triangle(x1,y1,x2,y2);
  if FigureCombo.ItemIndex = 3 then
     rectangle(x1,y1,x2,y2);
  if FigureCombo.ItemIndex = 4 then
     circle(x1,y1,x2,y2);
end;

procedure TfrmMapEditor.MenuItem12Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 2;
end;

procedure TfrmMapEditor.MenuItem13Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 3;
end;

procedure TfrmMapEditor.MenuItem14Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 5;
end;

procedure TfrmMapEditor.MenuItem16Click(Sender: TObject);
begin
  panel2.Visible:= not panel2.Visible;
end;

procedure TfrmMapEditor.MenuItem17Click(Sender: TObject);
begin
  ScrollBox2.Visible:= not ScrollBox2.Visible;
end;

procedure TfrmMapEditor.MenuItem18Click(Sender: TObject);
begin
  ShowMessage(LNG_MAPEDIT_HELP);
end;

procedure TfrmMapEditor.MenuItem5Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMapEditor.MenuItem7Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 0;
end;

procedure TfrmMapEditor.MenuItem8Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 1;
end;

procedure TfrmMapEditor.MenuItem9Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 4;
end;

procedure TfrmMapEditor.PColor1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssCtrl in Shift then
  begin
    if ColorDialog1.Execute then
      TPanel(Sender).Color:=ColorDialog1.Color;
    exit;
  end;
  if ssLeft in Shift then
  begin
    cbPen.ButtonColor:= TPanel(Sender).Color;
    cbPen1.ButtonColor:= cbPen.ButtonColor;
    updatePen;
  end;
  if ssRight in Shift then
  begin
    cbBrush.ButtonColor:= TPanel(Sender).Color;
    cbBrush1.ButtonColor:= cbBrush.ButtonColor;
    updateBrush;
  end;

end;



procedure TfrmMapEditor.PenModeComboChange(Sender: TObject);
begin
    updatePen;
end;

procedure TfrmMapEditor.PenStyleComboChange(Sender: TObject);
begin
    updatePen;
end;

procedure TfrmMapEditor.seBrushAlphaChange(Sender: TObject);
begin
  updateBrush;
end;

procedure TfrmMapEditor.sePenAlphaChange(Sender: TObject);
begin
    updatePen;
end;

procedure TfrmMapEditor.sePenChange(Sender: TObject);
begin
  updatePen;
end;

procedure TfrmMapEditor.SpeedButton1DblClick(Sender: TObject);
begin
end;

procedure TfrmMapEditor.SpeedButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;


procedure TfrmMapEditor.SpinEdit1Change(Sender: TObject);
begin
  Image1.Width:= Image1.Picture.Width * SpinEdit1.Value div 100;;
  Image1.Height:= Image1.Picture.Height * SpinEdit1.Value div 100;;
  image1.Refresh;
end;

procedure TfrmMapEditor.Action3Execute(Sender: TObject);
begin
    if SavePictureDialog1.Execute then
     Image1.Picture.SaveToFile(SavePictureDialog1.FileName);

end;

procedure TfrmMapEditor.Action1Execute(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
   Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
   Image1.Width:= Image1.Picture.Width * SpinEdit1.Value div 100;;
   Image1.Height:= Image1.Picture.Height * SpinEdit1.Value div 100;;
  end;
end;

procedure TfrmMapEditor.Action2Execute(Sender: TObject);
begin
  if OpenPictureDialog1.FileName = '' then
     Action3.Execute
  else
   Image1.Picture.SaveToFile(OpenPictureDialog1.FileName);
end;

end.

