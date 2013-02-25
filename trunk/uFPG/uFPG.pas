(*
 *  FPG Editor : Edit FPG file from DIV2, FENIX and CDIV
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

unit uFPG;

{$mode objfpc}{$H+}

interface

uses LCLIntf, LCLType, SysUtils, Forms, Classes,
  Graphics, FileUtil, ComCtrls, IntfGraphics,
  uFrmMessageBox, uLanguage, uColor16bits, uMap, Dialogs, uTools;

const
  MAX_NUM_IMAGES = 999;
  FPG_NULL = 255;
  FPG1 = 0;
  FPG8_DIV2 = 1;
  FPG16 = 2;
  FPG16_CDIV = 3;
  FPG24 = 4;
  FPG32 = 5;
  STRFPG1 = 'FPG 1 bit (All)';
  STRFPG8 = 'FPG 8 bits (All)';
  STRFPG16 = 'FPG 16 bits (Fenix/BennuGD)';
  STRFPGCDIV16 = 'FPG 16 bits (CDIV)';
  STRFPG24 = 'FPG 24 bits ';
  STRFPG32 = 'FPG 32 bits (BennuGD)';

type
  TFpgHeader = class
  private
    { Private declarations }
  public
    { Public declarations }
    Magic: array [0 .. 2] of char; {fpg, f16, c16}
    MSDOSEnd: array [0 .. 3] of byte;
    Version: byte;
    Palette: array [0 .. 767] of byte;
    Gamma: array [0 .. 575] of byte;
    function isKnownType: boolean;
    function loadFromFile(fileName : String): Boolean;
    procedure loadFromStream( stream : TStream );
    procedure saveToStream(stream : TStream);
    function getFPGType(var byte_size : Word): Integer ;
    //published

  end;


  TFpgGraphic = class
  private
    { Private declarations }
  public
    { Public declarations }
    graph_code: longint;
    fpname: array [0 .. 11] of char;
    Name: array [0 .. 31] of char;
    Width: longint;
    Height: longint;
    points: longint;
    control_points: array [0 .. 2047] of short;
    bmp: TBitMap;
    graph_size: longint;
    destructor Destroy; override;
  end;

  TFpg = class
  private
    { Private declarations }
  public
    { Public declarations }
    header: TFpgHeader;
    images: array [1 .. MAX_NUM_IMAGES] of TFpgGraphic;
    FPGtype: byte;
    active, update: boolean;
    source: string;

    needTable: boolean;
    Count: word;
    lastCode: word;
    loadPalette: boolean;
    table_16_to_8: array [0 .. 31, 0 .. 63, 0 .. 31] of byte;

    constructor Create;
    destructor Destroy; override;
    function Create_hpal: HPALETTE;
    function CodeExists(code: word): boolean;
    function indexOfCode(code: word): word;
    procedure DeleteWithCode(code: word);
    procedure Initialize;
    procedure setFileType;
    procedure Save(var gFPG: TProgressBar);
    function Load(str: string; var gFPG: TProgressBar): boolean;
    procedure Create_table_16_to_8;
    procedure Sort_Palette;
    procedure SaveMap(index: integer; filename: string);
    procedure add_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap );
    procedure replace_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap );

  end;

function FPG_Test(str: string): boolean;
procedure stringToArray(var inarray: array of char; str: string; len: integer);
procedure writeDataBitmap( var f: TFileStream ;var bitmap : TBitmap; bytes_per_pixel : word; cdivformat : boolean =false ; palette : PByte = nil);
function FPGCreateBitmap(var bmp_src : TBitmap; FPGtype : integer; palette:PByte  ): TBitmap;

implementation


function TFpgHeader.getFPGType(var byte_size : Word) :Integer;
begin
 // Ficheros de 1 bit
 if (Magic[0] = 'f') and (Magic[1] = '0') and
   (Magic[2] = '1') and (MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0) then
 begin
   Result := FPG1;
   byte_size := 0;
 end;
 // Ficheros de 8 bits para DIV2, FENIX y CDIV
 if (Magic[0] = 'f') and (Magic[1] = 'p') and
   (Magic[2] = 'g') and (MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0) then
 begin
   Result := FPG8_DIV2;
   byte_size := 1;
 end;
 // Ficheros de 16 bits para FENIX
 if (Magic[0] = 'f') and (Magic[1] = '1') and
   (Magic[2] = '6') and (MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0) then
 begin
   Result := FPG16;
   byte_size := 2;
 end;

 // Ficheros de 16 bits para CDIV
 if (Magic[0] = 'c') and (Magic[1] = '1') and
   (Magic[2] = '6') and (MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0) then
 begin
   Result := FPG16_CDIV;
   byte_size := 2;
 end;

 // Ficheros de 24 bits
 if (Magic[0] = 'f') and (Magic[1] = '2') and
   (Magic[2] = '4') and (MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0) then
 begin
   Result := FPG24;
   byte_size := 3;
 end;

 // Ficheros de 32 bits
 if (Magic[0] = 'f') and (Magic[1] = '3') and
   (Magic[2] = '2') and (MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0) then
 begin
   Result := FPG32;
   byte_size := 4;
 end;

end;

function TFpgHeader.isKnownType : Boolean;
var
  byte_size: Word;
begin
  result := getFPGType(byte_size) <> FPG_NULL;
end;


function TFpgHeader.loadFromFile(fileName : String): Boolean;
var
  f : TFileStream;
begin
  Result := False;

  if not FileExistsUTF8(fileName) { *Converted from FileExists*  } then
    Exit;

  try
    f := TFileStream.Create(fileName, fmOpenRead);
  except
    Exit;
  end;

  try
    loadFromStream(f);
  finally
    f.Free;
  end;

  Result:=True;
end;

procedure TFpgHeader.loadFromStream(stream : TStream);
begin
  stream.Read(Magic, 3);
  stream.Read(MSDOSEnd, 4);
  stream.Read(Version, 1);
end;

procedure TFpgHeader.saveToStream(stream : TStream);
begin
  stream.Write(Magic, 3);
  stream.Write(MSDOSEnd, 4);
  stream.Write(Version, 1);
end;

destructor TFpgGraphic.Destroy;
begin
  FreeAndNil(bmp);
  inherited Destroy;
end;


constructor TFpg.Create;
begin
  inherited Create;
  header := TFpgHeader.Create;
  Initialize;
end;

function TFpg.Create_hpal: HPALETTE;
var
  pal: PLogPalette;
  i: longint;
begin
  pal := nil;
  result := 0;
  try
    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);

    pal^.palVersion := $300;
    pal^.palNumEntries := 256;

    for i := 0 to 255 do
    begin
      pal^.palPalEntry[i].peRed := header.palette[(i * 3)];
      pal^.palPalEntry[i].peGreen := header.palette[(i * 3) + 1];
      pal^.palPalEntry[i].peBlue := header.palette[(i * 3) + 2];
      pal^.palPalEntry[i].peFlags := 0;
    end;

    result := CreatePalette(pal^);

  finally
    FreeMem(pal);
  end;
end;

//-----------------------------------------------------------------------------
// CodeExists: Comprueba si existe el código del gráfico en el FPG
//-----------------------------------------------------------------------------

function TFpg.CodeExists(code: word): boolean;
begin
   Result:= (indexOfCode(code) <> 0);
end;

function TFpg.indexOfCode(code: word): word;
var
  i: word;
begin
  indexOfCode := 0;

  if (code < 1) or (code > MAX_NUM_IMAGES) or (Count < 1) then
  begin
    indexOfCode := 0;
    Exit;
  end;

  for i := 1 to Count do
    if images[i].graph_code = code then
    begin
      indexOfCode := i;
      break;
    end;
end;

//-----------------------------------------------------------------------------
// FreeFPG: Libera la memoria reservada e inicializa el FPG
//-----------------------------------------------------------------------------

destructor TFpg.Destroy;
var
  i: word;
begin
  FreeAndNil(header);
  if Count > 0 then
  begin
    for i := 1 to Count do
    begin
        FreeAndNil(images[i]);
    end;
  end;

  inherited Destroy;
end;


//-----------------------------------------------------------------------------
// DeleteWithCode: Elimina un elemento de FPG con el código
//-----------------------------------------------------------------------------

procedure TFpg.DeleteWithCode(code: word);
var
  i,j: word;
begin
  if (Count < 1) then
    Exit;

  for i := 1 to Count  do
  begin
    if Images[i].graph_code = code then
    begin
      FreeAndNil(Images[i]);
      break;
    end;
  end;
  if i < Count then
    for j:=i to Count do
    begin
       Images[j]:=Images[j+1];
    end;
  Count := Count - 1;
end;

function IntToBin ( value: LongInt; digits: integer ): string;
begin
  result := StringOfChar ( '0', digits ) ;
  while value > 0 do begin
    if ( value and 1 ) = 1 then
        result [ digits ] := '1';
    dec ( digits ) ;
    value := value shr 1;
  end;
end;

//-----------------------------------------------------------------------------
// Save: Guarda el FPG actual a disco.
//-----------------------------------------------------------------------------

procedure TFpg.Save( var gFPG: TProgressBar);
var
  f: TFileStream;
  i : Word;
  graph_size: LongInt;
  bytes_per_pixel: Word;
  widthForFPG1: Integer;
  Frames: Word;

begin
  bytes_per_pixel := 0;
  case FPGtype of
    FPG1:
    begin
      bytes_per_pixel := 0;
    end;
    FPG8_DIV2:
    begin
      bytes_per_pixel := 1;
    end;
    FPG16, FPG16_CDIV:
    begin
      bytes_per_pixel := 2;
    end;
    FPG24:
    begin
      bytes_per_pixel := 3;
    end;
    FPG32:
    begin
      bytes_per_pixel := 4;
    end;
  end;

  f := TFileStream.Create(source, fmCreate);

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;
  header.saveToStream(f);
  (*
  f.Write(Header.Magic, 3);
  f.Write(Header.MSDOSEnd, 4);
  f.Write(Header.Version, 1);
  *)
  if FPGtype = FPG8_DIV2 then
  begin
    for i := 0 to 767 do
      Header.Palette[i] := Header.Palette[i] shr 2;

    f.Write(Header.Palette, 768);
    f.Write(Header.gamma, 576);

    for i := 0 to 767 do
      Header.Palette[i] := Header.Palette[i] shl 2;
  end;

  graph_size := 0;
  for i := 1 to Count do
  begin
    if FPGtype <> FPG1 then
    begin
      graph_size := (Images[i].Width * Images[i].Height * bytes_per_pixel) + 64;
    end else begin
      widthForFPG1 := Images[i].Width;
      if (Images[i].Width mod 8) <> 0 then
        widthForFPG1 := widthForFPG1 + 8 - (Images[i].Width mod 8);
      graph_size := (widthForFPG1 div 8) * Images[i].Height + 64;
    end;

    if Images[i].points > 0  then
      graph_size := graph_size + (Images[i].points * 4);

    (* BennuGD no comtempla el límite 4096, más info en la lectura de un MAP
    if ((Images[i].points > 0) and (Images[i].points <> 4096)) then
      graph_size := graph_size + (Images[i].points * 4);
    if (Images[i].points = 4096) then
      graph_size := graph_size + 6;
    *)

    f.Write(Images[i].graph_code, 4);
    f.Write(graph_size, 4);
    f.Write(Images[i].Name, 32);
    f.Write(Images[i].fpname, 12);
    f.Write(Images[i].Width, 4);
    f.Write(Images[i].Height, 4);
    f.Write(Images[i].points, 4);

    if ((Images[i].points > 0) and (Images[i].points <> 4096)) then
      f.Write(Images[i].control_points, Images[i].points * 4);

    if (Images[i].points = 4096) then
    begin
      Frames:=0;
      f.Read(Frames, 2);
      f.Read(Frames, 2); // Length
      f.Read(Frames, 2);  // Speed
     // f.Seek(length * 2, soFromCurrent);
    end;

    writeDataBitmap(f,Images[i].bmp,bytes_per_pixel, (FPGtype = FPG16_CDIV), header.Palette);

    gFPG.Position := (i * 100) div Count;
    gFPG.Repaint;
  end;

  gFPG.Hide;

  f.Free;

  feMessageBox(LNG_STRINGS[LNG_INFO], LNG_STRINGS[LNG_CORRECT_SAVING], 0, 0);
end;

//-----------------------------------------------------------------------------
// LoadFPG: Carga un FPG a memoria.
//-----------------------------------------------------------------------------

function TFpg.Load(str: string; var gFPG: TProgressBar): boolean;
var
  f: TStream;
  frames, length, speed: word;
  byte_size: Word;
  i : Integer;
begin
  FPGtype := FPG_NULL;
  FreeAndNil(header);
  header:=TFpgHeader.Create();

  Result := False;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
    Exit;

  //if not FPG_Test(str) then
  //begin
  //  zipfile:= TZipFile.Create(frmMain);
  //  zipfile.FileName:=str;
  //  zipfile.Activate;
  //  f:=zipfile.GetFileStream(ExtractFileNameOnly(str),bufflen);
  //  zipfile.Destroy;
  //end else
  begin
    try
      f := TFileStream.Create(str, fmOpenRead);
    except
      Exit;
    end;
  end;

  try
    header.loadFromStream(f);
  except
    f.Free;
    Exit;
  end;

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;
  byte_size := 0;

  FPGtype := header.getFPGType(byte_size);

  if (FPGtype = FPG_NULL) then
  begin
    feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_WRONG_FPG], 0, 0);
    f.Free;
    Exit;
  end;

  try
    if (FPGtype = FPG8_DIV2) then
    begin
      f.Read(header.palette, 768);
      f.Read(header.gamma, 576);

      for i := 0 to 767 do
        header.palette[i] := header.palette[i] shl 2;

      loadPalette := True;
      needTable := True;
    end;

    Count := 0;
    while f.Position < f.Size do
    begin
      Count := Count + 1;
      images[Count] := TFpgGraphic.Create;

      // Establecemos la imagen
      with images[Count] do
      begin
        f.Read(graph_code, 4);
        f.Read(graph_size, 4);
        f.Read(Name, 32);
        f.Read(fpname, 12);
        f.Read(Width, 4);
        f.Read(Height, 4);
        f.Read(points, 4);

        // Leemos los puntos de control del bitmap

        if points > 0 then
        begin
          f.Read(control_points, points * 4);
        end;
        (* BennuGD no tiene el límite 4096, ver carga de map para más informacion
        if ((points > 0) and (points <> 4096)) then
        begin
          f.Read(control_points, points * 4);
        end;

        if (points = 4096) then
        begin
          f.Read(frames, 2);
          f.Read(length, 2);
          f.Read(speed, 2);
          f.Seek(length * 2, soFromCurrent);
        end;
        *)

        bmp:=loadDataBitmap(f,header.palette,width,height, byte_size, FPGtype=FPG16_CDIV);

        gFPG.Position := (f.Position * 100) div f.Size;
        gFPG.Repaint;
      end;  // end with
    end; // end wile
    gFPG.Hide;
    Result := True;
  finally
    f.Free;
  end;
end;




procedure TFpg.Sort_Palette;
var
  R, G, B, i, color_index: integer;
begin
  i := 1;

  repeat
    // Buscamos el color que más se parece al anterior
    color_index := Find_Color(i, Header.palette[(i - 1) * 3],
      Header.palette[((i - 1) * 3) + 1], Header.palette[((i - 1) * 3) + 2],Header.palette);
    // Intercambio de colores
    R := Header.palette[color_index * 3];
    G := Header.palette[(color_index * 3) + 1];
    B := Header.palette[(color_index * 3) + 2];

    Header.palette[color_index * 3] := Header.palette[i * 3];
    Header.palette[(color_index * 3) + 1] := Header.palette[(i * 3) + 1];
    Header.palette[(color_index * 3) + 2] := Header.palette[(i * 3) + 2];

    Header.palette[i * 3] := R;
    Header.palette[(i * 3) + 1] := G;
    Header.palette[(i * 3) + 2] := B;

    i := i + 1;
  until i >= 255;
end;

procedure TFpg.Create_Table_16_to_8;
var
  i: byte;
  r, g, b: byte;
begin
  for r := 0 to 31 do
    for g := 0 to 63 do
      for b := 0 to 31 do
        table_16_to_8[r, g, b] := 0;

  for i := 0 to 255 do
    table_16_to_8[
      Header.palette[(i * 3)] shr 3,
      Header.palette[(i * 3) + 1] shr 2,
      Header.palette[(i * 3) + 2] shr 3] := i;
end;

procedure TFpg.SaveMap(index: integer; filename: string);
var
  f: TFileStream;
  byte_size: Word;
  MAPHeader: file_str_map;
  i : Word;
  Frames : Word;
begin
  byte_size := 0;
  case FPGtype of
    FPG1:
    begin
      byte_size := 0;
      stringToArray(MAPHeader.Magic, 'm01', 3);
    end;
    FPG8_DIV2:
    begin
      byte_size := 1;
      stringToArray(MAPHeader.Magic, 'map', 3);
    end;
    FPG16, FPG16_CDIV:
    begin
      byte_size := 2;
      stringToArray(MAPHeader.Magic, 'm16', 3);
    end;
    FPG24:
    begin
      byte_size := 3;
      stringToArray(MAPHeader.Magic, 'm24', 3);
    end;
    FPG32:
    begin
      byte_size := 4;
      stringToArray(MAPHeader.Magic, 'm32', 3);
    end;
  end;


  MAPHeader.MSDOSEnd[0]:= 26;
  MAPHeader.MSDOSEnd[1]:= 10;
  MAPHeader.MSDOSEnd[2]:= 13;
  MAPHeader.MSDOSEnd[3]:= 0;

  f := TFileStream.Create(filename, fmCreate);

  f.Write(MAPHeader.Magic, 3);
  f.Write(MAPHeader.MSDOSEnd, 4);
  f.Write(Header.Version, 1);

  MAPHeader.Width := Images[index].Width;
  MAPHeader.Height := Images[index].Height;
  f.Write(MAPHeader.Width, 2);
  f.Write(MAPHeader.Height, 2);

  f.Write(Images[index].graph_code, 4);
  f.Write(Images[index].Name, 32);

  if FPGtype = FPG8_DIV2 then
  begin
    for i := 0 to 767 do
      Header.Palette[i] := Header.Palette[i] shr 2;

    f.Write(Header.Palette, 768);
    f.Write(Header.gamma, 576);

    for i := 0 to 767 do
      Header.Palette[i] := Header.Palette[i] shl 2;
  end;

  MAPHeader.ncpoints := Images[index].points;
  f.Write(MAPHeader.ncpoints, 2);

  if MAPHeader.ncpoints > 0 then
    f.Write(Images[index].control_points, MAPHeader.ncpoints * 4);

  (* Mismo caso que en la Lectura, BennuGD no controla el valor 4096,
     por lo que soporta más de 4096 puntos de control, si se necesita implementar
     esta funcionalidad hay que ver que hace DIV
  if ((MAPHeader.ncpoints > 0) and (MAPHeader.ncpoints <> 4096)) then
    f.Write(Images[index].control_points, MAPHeader.ncpoints * 4);
  if (MAPHeader.ncpoints = 4096) then
  begin
    Frames:=0;
    f.Read(Frames, 2);
    f.Read(Frames, 2); // Length
    f.Read(Frames, 2);  // Speed
   // f.Seek(length * 2, soFromCurrent);
  end;
  *)

  writeDataBitmap(f, Images[index].bmp,byte_size ,(FPGtype = FPG16_CDIV), header.Palette);

  f.Free;

end;

Procedure TFpg.setFileType;
begin
 case FPGtype of
  FPG1:
    header.Magic := 'f01';
  FPG8_DIV2:
    header.Magic := 'fpg';
  FPG16:
    header.Magic := 'f16';
  FPG16_CDIV:
    header.Magic := 'c16';
  FPG24:
    header.Magic := 'f24';
  FPG32:
    header.Magic := 'f32';
 end;
end;

//-----------------------------------------------------------------------------
// initialize: Inicializa el FPG
//-----------------------------------------------------------------------------

Procedure TFpg.Initialize;
begin
 active   := true;
 Count   := 0;
 lastCode := 0;
 needTable:= false;
 header.MSDOSEnd[0] := 26;
 header.MSDOSEnd[1] := 13;
 header.MSDOSEnd[2] := 10;
 header.MSDOSEnd[3] := 0;
 header.Version     := 0;
end;

//Comprobamos si es un archivo FPG sin comprimir
function FPG_Test(str: string): boolean;
var
  header : TFpgHeader;
begin
  Result := False;
  header := TFpgHeader.Create;

  if header.loadFromFile(str) then
     result:= header.isKnownType;

  FreeAndNil(header);
end;

procedure stringToArray(var inarray: array of char; str: string; len: integer);
var
  i: integer;
begin
  for i := 0 to len - 1 do
  begin
    if i >= length(str) then
      inarray[i] := char(0)
    else
      inarray[i] := str[i + 1];
  end;
end;

procedure writeDataBitmap( var f: TFileStream ;var bitmap : TBitmap; bytes_per_pixel : word; cdivformat : boolean =false; palette : PByte =nil);
var
  lazBMP : TLazIntfImage;
  byte_line: array [0 .. 16383] of byte;
  byteForFPG1: byte;
  insertedBits: integer;
  p_bytearray: PByteArray;
  j, k: word;
begin
  lazBMP := bitmap.CreateIntfImage;

  for k := 0 to bitmap.Height - 1 do
  begin
    p_bytearray := lazBmp.GetDataLineStart(k);
    case bytes_per_pixel of
      0:
      begin
          insertedBits := 0;
          byteForFPG1 := 0;
          for j := 0 to bitmap.Width - 1 do
          begin
            if (p_bytearray^[j * 4] shr 7) = 1 then
            begin
              byteForFPG1 := byteForFPG1 or 1; // bit más alto en 8 bits
            end;
            insertedBits := insertedBits + 1;
            if (insertedBits = 8) then
            begin
              f.Write(byteForFPG1, 1);
              byteForFPG1 := 0;
              insertedBits := 0;
            end else
              byteForFPG1 := byteForFPG1 shl 1;
          end;
          if insertedBits > 0 then
          begin
            byteForFPG1 := byteForFPG1 shl (7 - insertedBits);
            f.Write(byteForFPG1, 1);
          end;
     end;
     1:
     begin
        for j := 0 to bitmap.Width - 1 do
        begin
          byte_line[j]:=0;
          if p_bytearray^[j * 4 + 3 ] <> 0 then
             byte_line[j]:=Find_Color(0,p_bytearray^[j * 4+2],p_bytearray^[j * 4+1],p_bytearray^[j * 4],palette);
        end;
        f.Write(byte_line, bitmap.Width);
     end;
     2:
     begin
       for j := 0 to bitmap.Width - 1 do
       begin
           if cdivformat then
             if p_bytearray^[j * 4 + 3 ] <> 0 then
                set_RGB16(byte_line[j*2+1], byte_line[j*2],p_bytearray^[j * 4],p_bytearray^[j * 4+1],p_bytearray^[j * 4+2] )
             else
               set_RGB16(byte_line[j*2+1], byte_line[j*2],248,0,248 )
           else begin
            byte_line[j*2]:=0;
            byte_line[j*2+1]:=0;
            if p_bytearray^[j * 4 + 3 ] <> 0 then
              set_BGR16(byte_line[j*2+1], byte_line[j*2],p_bytearray^[j * 4],p_bytearray^[j * 4+1],p_bytearray^[j * 4+2] )

           end;
       end;
       f.Write(byte_line, bitmap.Width*bytes_per_pixel);
     end;
     3:
     begin
       for j := 0 to bitmap.Width - 1 do
       begin
         byte_line[j*3]:=0;
         byte_line[j*3+1]:=0;
         byte_line[j*3+2]:=0;
         if p_bytearray^[j * 4 + 3 ] <> 0 then
         begin
           byte_line[j*3]:= p_bytearray^[j * 4];
           byte_line[j*3+1]:=p_bytearray^[j * 4 + 1];
           byte_line[j*3+2]:=p_bytearray^[j * 4 + 2 ];
         end;
       end;
       f.Write(byte_line, bitmap.Width*bytes_per_pixel);
     end;
     else  // 32 bits
     begin
         f.Write(p_bytearray^, bitmap.Width * bytes_per_pixel);
     end;
     end;

  end;
  lazBMP.Free;
end;

function FPGCreateBitmap(var bmp_src : TBitmap; FPGtype : integer ; palette : PByte ): TBitmap;
begin
 // Se crea la imagen resultante
 result   := TBitMap.Create;
 result.PixelFormat:=pf32bit;
 result.SetSize(bmp_src.Width, bmp_src.Height);

 CopyPixels(result,bmp_src,0,0);
 if bmp_src.PixelFormat<>pf32bit then
    setAlpha(result,255);
 case FPGtype of
    FPG1:
    begin
          simulate1bppIn32bpp(result);
    end;
    FPG8_DIV2:
    begin
         simulate8bppIn32bpp(result,palette);
    end;
    FPG16:
    begin
         colorToTransparent(result,clBlack,true );
    end;
    FPG16_CDIV:
    begin
         colorToTransparent(result,clFuchsia,true );
    end;
    FPG24:
    begin
         colorToTransparent(result,clBlack );
    end;
 end;

end;

// Añadir index
procedure TFPG.add_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap );
begin
  // Establece el código
  FreeAndNil( images[index]);
  images[index]:= TFpgGraphic.Create;
  images[index].graph_code  := lastcode;

  // Se establecen los datos de la imagen
  stringToArray(images[index].fpname,FileName,12);
  stringToArray(images[index].name,GraphicName,32);
  images[index].width  := bmp_src.Width;
  images[index].height := bmp_src.Height;
  images[index].points := 0;

  // Se crea la imagen resultante
  images[index].bmp    := FPGCreateBitmap(bmp_src,FPGtype, header.palette);

end;

// Añadir index
procedure TFPG.replace_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap );
begin
  // Establece el código
  images[index].graph_code  := lastcode;

  // Se establecen los datos de la imagen
  stringToArray(images[index].fpname,FileName,12);
  stringToArray(images[index].name,GraphicName,32);
  images[index].width  := bmp_src.Width;
  images[index].height := bmp_src.Height;

  images[index].bmp    := FPGCreateBitmap(bmp_src,FPGtype,header.Palette);

end;


end.