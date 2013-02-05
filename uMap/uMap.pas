unit uMap;

interface

uses LCLIntf, LCLType, SysUtils, Forms, Classes, dialogs,
     Graphics, FileUtil, IntfGraphics,
     uFrmMessageBox, uLanguage, uColor16bits;

const
 MAX_NUM_IMAGES = 999;
 FPG_NULL = 255;
 FPG1 = 0;
 FPG8_DIV2   = 1;
 FPG16 = 2;
 FPG16_CDIV  = 3;
 FPG24  = 4;
 FPG32  = 5;

type
 file_str_map = record
  magic          : array [0 .. 2] of char;
  msdosend       : array [0 .. 3] of byte;
  version        : byte;
  width          : word;
  height         : word;
  code           : dword;
  description    : array [0 .. 31] of char;
  palette   : array [0 .. 767] of byte;
  gamma     : array [0 .. 575] of byte;
  flags          : word;
  control_points : array [0 .. 2047] of short;
  bmp : TBitMap;
 end;


function MAP_Load(filename: string) : TBitmap;
function create_hpal (palette_ar : array of byte) : HPALETTE;
function loadDataBitmap(var f : TStream; palette : PByte ; width , height : longint; bytes_per_pixel : word; is_cdiv: boolean): TBitmap;

implementation
 function create_hpal (palette_ar : array of byte) : HPALETTE;
 var
  pal : PLogPalette;
  i   : LongInt;
 begin
  pal := nil;

  try
    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);

    pal^.palVersion    := $300;
    pal^.palNumEntries := 256;

    for i := 0 to 255 do
    begin
     pal^.palPalEntry[i].peRed   := palette_ar[(i*3)    ];
     pal^.palPalEntry[i].peGreen := palette_ar[(i*3) + 1];
     pal^.palPalEntry[i].peBlue  := palette_ar[(i*3) + 2];
     pal^.palPalEntry[i].peFlags := 0;
    end;

    create_hpal := CreatePalette(pal^);

  finally
    FreeMem(pal);
  end;
 end;

function loadDataBitmap(var f : TStream; palette : PByte ; width , height : longint; bytes_per_pixel : word; is_cdiv: boolean): TBitmap;
var
  lazBMP : TLazIntfImage;
  p_bytearray: PByteArray;
  i, j, k, z: integer;
  byte_line: array [0 .. 16383] of byte;
  lenLineBits: integer;
  lineBit: byte;

begin
        // Se crea la imagen resultante
        result := TBitMap.Create;
        result.PixelFormat := pf24bit;

        if  bytes_per_pixel = 4 then
        begin
          result.PixelFormat := pf32bit;
        end;

        result.SetSize(Width, Height);

        lazBMP := result.CreateIntfImage;
        // Para usar en caso de un bit
        if bytes_per_pixel = 0 then
        begin
          lenLineBits := Width div 8;
          if (Width mod 8) <> 0 then
            lenLineBits := lenLineBits + 1;
        end;

        for k := 0 to result.Height - 1 do
        begin
          p_bytearray := lazBMP.GetDataLineStart(k);
          case bytes_per_pixel of
            0:
            begin
                for j := 0 to lenLineBits - 1 do
                begin
                  f.Read(lineBit, 1);
                  for i := 0 to 7 do
                  begin
                    z := (j * 8) + i;
                    if z < result.Width then
                    begin
                      if (lineBit and 128) = 128 then
                      begin
                        p_bytearray^[z * 3] := 255;
                        p_bytearray^[(z * 3) + 1] := 255;
                        p_bytearray^[(z * 3) + 2] := 255;
                      end
                      else
                      begin
                        p_bytearray^[z * 3] := 0;
                        p_bytearray^[(z * 3) + 1] := 0;
                        p_bytearray^[(z * 3) + 2] := 0;
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
              f.Read(byte_line, result.Width * bytes_per_pixel);
              for j:=0 to result.Width -1  do
              begin
                 p_bytearray^[j*3+2] := palette[byte_line[j] * 3];
                 p_bytearray^[j*3+1] := palette[byte_line[j] * 3 + 1];
                 p_bytearray^[j*3] := palette[byte_line[j] * 3 + 2];
              end;
            end;
            2:
            begin
              f.Read(byte_line, result.Width * bytes_per_pixel);
              for j:=0 to result.Width -1  do
              begin
                if is_cdiv  then
                  Calculate_RGB16(byte_line[j*2+1], byte_line[j*2],
                    p_bytearray^[j * 3], p_bytearray^[(j * 3) + 1],
                    p_bytearray^[(j * 3) + 2])
                else
                  Calculate_BGR16(byte_line[j*2+1], byte_line[j*2 ],
                    p_bytearray^[j * 3], p_bytearray^[(j * 3) + 1],
                    p_bytearray^[(j * 3) + 2]);

              end;
            end;
            else // 24 y 32 bits
                f.Read(p_bytearray^, result.Width * bytes_per_pixel)
          end;
        end;
        result.LoadFromIntfImage(lazBMP);
        lazBMP.Free;

        if result.PixelFormat = pf24bit then
        begin
           if is_cdiv then
             result.TransparentColor:=clFuchsia
           else
             result.TransparentColor:=clBlack;
           result.Transparent:=true;
        end;

end;

 function MAP_Load(filename: string) : TBitmap;
 var
  f       : TStream;
  frames,
  length,
  speed   : word;
  bytes_per_pixel  : word;
  is_cdiv : boolean;
  header : file_str_map;
  map_hpal : HPALETTE;
  i : integer;

 begin

  result   := nil;

  if not FileExistsUTF8(filename) { *Converted from FileExists*  } then
   Exit;

  try
   f := TFileStream.Create(filename, fmOpenRead);
  except
   Exit;
  end;

  try
   f.Read(header.magic, 3);
   f.Read(header.msdosend , 4);
   f.Read(header.version, 1);
  except
   f.free;
   Exit;
  end;

  bytes_per_pixel := 0;
  is_cdiv:=false;
  // Ficheros de 1 bit
  if (header.magic[0]         = 'm') and (header.magic[1]         = '0') and
     (header.magic[2]         = '1') and (header.msdosend [0]     = 26 ) and
     (header.msdosend [1]     = 13 ) and (header.msdosend [2] = 10 ) and
     (header.msdosend [3] = 0) then begin
   bytes_per_pixel := 0;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (header.magic[0]         = 'm') and (header.magic[1]         = 'a') and
     (header.magic[2]         = 'p') and (header.msdosend [0]     = 26 ) and
     (header.msdosend [1]     = 13 ) and (header.msdosend [2] = 10 ) and
     (header.msdosend [3] = 0) then begin
   bytes_per_pixel := 1;
  end;
  // Ficheros de 16 bits para FENIX
  if (header.magic[0]         = 'm') and (header.magic[1]         = '1') and
     (header.magic[2]         = '6') and (header.msdosend [0]     = 26 ) and
     (header.msdosend [1]     = 13 ) and (header.msdosend [2] = 10 ) and
     (header.msdosend [3] = 0) then begin
   bytes_per_pixel := 2;
  end;

  // Ficheros de 16 bits para CDIV
  if (header.magic[0]         = 'c') and (header.magic[1]         = '1') and
     (header.magic[2]         = '6') and (header.msdosend [0]     = 26 ) and
     (header.msdosend [1]     = 13 ) and (header.msdosend [2] = 10 ) and
     (header.msdosend [3] = 0) then begin
   bytes_per_pixel := 2;
   is_cdiv:=true;
  end;

  // Ficheros de 24 bits
  if (header.magic[0]         = 'm') and (header.magic[1]         = '2') and
     (header.magic[2]         = '4') and (header.msdosend [0]     = 26 ) and
     (header.msdosend [1]     = 13 ) and (header.msdosend [2] = 10 ) and
     (header.msdosend [3] = 0) then begin
   bytes_per_pixel := 3;
  end;

     // Ficheros de 32 bits
  if (header.magic[0]         = 'm') and (header.magic[1]         = '3') and
     (header.magic[2]         = '2') and (header.msdosend [0]     = 26 ) and
     (header.msdosend [1]     = 13 ) and (header.msdosend [2] = 10 ) and
     (header.msdosend [3] = 0) then begin
   bytes_per_pixel := 4;
  end;

  if (bytes_per_pixel > 4) then
  begin
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_WRONG_FPG], 0, 0);
   f.free;
   Exit;
  end;

  try
   f.Read(header.width,2);
   f.Read(header.height,2);
   f.Read(header.code,4);
   f.Read(header.description, 32);

   if (bytes_per_pixel = 1) then
   begin
    f.Read(header.palette, 768);
    f.Read(header.gamma, 576);

    for i := 0 to 767 do
     header.palette[i] := header.palette[i] shl 2;

    map_hpal := create_hpal(header.palette);

   end;

   f.Read(header.flags, 2);

   // Leemos los puntos de control del bitmap
   if ((header.flags > 0) and (header.flags  <> 4096)) then
   begin
    f.Read(header.control_points, header.flags  * 4);
   end;

   if (header.flags  = 4096) then
   begin
    f.Read(frames, 2);
    f.Read(length, 2);
    f.Read(speed , 2);
    f.Seek(length * 2, soFromCurrent);
   end;


   // Se crea la imagen resultante

   result:=loadDataBitmap(f,header.palette, header.width,header.height, bytes_per_pixel, is_cdiv);

  finally
   f.free;
  end;
 end;

end.
 
