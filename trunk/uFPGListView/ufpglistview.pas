unit uFPGListView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ClipBrd, uFPG, uLanguage, uinifile, uTools,
  uLoadImage, uColor16bits, uFrmMessageBox, IntfGraphics;

type
  TFPGListView = class(TListView)
  private
    { Private declarations }
    ffpg: TFPG;
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure Load_Images(progressBar: TProgressBar);
    procedure Insert_Images(lImages: TStringList; dir: string;
      var progressBar: TProgressBar);
    procedure Insert_Imagescb(var progressBar: TProgressBar);
    procedure add_items(index: word);
    procedure replace_item(index: word);
    procedure freeFPG;
  published
    { Published declarations }
    property Fpg: TFpg read Ffpg write Ffpg;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I uFPGListView_icon.lrs}
  RegisterComponents('FPG Editor', [TFPGListView]);
end;

procedure TFPGListView.Load_Images(progressBar: TProgressBar);
var
  Count: integer;
begin
  //Limpiamos la lista de imagenes
  LargeImages.Clear;
  Items.Clear;

  LargeImages.Width := inifile_sizeof_icon;
  LargeImages.Height := inifile_sizeof_icon;

  progressBar.Position := 0;
  progressBar.Show;
  progressBar.Repaint;
  for Count := 1 to Fpg.Count do
  begin
    with Fpg.images[Count] do
    begin
      add_items(Count);
      if (Count mod inifile_repaint_number) = 0 then
      begin
        progressBar.Position := (Count * 100) div Fpg.Count;
        progressBar.Repaint;
      end;
    end;
  end;

  progressBar.Hide;
end;


procedure TFPGListView.Insert_Images(lImages: TStringList; dir: string;
  var progressBar: TProgressBar);
var
  i: integer;
  bmp_src: TBitmap;
  ncpoints : Word;
  cpoints :   array[0..high(Word)*2] of Word;
  file_source, filename: string;
  index: word;
begin
  // Creamos el bitmap fuente y destino
  bmp_src := TBitmap.Create;
  // Se inializa la barra de progresión
  progressBar.Position := 0;
  progressBar.Show;
  progressBar.Repaint;


  for i := 0 to lImages.Count - 1 do
  begin

    index := Fpg.indexOfCode(Fpg.lastcode);
    if index <> 0 then
    begin
      if MessageDlg('El código: ' + IntToStr(Fpg.lastcode) +
        ' ya existe. ¿Desea sobrescribirlo?', mtConfirmation,
        [mbYes, mbNo], 0) = mrNo then
        continue;
    end;

    filename := lImages.Strings[i];

    // Se prepara la ruta del fichero
    file_source := prepare_file_source(Dir, filename);

    // Se carga la imagen
    ncpoints:=0;
    loadImageFile(bmp_src, file_source,ncpoints,cpoints);

  (*
  // Se incrementa el código de la imagen
  Fpg.last_code := Fpg.last_code + 1;

  // Busca hasta que encuentre un código libre
  while CodeExists(Fpg.last_code) do
    Fpg.last_code := Fpg.last_code + 1;
  *)

    // ver como meter fpgeditor3.1
    if index <> 0 then
    begin
      fpg.replace_bitmap(index, ChangeFileExt(filename, ''),
        ChangeFileExt(filename, ''), bmp_src,ncpoints,cpoints);
      replace_item(index);
    end
    else
    begin
      Fpg.Count := Fpg.Count + 1;
      fpg.add_bitmap(Fpg.Count, ChangeFileExt(filename, ''),
        ChangeFileExt(filename, ''), bmp_src,ncpoints,cpoints);
      add_items(Fpg.Count);
    end;
    Fpg.lastcode := Fpg.lastcode + 1;

    //bmp_src.FreeImage;
    progressBar.Position := ((i + 1) * 100) div lImages.Count;
    progressBar.Repaint;

  end;
  Fpg.lastcode := Fpg.lastcode - 1;
  bmp_src.Free;
  Fpg.update := True;
  Repaint;
  progressBar.Hide;
end;

procedure TFPGListView.Insert_Imagescb(var progressBar: TProgressBar);
var
  bmp_src: TBitmap;
  ncpoints : Word;
  cpoints :   array[0..high(Word)*2] of Word;

begin
  // Se inializa la barra de progresión
  progressBar.Position := 50;
  progressBar.Show;
  progressBar.Repaint;

  bmp_src := TBitmap.Create;
  bmp_src.PixelFormat := pf32bit;

  try
    bmp_src.LoadFromClipBoardFormat(cf_BitMap);
  except
    bmp_src.Destroy;
    progressBar.Hide;
    feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_CLIPBOARD_IMAGE], 0, 0);
    Exit;
  end;

  LargeImages.Width := inifile_sizeof_icon;
  LargeImages.Height := inifile_sizeof_icon;

  // Se incrementa el código de la imagen
  Fpg.lastcode := Fpg.lastcode + 1;

  // Busca hasta que encuentre un código libre
  while Fpg.CodeExists(Fpg.lastcode) do
    Fpg.lastcode := Fpg.lastcode + 1;

  // ver como meter fpgeditor3.1
  Fpg.Count := Fpg.Count + 1;
  fpg.add_bitmap(Fpg.Count, 'ClipBoard', 'ClipBoard', bmp_src,ncpoints,cpoints);
  add_items(Fpg.Count);


  progressBar.Hide;

  bmp_src.Destroy;

  Fpg.update := True;
end;

procedure TFPGListView.add_items(index: word);
var
  list_bmp: TListItem;
  bmp_dst: TBitMap;
begin

  // Pintamos el icono
  DrawProportional(Fpg.images[index].bmp, bmp_dst, color);

  list_bmp := Items.Add;

  list_bmp.ImageIndex := LargeImages.add(bmp_dst, nil);

  // Se establece el código del FPG
  list_bmp.Caption := NumberTo3Char(Fpg.images[index].graph_code);

  // Se añaden los datos de la imagen a la lista
  list_bmp.SubItems.Add(Fpg.images[index].fpname);
  list_bmp.SubItems.Add(Fpg.images[index].Name);

  list_bmp.SubItems.Add(IntToStr(Fpg.images[index].Width));
  list_bmp.SubItems.Add(IntToStr(Fpg.images[index].Height));
  list_bmp.SubItems.Add(IntToStr(Fpg.images[index].ncpoints));

end;

procedure TFPGListView.replace_item(index: word);
var
  list_bmp: TListItem;
  bmp_dst: TBitMap;
begin

  // Pintamos el icono
  DrawProportional(Fpg.images[index].bmp, bmp_dst, color);

  list_bmp := Items.Item[index - 1];

  LargeImages.Replace(index - 1, bmp_dst, nil);
  //list_bmp.ImageIndex :=

  // Se añaden los datos de la imagen a la lista
  list_bmp.SubItems.Strings[0] := Fpg.images[index].fpname;
  list_bmp.SubItems.Strings[1] := Fpg.images[index].Name;

  list_bmp.SubItems.Strings[2] := IntToStr(Fpg.images[index].Width);
  list_bmp.SubItems.Strings[3] := IntToStr(Fpg.images[index].Height);
  // list_bmp.SubItems.Strings[4]:=IntToStr(Fpg.images[index].ncpoints);

end;

procedure TFPGListView.FreeFPG;
begin
  FreeAndNil(ffpg);
end;


end.
