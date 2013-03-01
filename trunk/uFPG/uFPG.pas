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
  uFrmMessageBox, uLanguage, uColor16bits, uMAPGraphic, Dialogs, uTools;

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

  TFpg = class(TPersistent)
  private
    { Private declarations }
  public
    { Public declarations }
    Magic: array [0 .. 2] of char; {fpg, f16, c16}
    MSDOSEnd: array [0 .. 3] of byte;
    Version: byte;
    Gamma: array [0 .. 575] of byte;
    FPGFormat: byte;
    Palette: array [0 .. 767] of byte;
    images: array [1 .. MAX_NUM_IMAGES] of TMAPGraphic;
    active, update: boolean;
    source: String;
    needTable: boolean;
    Count: word;
    lastCode: word;
    loadPalette: boolean;
    comments : TMAPGraphic;
    table_16_to_8: array [0 .. 31, 0 .. 63, 0 .. 31] of byte;
    appName : String;
    appVersion : String;

    constructor Create;
    destructor Destroy; override;
    function CodeExists(code: word): boolean;
    function indexOfCode(code: word): word;
    procedure DeleteWithCode(code: word);
    procedure Initialize;
    procedure setMagic;
    procedure SaveToFile(var gFPG: TProgressBar);
    function LoadFromFile(str: string; var gFPG: TProgressBar): boolean;
    procedure Create_table_16_to_8;
    procedure Sort_Palette;
    procedure SaveMap(index: integer; filename: string);
    procedure add_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap ; ncpoints:word;cpoints :PWord);
    procedure replace_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap; ncpoints:word;cpoints :PWord );
    function isKnownFormat: boolean;
    function loadHeaderFromFile(fileName : String): Boolean;
    procedure loadHeaderFromStream( stream : TStream );
    procedure saveHeaderToStream(stream : TStream);
    function getFormat(var byte_size : Word): Integer ;
    function getBPP : Word;

  end;

function FPG_Test(str: string): boolean;
procedure stringToArray(var inarray: array of char; str: string; len: integer);
procedure writeDataBitmap( var f: TFileStream ;var bitmap : TBitmap; bytes_per_pixel : word; cdivformat : boolean =false ; palette : PByte = nil);


implementation


function TFpg.getBPP:Word;
begin
  result:=0;
  case FPGFormat of
    FPG1:
    begin
      result:=1;
    end;
    FPG8_DIV2:
    begin
      result:=8;
    end;
    FPG16, FPG16_CDIV:
    begin
      result:=16;
    end;
    FPG24:
    begin
      result:=24;
    end;
    FPG32:
    begin
      result:=32;
    end;
  end;
end;

function TFpg.getFormat(var byte_size : Word) :Integer;
begin
 Result := FPG_NULL;
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

function TFpg.isKnownFormat : Boolean;
var
  byte_size: Word;
begin
  result := getFormat(byte_size) <> FPG_NULL;
end;


function TFpg.loadHeaderFromFile(fileName : String): Boolean;
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
    loadHeaderFromStream(f);
  finally
    f.Free;
  end;

  Result:=True;
end;

procedure TFpg.loadHeaderFromStream(stream : TStream);
begin
  stream.Read(Magic, 3);
  stream.Read(MSDOSEnd, 4);
  stream.Read(Version, 1);
end;

procedure TFpg.saveHeaderToStream(stream : TStream);
begin
  stream.Write(Magic, 3);
  stream.Write(MSDOSEnd, 4);
  stream.Write(Version, 1);
end;


constructor TFpg.Create;
begin
  inherited Create;
  comments := TMAPGraphic.Create;
  Initialize;
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
    if images[i].code = code then
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
  if Count > 0 then
  begin
    for i := 1 to Count do
    begin
        FreeAndNil(images[i]);
    end;
  end;
  FreeAndNil(comments);
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
    if Images[i].code = code then
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

procedure TFpg.SaveToFile( var gFPG: TProgressBar);
var
  f: TFileStream;
  i : Word;
  graph_size: LongInt;
  bits_per_pixel: Word;
  widthForFPG1: Integer;
  Frames: Word;
  data_comments: array[0..31] of Byte;

begin

  bits_per_pixel:=getBPP;
  f := TFileStream.Create(source, fmCreate);
  saveHeaderToStream(f);

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;

  if bits_per_pixel = 8 then
  begin
    for i := 0 to 767 do
      Palette[i] := Palette[i] shr 2;

    f.Write(Palette, 768);
    f.Write(gamma, 576);

    for i := 0 to 767 do
      Palette[i] := Palette[i] shl 2;
  end;

  graph_size := 0;
  for i := 1 to Count do
  begin
    images[i].bitsPerPixel:=bits_per_pixel;
    images[i].CDIVFormat:= (FPGFormat= FPG16_CDIV);
    images[i].SaveToStream(f,true);
    gFPG.Position := (i * 100) div Count;
    gFPG.Repaint;
  end;

  FreeAndNil(comments);
  comments := TMAPGraphic.Create;
  comments.bitsPerPixel:=bits_per_pixel;
  comments.CDIVFormat:= (FPGFormat= FPG16_CDIV);
  comments.code:=1001;
  comments.SetSize(1,1);
  comments.name:=appVersion;
  comments.fpname:=appName;
  comments.SaveToStream(f,true);

  gFPG.Hide;

  f.Free;

  feMessageBox(LNG_STRINGS[LNG_INFO], LNG_STRINGS[LNG_CORRECT_SAVING], 0, 0);
end;

//-----------------------------------------------------------------------------
// LoadFPG: Carga un FPG a memoria.
//-----------------------------------------------------------------------------

function TFpg.LoadFromFile(str: string; var gFPG: TProgressBar): boolean;
var
  f: TStream;
  frames, length, speed: word;
  byte_size: Word;
  i : Integer;
  chr_comments : array[0..400] of Char;
  comemntslengt: Integer;
  fpgGraphic    :TMAPGraphic;
begin
  FPGFormat := FPG_NULL;

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
    loadHeaderFromStream(f);
  except
    f.Free;
    Exit;
  end;

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;
  byte_size := 0;

  FPGFormat := getFormat(byte_size);

  if (FPGFormat = FPG_NULL) then
  begin
    feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_WRONG_FPG], 0, 0);
    f.Free;
    Exit;
  end;

  try
    if (FPGFormat = FPG8_DIV2) then
    begin
      f.Read(palette, 768);
      f.Read(gamma, 576);

      for i := 0 to 767 do
        palette[i] := palette[i] shl 2;

      loadPalette := True;
      needTable := True;
    end;

    Count := 0;

    while f.Position < f.Size do
    begin
      fpgGraphic:= TMAPGraphic.Create;
      fpgGraphic.bitsPerPixel:= getBPP;
      fpgGraphic.CDIVFormat:= (FPGFormat = FPG16_CDIV);
      fpgGraphic.LoadFromStream(f,true);

      if fpgGraphic.code=1001 then
      begin
        FreeAndNil(comments);
        comments:=fpgGraphic;
      end else begin
        Count := Count + 1;
        images[Count] := fpgGraphic;
      end;

      gFPG.Position := (f.Position * 100) div f.Size;
      gFPG.Repaint;

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
    color_index := Find_Color(i, palette[(i - 1) * 3],
      palette[((i - 1) * 3) + 1], palette[((i - 1) * 3) + 2],palette);
    // Intercambio de colores
    R := palette[color_index * 3];
    G := palette[(color_index * 3) + 1];
    B := palette[(color_index * 3) + 2];

    palette[color_index * 3] := palette[i * 3];
    palette[(color_index * 3) + 1] := palette[(i * 3) + 1];
    palette[(color_index * 3) + 2] := palette[(i * 3) + 2];

    palette[i * 3] := R;
    palette[(i * 3) + 1] := G;
    palette[(i * 3) + 2] := B;

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
      palette[(i * 3)] shr 3,
      palette[(i * 3) + 1] shr 2,
      palette[(i * 3) + 2] shr 3] := i;
end;

procedure TFpg.SaveMap(index: integer; filename: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(filename, fmCreate);

  images[index].bitsPerPixel:=getBPP;
  images[index].CDIVFormat:= (FPGFormat = FPG16_CDIV);
  images[index].SaveToStream(f);

  f.Free;
end;

Procedure TFpg.setMagic;
begin
 case FPGFormat of
  FPG1:
    Magic := 'f01';
  FPG8_DIV2:
    Magic := 'fpg';
  FPG16:
    Magic := 'f16';
  FPG16_CDIV:
    Magic := 'c16';
  FPG24:
    Magic := 'f24';
  FPG32:
    Magic := 'f32';
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

 source:='';
 MSDOSEnd[0] := 26;
 MSDOSEnd[1] := 13;
 MSDOSEnd[2] := 10;
 MSDOSEnd[3] := 0;
 Version     := 0;
 FPGFormat:=FPG32;
 comments.fpname:='';
 comments.name:='';

end;

//Comprobamos si es un archivo FPG sin comprimir
function FPG_Test(str: string): boolean;
var
  fpg : TFpg;
begin
  Result := False;
  fpg := TFpg.Create;

  if fpg.loadHeaderFromFile(str) then
     result:= fpg.isKnownFormat;

  FreeAndNil(fpg);
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

// Añadir index
procedure TFPG.add_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap ; ncpoints:word;cpoints :PWord);
var
  i: Word;
begin
  // Establece el código
  FreeAndNil( images[index]);
  images[index]:= TMAPGraphic.Create;
  images[index].code  := lastcode;

  // Se establecen los datos de la imagen
  images[index].fpname:=FileName;
  images[index].name:=GraphicName;
  images[index].width  := bmp_src.Width;
  images[index].height := bmp_src.Height;
  images[index].CPointsCount := ncpoints;
  for i:=0 to (ncpoints*2) -1 do
     images[index].cpoints[i]:=cpoints[i];

  // Se crea la imagen resultante
  images[index].bitsPerPixel:=getBPP;
  images[index].CDIVFormat:= (FPGFormat= FPG16_CDIV);
  images[index].bPalette:=Palette;
  images[index].CreateBitmap(bmp_src);

end;

// Añadir index
procedure TFPG.replace_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TBitmap ; ncpoints:word;cpoints :PWord);
var
  i : word;
begin
  // Establece el código
  images[index].code  := lastcode;

  // Se establecen los datos de la imagen
  images[index].fpname:=FileName;
  images[index].name:=GraphicName;
  images[index].width  := bmp_src.Width;
  images[index].height := bmp_src.Height;
  if ncpoints>0 then
  begin
    images[index].CPointsCount:= ncpoints;
    for i:=0 to (ncpoints*2) -1 do
       images[index].cpoints[i]:=cpoints[i];
  end;

  // Se crea la imagen resultante
  images[index].bitsPerPixel:=getBPP;
  images[index].CDIVFormat:= (FPGFormat= FPG16_CDIV);
  images[index].bPalette:=Palette;
  images[index].CreateBitmap(bmp_src);

end;


end.