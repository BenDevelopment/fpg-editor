{ uMAPGraphic class to manipulate MAP files for DIV like Programs

  Copyright (C) 2013 DCelso <- gmail.com

  Esta código es software libre; usted puede redistribuirlo y/o modificarlo
  bajo los términos de la GNU General Public License publicada por la Free
  Software Foundation; sea versión 2 de la licencia, o (a su opción)
  cualquier posterior versión.

  Este código se distribuye con la esperanza de que sea útil, pero SIN
  NINGUNA GARANTÍA, ni siquiera la garantía implícita de COMERCIABILIDAD o
  IDONEIDAD PARA UN DETERMINADO FIN.  Consulte la GNU General Public License
  para obtener más detalles.

  Una copia de la Licencia Pública General de GNU está disponible en la
  World Wide Web en <http://www.gnu.org/copyleft/gpl.html>. También puede
  obtenerlo por escrito a la Free Software Foundation, Inc., 59 Temple Place -
  Suite 330, Boston, MA 02111-1307, USA.
}

unit uMAPGraphic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  IntfGraphics, FileUtil;

type
  { TMAPGraphic }

  TMAPGraphic = class(TBitmap)
  private
    Magic: array [0 .. 2] of Char;
    MSDOSEnd: array [0 .. 3] of Byte;
    Version: Byte;
    //      width          : word;  // Not needed, stored in TBitmap
    //      height         : word;  // Not needed, stored in TBitmap
    Code: dword;
    FPName: array [0 .. 11] of Char; // Needed for FPG Graphics
    Name: array [0 .. 31] of Char;
    bPalette: array [0 .. 767] of Byte;
    Gamma: array [0 .. 575] of Byte;
    NCPoints: Word;
    CPoints :   array[0..high(Word)*2] of Word;
    GraphSize: LongInt;               // Needed for FPG Graphics
    FbitsPerPixel: Word;            // to get faster this attribute.
    FCDIVFormat: Boolean;            // to get faster this attribute.
    procedure loadDataBitmap(Stream: TStream; bytes_per_pixel: Word);
    procedure writeDataBitmap(Stream: TStream; bytes_per_pixel: Word);
    procedure RGB24toBGR16(var byte0, byte1: Byte; red, green, blue: Byte);
    procedure RGB24toRGB16(var byte0, byte1: Byte; red, green, blue: Byte);
    procedure BGR16toRGB24(byte0, byte1: Byte; var red, green, blue: Byte);
    procedure RGB16toRGB24(byte0, byte1: Byte; var red, green, blue: Byte);
    function FindColor(index, rc, gc, bc: Integer): Integer;
    procedure SetFormat(cdiv : Boolean);
    procedure SetBitsPerPixel(bpp: word);
    procedure setMagic;
  public
    procedure LoadFromFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToFile(const Filename: string); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream; onFPG: Boolean);
    class function GetFileExtensions: string; override;
  published
    property CDIVFormat : Boolean read FCDIVFormat write SetFormat default False;
    property bitsPerPixel : Word read FbitsPerPixel write setBitsPerPixel default 32;
  end;

implementation

{ TMAPGraphic }

class function TMAPGraphic.GetFileExtensions: string;
begin
  Result := 'map';
end;

procedure TMAPGraphic.LoadFromFile(const Filename: string);
var
  f: TFileStream;
begin
  if not FileExistsUTF8(Filename) { *Converted from FileExists*  } then
    Exit;

  try
    f := TFileStream.Create(Filename, fmOpenRead);
  except
    Exit;
  end;

  try
    LoadFromStream(f);
  finally
    f.Free;
  end;

end;

procedure TMAPGraphic.LoadFromStream(Stream: TStream);
var
  frames: word;
  length: word;
  speed: word;
  tmpWidth: word;
  tmpHeight: word;
  i: integer;
  bytes_per_pixel :Word;
begin
  Stream.Read(Magic, 3);
  Stream.Read(MSDOSEnd, 4);
  Stream.Read(Version, 1);

  bitsPerPixel := 0;
  CDIVFormat := False;
  // Ficheros de 1 bit
  if (Magic[0] = 'm') and (Magic[1] = '0') and (Magic[2] = '1') and
    (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
    (MSDOSEnd[3] = 0) then
  begin
    bitsPerPixel := 0;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (Magic[0] = 'm') and (Magic[1] = 'a') and (Magic[2] = 'p') and
    (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
    (MSDOSEnd[3] = 0) then
  begin
    bitsPerPixel := 8;
  end;
  // Ficheros de 16 bits para FENIX
  if (Magic[0] = 'm') and (Magic[1] = '1') and (Magic[2] = '6') and
    (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
    (MSDOSEnd[3] = 0) then
  begin
    bitsPerPixel := 16;
  end;

  // Ficheros de 16 bits para CDIV
  if (Magic[0] = 'c') and (Magic[1] = '1') and (Magic[2] = '6') and
    (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
    (MSDOSEnd[3] = 0) then
  begin
    bitsPerPixel := 16;
  end;

  // Ficheros de 24 bits
  if (Magic[0] = 'm') and (Magic[1] = '2') and (Magic[2] = '4') and
    (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
    (MSDOSEnd[3] = 0) then
  begin
    bitsPerPixel := 24;
  end;

  // Ficheros de 32 bits
  if (Magic[0] = 'm') and (Magic[1] = '3') and (Magic[2] = '2') and
    (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
    (MSDOSEnd[3] = 0) then
  begin
    bitsPerPixel := 32;
  end;

  bytes_per_pixel:=bitsPerPixel div 8;

  Stream.Read(tmpWidth, 2);
  Stream.Read(tmpHeight, 2);
  Stream.Read(Code, 4);
  Stream.Read(Name, 32);

  Width := tmpWidth;
  Height := tmpHeight;

  if (bytes_per_pixel = 1) then
  begin
    Stream.Read(bPalette, 768);
    Stream.Read(Gamma, 576);

    for i := 0 to 767 do
      bPalette[i] := bPalette[i] shl 2;

  end;

  Stream.Read(ncpoints, 2);

  // Leemos los puntos de control del bitmap
  if ((ncpoints > 0) and (ncpoints <> 4096)) then
  begin
    Stream.Read(CPoints, ncpoints * 4);
  end;

  if (ncpoints = 4096) then
  begin
    Stream.Read(frames, 2);
    Stream.Read(length, 2);
    Stream.Read(speed, 2);
    Stream.Seek(length * 2, soFromCurrent);
  end;

  // Se carga la imagen resultante
  loadDataBitmap(Stream, bytes_per_pixel);

end;

procedure TMAPGraphic.loadDataBitmap(Stream: TStream; bytes_per_pixel: word);
var
  lazBMP: TLazIntfImage;
  p_bytearray: PByteArray;
  i, j, k, z: integer;
  byte_line: array [0 .. 16383] of byte;
  lenLineBits: integer;
  lineBit: byte;

begin
  // Se crea la imagen resultante
  PixelFormat := pf32bit;
  SetSize(Width, Height);


  // Para usar en caso de un bit
  if bytes_per_pixel = 0 then
  begin
    lenLineBits := Width div 8;
    if (Width mod 8) <> 0 then
      lenLineBits := lenLineBits + 1;
  end;

  lazBMP := CreateIntfImage;
  for k := 0 to Height - 1 do
  begin
    p_bytearray := lazBMP.GetDataLineStart(k);
    case bytes_per_pixel of
      0:
      begin
        for j := 0 to lenLineBits - 1 do
        begin
          Stream.Read(lineBit, 1);
          for i := 0 to 7 do
          begin
            z := (j * 8) + i;
            if z < Width then
            begin
              if (lineBit and 128) = 128 then
              begin
                p_bytearray^[z * 4] := 255;
                p_bytearray^[(z * 4) + 1] := 255;
                p_bytearray^[(z * 4) + 2] := 255;
                p_bytearray^[(z * 4) + 3] := 255;
              end
              else
              begin
                p_bytearray^[z * 4] := 0;
                p_bytearray^[(z * 4) + 1] := 0;
                p_bytearray^[(z * 4) + 2] := 0;
                p_bytearray^[(z * 4) + 3] := 0;
              end;
              lineBit := lineBit shl 1;
            end
            else
              break;
          end;
        end;
      end;
      1:
      begin
        Stream.Read(byte_line, Width * bytes_per_pixel);
        for j := 0 to Width - 1 do
        begin
          p_bytearray^[j * 4] := bPalette[byte_line[j] * 3 + 2];
          p_bytearray^[j * 4 + 1] := bPalette[byte_line[j] * 3 + 1];
          p_bytearray^[j * 4 + 2] := bPalette[byte_line[j] * 3];
          p_bytearray^[j * 4 + 3] := 255;
          if byte_line[j] = 0 then
            p_bytearray^[j * 4 + 3] := 0;
        end;
      end;
      2:
      begin
        Stream.Read(byte_line, Width * bytes_per_pixel);
        for j := 0 to Width - 1 do
        begin
          if CDIVFormat then
          begin
            RGB16toRGB24(byte_line[j * 2 + 1], byte_line[j * 2],
              p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
              p_bytearray^[(j * 4) + 2]);
            p_bytearray^[(j * 4) + 3] := 255;
            if ((p_bytearray^[j * 4] = $F8) and
              (p_bytearray^[j * 4 + 1] = 0) and
              (p_bytearray^[j * 4 + 2] = $F8)) then
              p_bytearray^[(j * 4) + 3] := 0;
          end
          else
          begin
            BGR16toRGB24(byte_line[j * 2 + 1], byte_line[j * 2],
              p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
              p_bytearray^[(j * 4) + 2]);
            p_bytearray^[(j * 4) + 3] := 255;
            if (byte_line[j * 2 + 1] + byte_line[j * 2]) = 0 then
              p_bytearray^[(j * 4) + 3] := 0;

          end;

        end;
      end;
      3:
      begin
        Stream.Read(byte_line, Width * bytes_per_pixel);
        for j := 0 to Width - 1 do
        begin
          p_bytearray^[j * 4] := byte_line[j * 3];
          p_bytearray^[j * 4 + 1] := byte_line[j * 3 + 1];
          p_bytearray^[j * 4 + 2] := byte_line[j * 3 + 2];
          p_bytearray^[j * 4 + 3] := 255;
          if (byte_line[j * 3 + 2] + byte_line[j * 3 + 1] + byte_line[j * 3]) = 0 then
            p_bytearray^[(j * 4) + 3] := 0;
        end;
      end;
      else // 32 bits
        Stream.Read(p_bytearray^, Width * bytes_per_pixel)
    end;
  end;
  LoadFromIntfImage(lazBMP);
  lazBMP.Free;

end;

procedure TMAPGraphic.SaveToStream(Stream: TStream);
begin
  saveToStream(Stream, False);
end;

procedure TMAPGraphic.SaveToStream(Stream: TStream; onFPG: boolean);
var
  byte_size: word;
  i: word;
  aWidth, aHeight: word;
  Frames: word;
  intFlags: longint;
  widthForFPG1: integer;
begin
  byte_size := 0;

  if magic[2] = 'p' then
    byte_size := 1;

  if magic[2] = '6' then
    byte_size := 2;

  if magic[2] = '4' then
    byte_size := 3;

  if magic[2] = '2' then
    byte_size := 4;

  if not onFPG then
  begin
    MSDOSEnd[0] := 26;
    MSDOSEnd[1] := 10;
    MSDOSEnd[2] := 13;
    MSDOSEnd[3] := 0;

    Stream.Write(Magic, 3);
    Stream.Write(MSDOSEnd, 4);
    Stream.Write(Version, 1);

    aWidth := Width;
    aHeight := Height;
    Stream.Write(aWidth, 2);
    Stream.Write(aHeight, 2);
  end;

  Stream.Write(Code, 4);

  if onFPG then
  begin
    if magic[1] <> '0' then
    begin
      graphSize := (Width * Height * byte_size) + 64;
    end
    else
    begin
      widthForFPG1 := Width;
      if (Width mod 8) <> 0 then
        widthForFPG1 := widthForFPG1 + 8 - (Width mod 8);
      graphSize := (widthForFPG1 div 8) * Height + 64;
      if ((ncpoints > 0) and (ncpoints <> 4096)) then
        graphSize := graphSize + (ncpoints * 4);
      if (ncpoints = 4096) then
        graphSize := graphSize + 6;
    end;
    Stream.Write(graphSize, 4);
  end;

  Stream.Write(Name, 32);
  if onFPG then
  begin
    Stream.Write(FPName, 11);
    Stream.Write(Width, 4);
    Stream.Write(Height, 4);
  end;

  if (not onFPG) and (Magic[1] = 'a') then
  begin
    for i := 0 to 767 do
      bPalette[i] := bPalette[i] shr 2;

    Stream.Write(bPalette, 768);
    Stream.Write(Gamma, 576);

    for i := 0 to 767 do
      bPalette[i] := bPalette[i] shl 2;
  end;

  if onFPG then
  begin
    intFlags := ncpoints;
    Stream.Write(intFlags, 4);
  end
  else
    Stream.Write(ncpoints, 2);

  if ((ncpoints > 0) and (ncpoints <> 4096)) then
    Stream.Write(CPoints, ncpoints * 4);
  if (ncpoints = 4096) then
  begin
    Frames := 0;
    Stream.Read(Frames, 2);
    Stream.Read(Frames, 2); // Length
    Stream.Read(Frames, 2);  // Speed
    // f.Seek(length * 2, soFromCurrent);
  end;
  writeDataBitmap(Stream, byte_size);

end;

procedure TMAPGraphic.writeDataBitmap(Stream: TStream; bytes_per_pixel: word);
var
  lazBMP: TLazIntfImage;
  byte_line: array [0 .. 16383] of byte;
  byteForFPG1: byte;
  insertedBits: integer;
  p_bytearray: PByteArray;
  j, k: word;
begin
  lazBMP := CreateIntfImage;

  for k := 0 to Height - 1 do
  begin
    p_bytearray := lazBmp.GetDataLineStart(k);
    case bytes_per_pixel of
      0:
      begin
        insertedBits := 0;
        byteForFPG1 := 0;
        for j := 0 to Width - 1 do
        begin
          if (p_bytearray^[j * 4] shr 7) = 1 then
          begin
            byteForFPG1 := byteForFPG1 or 1; // bit más alto en 8 bits
          end;
          insertedBits := insertedBits + 1;
          if (insertedBits = 8) then
          begin
            Stream.Write(byteForFPG1, 1);
            byteForFPG1 := 0;
            insertedBits := 0;
          end
          else
            byteForFPG1 := byteForFPG1 shl 1;
        end;
        if insertedBits > 0 then
        begin
          byteForFPG1 := byteForFPG1 shl (7 - insertedBits);
          Stream.Write(byteForFPG1, 1);
        end;
      end;
      1:
      begin
        for j := 0 to Width - 1 do
        begin
          byte_line[j] := 0;
          if p_bytearray^[j * 4 + 3] <> 0 then
            byte_line[j] := FindColor(0, p_bytearray^[j * 4 + 2],
              p_bytearray^[j * 4 + 1], p_bytearray^[j * 4]);
        end;
        Stream.Write(byte_line, Width);
      end;
      2:
      begin
        for j := 0 to Width - 1 do
        begin
          if CDIVFormat then
            if p_bytearray^[j * 4 + 3] <> 0 then
              RGB24toRGB16(byte_line[j * 2 + 1],
                byte_line[j * 2], p_bytearray^[j * 4], p_bytearray^[j * 4 + 1],
                p_bytearray^[j * 4 + 2])
            else
              RGB24toRGB16(byte_line[j * 2 + 1], byte_line[j * 2], 248, 0, 248)
          else
          begin
            byte_line[j * 2] := 0;
            byte_line[j * 2 + 1] := 0;
            if p_bytearray^[j * 4 + 3] <> 0 then
              RGB24toBGR16(byte_line[j * 2 + 1],
                byte_line[j * 2], p_bytearray^[j * 4], p_bytearray^[j * 4 + 1],
                p_bytearray^[j * 4 + 2]);

          end;
        end;
        Stream.Write(byte_line, Width * bytes_per_pixel);
      end;
      3:
      begin
        for j := 0 to Width - 1 do
        begin
          byte_line[j * 3] := 0;
          byte_line[j * 3 + 1] := 0;
          byte_line[j * 3 + 2] := 0;
          if p_bytearray^[j * 4 + 3] <> 0 then
          begin
            byte_line[j * 3] := p_bytearray^[j * 4];
            byte_line[j * 3 + 1] := p_bytearray^[j * 4 + 1];
            byte_line[j * 3 + 2] := p_bytearray^[j * 4 + 2];
          end;
        end;
        Stream.Write(byte_line, Width * bytes_per_pixel);
      end;
      else  // 32 bits
      begin
        Stream.Write(p_bytearray^, Width * bytes_per_pixel);
      end;
    end;

  end;
  lazBMP.Free;
end;

function TMAPGraphic.FindColor(index, rc, gc, bc: integer): integer;
var
  dif_colors, temp_dif_colors, i: word;
begin
  dif_colors := 800;
  Result := 0;

  for i := index to 255 do
  begin
    temp_dif_colors :=
      Abs(rc - bPalette[i * 3]) + Abs(gc - bPalette[(i * 3) + 1]) +
      Abs(bc - bPalette[(i * 3) + 2]);

    if temp_dif_colors <= dif_colors then
    begin
      Result := i;
      dif_colors := temp_dif_colors;

      if dif_colors = 0 then
        Exit;
    end;

  end;

end;

procedure TMAPGraphic.SaveToFile(const Filename: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(filename, fmCreate);
  SaveToStream(f);
  f.Free;
end;


// Calcula las componentes RGB almacenadas en 2 bytes como BGR
procedure TMAPGraphic.BGR16toRGB24(byte0, byte1: byte; var red, green, blue: byte);
begin
  blue := byte0 and $F8; // me quedo 5 bits 11111000
  green := (byte0 shl 5) or ((byte1 and $E0) shr 3);
  // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
  red := byte1 shl 3; // me quedo 5 bits
end;

// Calcula las componentes RGB almacenadas en 2 bytes como RGB
procedure TMAPGraphic.RGB16toRGB24(byte0, byte1: byte; var red, green, blue: byte);
begin
  red := byte0 and $F8; // me quedo 5 bits 11111000
  green := (byte0 shl 5) or ((byte1 and $E0) shr 3);
  // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
  blue := byte1 shl 3; // me quedo 5 bits
end;

// Calcula las componentes BGR almacenandolas en 2 bytes como BGR
procedure TMAPGraphic.RGB24toBGR16(var byte0, byte1: byte; red, green, blue: byte);
begin
  // F8 = 11111000
  // 1C = 00011100
  byte0 := (blue and $F8) or (green shr 5);
  byte1 := ((green and $1C) shl 3) or (red shr 3);
end;

// Establece las componentes RGB almacenandolas en 2 bytes como RGB
procedure TMAPGraphic.RGB24toRGB16(var byte0, byte1: byte; red, green, blue: byte);
begin
  // F8 = 11111000
  // 1C = 00011100
  byte0 := (red and $F8) or (green shr 5);
  byte1 := ((green and $1C) shl 3) or (blue shr 3);
end;

procedure  TMAPGraphic.SetFormat(cdiv : Boolean);
begin
  FCDIVFormat:=cdiv;
  FbitsPerPixel:=16;
  setMagic;
end;

procedure  TMAPGraphic.setMagic;
var
  strBpp :String;
begin
  if FCDIVFormat then
  begin
    magic[0]:='c';
  end else begin
    magic[0]:='m';
  end;
  if FbitsPerPixel = 8 then
  begin
    magic[1]:='a';
    magic[2]:='p';
  end else begin
    strBpp:=format('%.2d',[fbitsPerPixel]);
    magic[1]:=strBpp[1];
    magic[2]:=strBpp[2];
  end;

end;

procedure TMAPGraphic.SetBitsPerPixel(bpp: word);
begin
  FbitsPerPixel:=bpp;
  if FCDIVFormat then
    FbitsPerPixel:=16;
  setMagic;
end;

end.
