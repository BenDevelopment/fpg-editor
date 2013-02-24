unit uMAPGraphic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  IntfGraphics, FileUtil;

type
   { TMAPGraphic }

  TMAPGraphic = class (TBitmap)
    private
      Magic          : array [0 .. 2] of char;
      MSDOSEnd       : array [0 .. 3] of byte;
      Version        : byte;
//      width          : word;  // Not needed, stored in TBitmap
//      height         : word;  // Not needed, stored in TBitmap
      Code           : dword;
      FPName  :array [0 .. 11] of char; // Needed for FPG Graphics
      Name    : array [0 .. 31] of char;
      bPalette   : array [0 .. 767] of byte;
      Gamma     : array [0 .. 575] of byte;
      Flags          : word;
      ControlPoints : array [0 .. 2047] of smallint;
      GraphSize: longint;               // Needed for FPG Graphics
      procedure loadDataBitmap ( Stream : TStream;  bytes_per_pixel : Word; is_cdiv : Boolean = false);
      procedure writeDataBitmap( Stream: TStream ; bytes_per_pixel : word; cdivformat : boolean =false);
      procedure calculateBGR16( var byte0, byte1 : Byte; red, green, blue : Byte );
      procedure calculateRGB16( var byte0, byte1 : Byte; red, green, blue : Byte );
      procedure CalculateBGR24( byte0, byte1 : Byte; var red, green, blue : Byte );
      procedure CalculateRGB24( byte0, byte1 : Byte; var red, green, blue : Byte );
      function FindColor(index, rc, gc, bc: integer ): integer;
    public
      procedure LoadFromFile(const Filename: string); override;
      procedure LoadFromStream(Stream: TStream); override;
      procedure SaveToFile(const Filename: string); override;
      procedure SaveToStream(Stream: TStream); override;
      procedure SaveToStream(Stream: TStream; onFPG: Boolean);
      class function GetFileExtensions: string; override;
  end;

implementation

{ TMAPGraphic }

class function TMAPGraphic.GetFileExtensions: string;
begin
  Result:='map';
end;

procedure TMAPGraphic.LoadFromFile(const Filename: string);
var
  f : TFileStream;
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
   f.free;
  end;

end;

procedure TMAPGraphic.LoadFromStream(Stream: TStream);
var
  bytes_per_pixel : Word;
  is_cdiv : Boolean;
  frames : Word;
  length : Word;
  speed   : Word;
  tmpWidth : Word;
  tmpHeight : Word;
  i : Integer;
begin
   Stream.Read(Magic, 3);
   Stream.Read(MSDOSEnd , 4);
   Stream.Read(Version, 1);

  bytes_per_pixel := 0;
  is_cdiv:=false;
  // Ficheros de 1 bit
  if (Magic[0]         = 'm') and (Magic[1]         = '0') and
     (Magic[2]         = '1') and (MSDOSEnd [0]     = 26 ) and
     (MSDOSEnd [1]     = 13 ) and (MSDOSEnd [2] = 10 ) and
     (MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 0;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (Magic[0]         = 'm') and (Magic[1]         = 'a') and
     (Magic[2]         = 'p') and (MSDOSEnd [0]     = 26 ) and
     (MSDOSEnd [1]     = 13 ) and (MSDOSEnd [2] = 10 ) and
     (MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 1;
  end;
  // Ficheros de 16 bits para FENIX
  if (Magic[0]         = 'm') and (Magic[1]         = '1') and
     (Magic[2]         = '6') and (MSDOSEnd [0]     = 26 ) and
     (MSDOSEnd [1]     = 13 ) and (MSDOSEnd [2] = 10 ) and
     (MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 2;
  end;

  // Ficheros de 16 bits para CDIV
  if (Magic[0]         = 'c') and (Magic[1]         = '1') and
     (Magic[2]         = '6') and (MSDOSEnd [0]     = 26 ) and
     (MSDOSEnd [1]     = 13 ) and (MSDOSEnd [2] = 10 ) and
     (MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 2;
   is_cdiv:=true;
  end;

  // Ficheros de 24 bits
  if (Magic[0]         = 'm') and (Magic[1]         = '2') and
     (Magic[2]         = '4') and (MSDOSEnd [0]     = 26 ) and
     (MSDOSEnd [1]     = 13 ) and (MSDOSEnd [2] = 10 ) and
     (MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 3;
  end;

     // Ficheros de 32 bits
  if (Magic[0]         = 'm') and (Magic[1]         = '3') and
     (Magic[2]         = '2') and (MSDOSEnd [0]     = 26 ) and
     (MSDOSEnd [1]     = 13 ) and (MSDOSEnd [2] = 10 ) and
     (MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 4;
  end;

  if (bytes_per_pixel > 4) then
  begin
   Stream.free;
   Exit;
  end;

   Stream.Read(tmpWidth,2);
   Stream.Read(tmpHeight,2);
   Stream.Read(Code,4);
   Stream.Read(Name, 32);

   width:=tmpWidth;
   height:=tmpHeight;

   if (bytes_per_pixel = 1) then
   begin
    Stream.Read(bPalette, 768);
    Stream.Read(Gamma, 576);

    for i := 0 to 767 do
     bPalette[i] := bPalette[i] shl 2;

   end;

   Stream.Read(Flags, 2);

   // Leemos los puntos de control del bitmap
   if ((Flags > 0) and (Flags  <> 4096)) then
   begin
    Stream.Read(ControlPoints, Flags  * 4);
   end;

   if (Flags  = 4096) then
   begin
    Stream.Read(frames, 2);
    Stream.Read(length, 2);
    Stream.Read(speed , 2);
    Stream.Seek(length * 2, soFromCurrent);
   end;

   // Se carga la imagen resultante
   loadDataBitmap(Stream, bytes_per_pixel, is_cdiv);

end;

procedure TMAPGraphic.loadDataBitmap ( Stream : TStream;  bytes_per_pixel : Word; is_cdiv : Boolean);
var
  lazBMP : TLazIntfImage;
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
              for j:=0 to Width -1  do
              begin
                 p_bytearray^[j*4] := bPalette[byte_line[j] * 3 + 2];
                 p_bytearray^[j*4+1] := bPalette[byte_line[j] * 3 + 1];
                 p_bytearray^[j*4+2] := bPalette[byte_line[j] * 3];
                 p_bytearray^[j*4+3]:=255;
                 if byte_line[j]=0 then
                   p_bytearray^[j*4+3]:=0;
              end;
            end;
            2:
            begin
              Stream.Read(byte_line, Width * bytes_per_pixel);
              for j:=0 to Width -1  do
              begin
                if is_cdiv then
                begin
                  CalculateRGB24(byte_line[j*2+1], byte_line[j*2],
                    p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
                    p_bytearray^[(j * 4) + 2]);
                  p_bytearray^[(j * 4) + 3] := 255;
                  if ( ( p_bytearray^[j * 4] = $F8) and
                         ( p_bytearray^[j * 4 + 1] = 0) and
                         ( p_bytearray^[j * 4 + 2] = $F8)  ) then
                     p_bytearray^[(j * 4) + 3] := 0;
                end
                else
                begin
                  CalculateBGR24(byte_line[j*2+1], byte_line[j*2 ],
                    p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
                    p_bytearray^[(j * 4) + 2]);
                  p_bytearray^[(j * 4) + 3] := 255;
                  if (byte_line[j*2+1] + byte_line[j*2 ]) = 0 then
                     p_bytearray^[(j * 4) + 3] := 0;

                end;

              end;
            end;
            3:
            begin
              Stream.Read(byte_line, Width * bytes_per_pixel);
              for j:=0 to Width -1  do
              begin
                p_bytearray^[j*4] := byte_line[j*3];
                p_bytearray^[j*4+1] := byte_line[j*3+1];
                p_bytearray^[j*4+2] := byte_line[j*3+2];
                p_bytearray^[j*4+3]:=255;
                if (byte_line[j*3+2] + byte_line[j*3+1] + byte_line[j*3 ]) = 0 then
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

// Calcula las componentes RGB almacenadas en 2 bytes como BGR
procedure TMAPGraphic.CalculateBGR24( byte0, byte1 : Byte; var red, green, blue : Byte );
begin
 blue := byte0 and $F8; // me quedo 5 bits 11111000
 green := (byte0 shl 5) or ( (byte1 and $E0) shr 3); // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
 red := byte1 shl 3; // me quedo 5 bits
end;

// Calcula las componentes RGB almacenadas en 2 bytes como RGB
procedure TMAPGraphic.CalculateRGB24( byte0, byte1 : Byte; var red, green, blue : Byte );
begin
 red := byte0 and $F8; // me quedo 5 bits 11111000
 green := (byte0 shl 5) or ( (byte1 and $E0) shr 3); // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
 blue := byte1 shl 3; // me quedo 5 bits
end;

//      procedure SaveToFile(const Filename: string); override;
//      procedure SaveToStream(Stream: TStream); override;

procedure TMAPGraphic.SaveToFile(const Filename: string);
var
    f: TFileStream;
begin
   f := TFileStream.Create(filename, fmCreate);
   SaveToStream(f);
   f.Free;
end;

procedure TMAPGraphic.SaveToStream(Stream: TStream);
begin
  saveToStream(Stream,false);
end;

procedure TMAPGraphic.SaveToStream(Stream: TStream; onFPG:Boolean);
var
  byte_size: Word;
  i : Word;
  aWidth,aHeight : Word;
  Frames : Word;
  intFlags : LongInt;
  widthForFPG1: Integer;
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
    MSDOSEnd[0]:= 26;
    MSDOSEnd[1]:= 10;
    MSDOSEnd[2]:= 13;
    MSDOSEnd[3]:= 0;

    Stream.Write(Magic, 3);
    Stream.Write(MSDOSEnd , 4);
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
    end else begin
      widthForFPG1 := Width;
      if (Width mod 8) <> 0 then
        widthForFPG1 := widthForFPG1 + 8 - (Width mod 8);
      graphSize := (widthForFPG1 div 8) * Height + 64;
      if ((Flags > 0) and (Flags <> 4096)) then
        graphSize := graphSize + (Flags * 4);
      if (Flags = 4096) then
        graphSize := graphSize + 6;
    end;
    Stream.Write(graphSize, 4);
  end;

  Stream.Write(Name, 32);
  if onFPG then
  begin
    Stream.Write(FPName, 11);
    Stream.Write(Width, 4);
    Stream.Write(Height, 4)
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
    intFlags:= Flags;
    Stream.Write(Flags, 4);
  end else
    Stream.Write(Flags, 2);

  if ((Flags > 0) and (Flags <> 4096)) then
    Stream.Write(ControlPoints, Flags * 4);
  if (Flags = 4096) then
  begin
    Frames:=0;
    Stream.Read(Frames, 2);
    Stream.Read(Frames, 2); // Length
    Stream.Read(Frames, 2);  // Speed
   // f.Seek(length * 2, soFromCurrent);
  end;
  writeDataBitmap(Stream,byte_size ,(Magic[0] = 'c'));

end;

procedure TMAPGraphic.writeDataBitmap( Stream: TStream ; bytes_per_pixel : word; cdivformat : boolean =false);
var
  lazBMP : TLazIntfImage;
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
            end else
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
          byte_line[j]:=0;
          if p_bytearray^[j * 4 + 3 ] <> 0 then
             byte_line[j]:=FindColor(0,p_bytearray^[j * 4+2],p_bytearray^[j * 4+1],p_bytearray^[j * 4]);
        end;
        Stream.Write(byte_line, Width);
     end;
     2:
     begin
       for j := 0 to Width - 1 do
       begin
           if cdivformat then
             if p_bytearray^[j * 4 + 3 ] <> 0 then
                calculateRGB16(byte_line[j*2+1], byte_line[j*2],p_bytearray^[j * 4],p_bytearray^[j * 4+1],p_bytearray^[j * 4+2] )
             else
               calculateRGB16(byte_line[j*2+1], byte_line[j*2],248,0,248 )
           else begin
            byte_line[j*2]:=0;
            byte_line[j*2+1]:=0;
            if p_bytearray^[j * 4 + 3 ] <> 0 then
              calculateBGR16(byte_line[j*2+1], byte_line[j*2],p_bytearray^[j * 4],p_bytearray^[j * 4+1],p_bytearray^[j * 4+2] )

           end;
       end;
       Stream.Write(byte_line, Width*bytes_per_pixel);
     end;
     3:
     begin
       for j := 0 to Width - 1 do
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
       Stream.Write(byte_line, Width*bytes_per_pixel);
     end;
     else  // 32 bits
     begin
         Stream.Write(p_bytearray^, Width * bytes_per_pixel);
     end;
     end;

  end;
  lazBMP.Free;
end;

function TMAPGraphic.FindColor(index, rc, gc, bc: integer ): integer;
var
  dif_colors, temp_dif_colors, i: word;
begin
  dif_colors := 800;
  Result := 0;

  for i := index to 255 do
  begin
    temp_dif_colors :=
      Abs(rc - bPalette[i * 3]) +
      Abs(gc - bPalette[(i * 3) + 1]) +
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

// Establece las componentes RGB almacenandolas en 2 bytes como BGR
procedure TMAPGraphic.calculateBGR16( var byte0, byte1 : Byte; red, green, blue : Byte );
begin
 // F8 = 11111000
 // 1C = 00011100
 byte0 := (blue and $F8) or (green shr 5);
 byte1 := ( (green and $1C) shl 3)  or (red shr 3);
end;

// Establece las componentes RGB almacenandolas en 2 bytes como RGB
procedure TMAPGraphic.calculateRGB16( var byte0, byte1 : Byte; red, green, blue : Byte );
begin
 // F8 = 11111000
 // 1C = 00011100
 byte0 := (red and $F8) or (green shr 5);
 byte1 := ( (green and $1C) shl 3)  or (blue shr 3);
end;


end.

