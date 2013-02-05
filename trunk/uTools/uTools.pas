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

unit uTools;



interface

uses
  LCLIntf, LCLType, Graphics, Classes, SysUtils, Forms, Dialogs, FileUtil,
  Process, IntfGraphics, FPimage,
  uIniFile, uFPG , uMap, lazcanvas, GraphType;

 function RunExe(Cmd, WorkDir: String): string;overload;
 function RunExe(Cmd, WorkDir,outputfilename: String): string;overload;
 function ExecuteFile(const FileName, Params, DefaultDir: string; ShowCmd: Integer): THandle;
 function FileDeleteRB( AFileName:string ): boolean;

 function prepare_file_source(dir : string; name : string) : string;
 function NumberTo3Char( number: LongInt ): string;
 
 procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap; bgcolor:TColor; newwidth, newheight:Integer );overload;
 procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap; bgcolor:TColor );overload;
 procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap);overload;
 procedure DrawProportional( var bmp : TBitmap); overload;

 procedure simulate1bppIn32bpp(var bmp_src : TBitmap);
 procedure simulate1bppIn24bpp(var bmp_src : TBitmap);
 procedure simulate8bppIn24bpp(var bmp_src : TBitmap);
 procedure createBitmap8bpp(var bmp_dst,bmp_src : TBitmap);
 procedure createBitmap8bpp_bis(var bmp_dst,bmp_src : TBitmap);

 function countAlphas(var Bitmap: TBItmap; value: Byte): Integer;
 procedure copyPixels(var dstBitmap: TBitmap; srcBitmap: TBitmap; x, y : Integer);


implementation

function RunExe(Cmd, WorkDir, outputfilename: String): string;
var
   UnProceso: TProcess;
   f_output: TFileStream;
   MyBuffer:array[1..100] of byte;
   size_read: Longint;
begin
   SetCurrentDir(WorkDir);
   UnProceso := TProcess.Create(nil);
   UnProceso.CommandLine := Cmd;
   UnProceso.Options := [poUsePipes];

   UnProceso.Execute;
   f_output:= TFileStream.Create(outputfilename,fmCreate );
   while UnProceso.Running do
   begin
      size_read:=UnProceso.Output.Read(mybuffer,100);
      if size_read >0 then
      begin
        f_output.Write(mybuffer,size_read);
      end
      else begin
         sleep(100);
      end;
   end;
   repeat
         size_read:=UnProceso.Output.Read(mybuffer,100);
         if size_read >0 then
         begin
           f_output.Write(mybuffer,size_read);
         end;
   until size_read <= 0;

   f_output.free;

   RunExe:= '';

   UnProceso.Free;
end;

function RunExe(Cmd, WorkDir: String): string;
var
   UnProceso: TProcess;

begin
   SetCurrentDir(WorkDir);
   UnProceso := TProcess.Create(nil);
   UnProceso.Options := UnProceso.Options + [poWaitOnExit];

   UnProceso.CommandLine := Cmd;
   UnProceso.Execute;
//   RunExe:= UnProceso.Output.ToString;
   RunExe:= '';

   UnProceso.Free;
end;
//function RunExe(Cmd, WorkDir: String): string;
//var
//  tsi: TStartupInfo;
//  tpi: TProcessInformation;
//  nRead: DWORD;
//  aBuf: Array[0..101] of char;
//  sa: TSecurityAttributes;
//  hOutputReadTmp, hOutputRead, hOutputWrite, hInputWriteTmp, hInputRead,
//  hInputWrite, hErrorWrite: THandle;
//  FOutput: String;
//begin
//  FOutput := '';
//
//  sa.nLength              := SizeOf(TSecurityAttributes);
//  sa.lpSecurityDescriptor := nil;
//  sa.bInheritHandle       := True;
//
//  CreatePipe(hOutputReadTmp, hOutputWrite, @sa, 0);
//  DuplicateHandle(GetCurrentProcess(), hOutputWrite, GetCurrentProcess(),
//    @hErrorWrite, 0, true, DUPLICATE_SAME_ACCESS);
//  CreatePipe(hInputRead, hInputWriteTmp, @sa, 0);
//
//  // Create new output read handle and the input write handle. Set
//  // the inheritance properties to FALSE. Otherwise, the child inherits
//  // the these handles; resulting in non-closeable handles to the pipes
//  // being created.
//  DuplicateHandle(GetCurrentProcess(), hOutputReadTmp,  GetCurrentProcess(),
//    @hOutputRead,  0, false, DUPLICATE_SAME_ACCESS);
//  DuplicateHandle(GetCurrentProcess(), hInputWriteTmp, GetCurrentProcess(),
//    @hInputWrite, 0, false, DUPLICATE_SAME_ACCESS);
//  FileClose(hOutputReadTmp); { *Converted from CloseHandle*  }
//  FileClose(hInputWriteTmp); { *Converted from CloseHandle*  }
//
//  FillChar(tsi, SizeOf(TStartupInfo), 0);
//  tsi.cb         := SizeOf(TStartupInfo);
//  tsi.dwFlags    := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
//  tsi.hStdInput  := hInputRead;
//  tsi.hStdOutput := hOutputWrite;
//  tsi.hStdError  := hErrorWrite;
//
//  CreateProcess(nil, PChar(Cmd), @sa, @sa, true, 0, nil, PChar(WorkDir),
//    tsi, tpi);
//  FileClose(hOutputWrite); { *Converted from CloseHandle*  }
//  FileClose(hInputRead ); { *Converted from CloseHandle*  }
//  FileClose(hErrorWrite); { *Converted from CloseHandle*  }
//  Application.ProcessMessages;
//
//  repeat
//     if (not FileRead(hOutputRead) { *Converted from ReadFile*  }) or (nRead = 0) then
//     begin
//        if GetLastError = ERROR_BROKEN_PIPE then Break
//        else MessageDlg('Pipe read error, could not execute file', mtError, [mbOK], 0);
//     end;
//     aBuf[nRead] := #0;
//     FOutput := FOutput + PChar(@aBuf[0]);
//     Application.ProcessMessages;
//  until False;
//
//  Result := FOutput;
//  //GetExitCodeProcess(tpi.hProcess, nRead) = True;
//end;

function FileDeleteRB( AFileName:string ): boolean;
begin
     FileDeleteRB:=  DeleteFile(AFilename);
end;

//function FileDeleteRB( AFileName:string ): boolean;
//var Struct: TSHFileOpStruct;
//    pFromc: array[0..255] of char;
//    Resultval: integer;
//begin
//   if not FileExistsUTF8(AFileName) { *Converted from FileExists*  } then begin
//      Result := False;
//      exit;
//   end
//   else begin
//      fillchar(pfromc,sizeof(pfromc),0) ;
//      StrPcopy(pfromc,ExpandFileNameUTF8(AFileName) { *Converted from ExpandFileName*  }+#0#0) ;
//      Struct.wnd := 0;
//      Struct.wFunc := FO_DELETE;
//      Struct.pFrom := pFromC;
//      Struct.pTo := nil;
//      Struct.fFlags:= FOF_ALLOWUNDO or FOF_NOCONFIRMATION
//         or FOF_SILENT;
//      Struct.fAnyOperationsAborted := false;
//      Struct.hNameMappings := nil;
//      Resultval := ShFileOperation(Struct) ;
//      Result := (Resultval = 0) ;
//   end;
//end;

//ExecuteProcess('xdg-open','http://bennugd.org/');

function ExecuteFile(const FileName, Params, DefaultDir: string; ShowCmd: Integer): THandle;
var
  UnProceso: TProcess;
  splitted : TStrings;
begin
  SetCurrentDir(DefaultDir);

  UnProceso := TProcess.Create(nil);
  UnProceso.Executable:= FileName;//  CommandLine := FileName +' '+Params;

  splitted:= TStringList.Create;
  splitted.StrictDelimiter := true;
  splitted.Delimiter :=  ' ';
  splitted.DelimitedText := Params;

  UnProceso.Parameters:=splitted;
  UnProceso.Options := UnProceso.Options + [poWaitOnExit];
  UnProceso.Execute;
  UnProceso.Free;
  ExecuteFile:= UnProceso.Handle;
end;
//function ExecuteFile(const FileName, Params, DefaultDir: string; ShowCmd: Integer): THandle;
//var
//  zFileName, zParams, zDir: array[0..79] of Char;
//begin
//  Result :=  OpenDocument(StrPCopy(zFileName); { *Converted from ShellExecute*  }
//end;

function prepare_file_source(dir : string; name : string) : string;
begin
 prepare_file_source := dir + DirectorySeparator + name;
end;

function NumberTo3Char( number: LongInt ): string;
begin
 result := IntToStr(number);

 if Length(result) = 1 then
  result := '00' + result
 else if Length(result) = 2 then
  result := '0' + result;
end;

procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap);
begin
    DrawProportional(bmp_src,bmp_dst,clWhite);
end;

procedure setTansparentPixels( var bmp : TBitmap );
var
 image : TLazIntfImage;
 ImgHandle,ImgMaskHandle: HBitmap;
 i,j : Integer;
 pointer : PRGBAQuad;

begin
 image:=TLazIntfImage.Create(0,0);
 image.LoadFromBitmap(bmp.Handle,bmp.MaskHandle);

 for j:=0 to image.Height -1 do
 begin
  pointer:=image.GetDataLineStart(j);
  for i:=0 to image.Width -1 do
  begin
    pointer[i].Alpha:=255;
  end;
 end;

 image.CreateBitmaps(imgHandle,imgMaskHandle,false);
 bmp.handle:=imgHandle;
 bmp.maskhandle:=imgMaskHandle;
 image.free;
end;

procedure setAlpha(var Bitmap: TBItmap; value: Byte; in_rect : TRect );
var
  lazBitmap: TLazIntfImage;
  k, j :integer;
  ppixel : PRGBAQuad;
begin
 lazBitmap:= Bitmap.CreateIntfImage;
 for k := in_rect.top to in_rect.Bottom -1 do
 begin
   ppixel := lazBitmap.GetDataLineStart(k);
   for j := in_rect.Left to in_rect.Right - 1 do
     ppixel[j].Alpha := value;
 end;
 Bitmap.LoadFromIntfImage(lazBitmap);
 lazBitmap.free;
end;

procedure setAlpha(var Bitmap: TBItmap; value: Byte);
begin
  setAlpha(Bitmap,value,Rect(0,0,Bitmap.Width,Bitmap.Height));
end;

function countAlphas(var Bitmap: TBItmap; value: Byte): Integer;
var
  lazBitmap: TLazIntfImage;
  k, j :integer;
  ppixel : PRGBAQuad;
begin
 lazBitmap := Bitmap.CreateIntfImage;
 result := 0;
 for k := 0 to Bitmap.height - 1 do
 begin
   ppixel := lazBitmap.GetDataLineStart(k);
   for j := 0 to Bitmap.width - 1 do
   begin
     if ppixel[j].Alpha = value then
        result := result +1;
   end;
 end;

 bitmap.LoadFromIntfImage(lazBitmap);
 lazBitmap.free;
end;

procedure copyPixels(var dstBitmap: TBitmap; srcBitmap: TBitmap; x, y : Integer);
var
  dstLazBitmap: TLazIntfImage;
  srcLazBitmap: TLazIntfImage;
begin
 dstLazBitmap:=dstBitmap.CreateIntfImage;
 srcLazBitmap:=srcBitmap.CreateIntfImage;

 dstLazBitmap.CopyPixels(srcLazBitmap,x,y);

 srcLazBitmap.free;
 dstBitmap.LoadFromIntfImage(dstLazBitmap);
 dstLazBitmap.free;
end;


procedure DrawProportional2( var bmp_src : TBitMap; var bmp_dst: TBitMap; bgcolor:TColor; newWidth,newHeight: integer );
var
 lazBMPdst : TLazIntfImage;
 lazBMPsrc : TLazIntfImage;
 lazCanvasDst: TLazCanvas;
 lazRawDst: TRawImage;
begin
  lazRawDst.Init;
  lazRawDst.Description.Init_BPP32_A8R8G8B8_BIO_TTB(newWidth, newHeight);
  lazRawDst.CreateData(True);
  lazBMPdst:= TLazIntfImage.Create(0,0);
  lazBMPdst.SetRawImage(lazRawDst);

  lazBMPsrc:=bmp_src.CreateIntfImage;

  lazCanvasDst := TLazCanvas.create(lazBMPdst);
  lazcanvasDst.StretchDraw(0,0,newWidth,newHeight,lazBMPsrc);

  lazBMPsrc.free;
  bmp_dst.PixelFormat:= pf32bit;
  bmp_dst.LoadFromIntfImage(lazBMPdst);
  lazBMPdst.free;
end;

procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap; bgcolor:TColor; newWidth,newHeight: integer );
var
 x, y, width, height : integer;
 bitmap1 : TBitmap;
 lazBMP : TLazIntfImage;
 lazBMPsrc : TLazIntfImage;

begin
 bmp_dst := TBitmap.Create;
 bmp_dst.PixelFormat:= pf32bit;
 bitmap1 := TBitmap.Create;
 bitmap1.PixelFormat:= pf32bit;

 bmp_dst.SetSize(newWidth,newHeight);
 setAlpha(bmp_dst,0,Rect(0, 0, newWidth , newHeight));

 x := 0;
 y := 0;
 width  := bmp_dst.Width;
 height := bmp_dst.Height;

 if bmp_src <> nil then begin
   if bmp_src.Width > bmp_src.Height then
   begin
    height := (bmp_src.Height * newWidth) div bmp_src.Width;
    y := (newHeight - height) div 2;
   end
   else
   begin
    width  := (bmp_src.Width * newHeight) div bmp_src.Height;
    x := (newWidth - width) div 2;
   end;

   bitmap1.SetSize(Width,height);
   bitmap1.Canvas.StretchDraw( Rect(0, 0, width , height ), bmp_src );

   copyPixels(bmp_dst,bitmap1,x,y);

   if countAlphas(bitmap1,0) >= width*height then
    setAlpha(bmp_dst,255,Rect(x, y, x+width , y+height));



   bitmap1.Free;
   //bmp_dst.TransparentColor:=bmp_src.TransparentColor;
   //bmp_dst.Transparent:=bmp_src.Transparent;
   //bmp_dst.Canvas.StretchDraw( Rect(x, y, width + x, height + y), bmp_src );

 end;

end;

procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap; bgcolor:TColor);
begin
 DrawProportional( bmp_src , bmp_dst, bgcolor,inifile_sizeof_icon,inifile_sizeof_icon);
end;

procedure DrawProportional( var bmp : TBitmap);
var
  thumbRect : TRect;
  maxWidth, maxHeight : integer;
begin
 thumbRect.Left :=0; //  := inifile_sizeof_icon;
 thumbRect.Top := 0 ; // inifile_sizeof_icon;
 maxWidth:=  inifile_sizeof_icon;
 maxHeight:=  inifile_sizeof_icon ;
 if bmp <> nil then begin
   if bmp.Width > bmp.Height then begin
    thumbRect.Right := maxWidth;
    thumbRect.Bottom := (maxWidth * bmp.Height) div bmp.Width;
   end else begin
    thumbRect.Bottom := maxHeight;
    thumbRect.Right := (maxHeight * bmp.Width) div bmp.Height;
   end;
   bmp.Canvas.StretchDraw( thumbRect, bmp );
 end;
end;

procedure simulate1bppIn32bpp(var bmp_src : TBitmap);
var
 lazBMP: TLazIntfImage;
 rgbaLine : PRGBAQuad;
 i, j : LongInt;
begin
   lazBMP:=bmp_src.CreateIntfImage;
   // Conversión a 1 bit
   for j := 0 to bmp_src.height - 1 do begin
    rgbaLine := lazBMP.GetDataLineStart(j);
    for i := 0 to bmp_src.width - 1 do begin
      //if ( ( (rgbaLine[i].R shl 16) + (rgbaLine[i].G shl 8) + (rgbaLine[i].B) ) shr 23 )
      //if ( ( (rgbaLine[i].R shl 16) ) shr 23 )
      if (rgbaLine[i].Red shr 7) = 1 then begin
         rgbaLine[i].Red := 255;
         rgbaLine[i].Green := 255;
         rgbaLine[i].Blue := 255;
         rgbaLine[i].Alpha := 255;
      end else begin
         rgbaLine[i].Red := 0;
         rgbaLine[i].Green := 0;
         rgbaLine[i].Blue := 0;
         rgbaLine[i].Alpha := 0;
      end;
    end;
   end;
   bmp_src.LoadFromIntfImage(lazBMP);
   lazBMP.free;
end;

procedure simulate1bppIn24bpp(var bmp_src : TBitmap);
var
 lazBMP: TLazIntfImage;
 pRGB : PRGBTriple;
 i, j : LongInt;
begin
   lazBMP:=bmp_src.CreateIntfImage;
   // Conversión a 1 bit
   for j := 0 to bmp_src.height - 1 do begin
    pRGB := lazBMP.GetDataLineStart(j);
    for i := 0 to bmp_src.width - 1 do begin
      if (pRGB[i].rgbtRed shr 7) = 1 then begin
         pRGB[i].rgbtRed := 255;
         pRGB[i].rgbtGreen := 255;
         pRGB[i].rgbtBlue := 255;
      end else begin
         pRGB[i].rgbtRed := 0;
         pRGB[i].rgbtGreen := 0;
         pRGB[i].rgbtBlue := 0;
      end;
    end;
   end;
   bmp_src.LoadFromIntfImage(lazBMP);
   lazBMP.free;
   //bmp_src.TransparentColor:=clBlack;
   //bmp_src.Transparent:=true;
end;


procedure createBitmap8bpp_bis(var bmp_dst, bmp_src : TBitmap);
begin
   bmp_dst.PixelFormat:=pf8bit;
   bmp_dst.Palette:=create_hpal(FPG_Header.palette);
   bmp_dst.SetSize(bmp_src.Width,bmp_src.Height);
   copyPixels(bmp_dst,bmp_src,0,0);
end;

procedure createBitmap8bpp(var bmp_dst, bmp_src : TBitmap);
var
 lazBMP_src: TLazIntfImage;
 lazBMP_dst: TLazIntfImage;
 curcolor : TFPColor;
 curByte : PByte;
 i, j : LongInt;
 pal_index : integer;
begin
   bmp_dst.PixelFormat:=pf8bit;
   bmp_dst.Palette:=create_hpal(FPG_Header.palette);
   bmp_dst.SetSize(bmp_src.Width,bmp_src.Height);

   lazBMP_src:= bmp_src.CreateIntfImage;
   lazBMP_dst:= bmp_dst.CreateIntfImage;
   for j := 0 to lazBmp_src.height - 1 do
   begin
    curByte := lazBmp_dst.GetDataLineStart(j);
    for i := 0 to lazBmp_src.width - 1 do
     begin
        curcolor:= lazBmp_src.Colors[i,j];
        pal_index := Find_Color(1, curcolor.red , curcolor.Green, curcolor.Blue);
        curByte[i]:=pal_index;
        //if curcolor.alpha < (127 shl 8) then
        //  curByte:=0;
     end;
   end;
   bmp_dst.LoadFromIntfImage(lazBMP_dst);
   lazBMP_dst.free;
   lazBMP_src.free;

end;
procedure simulate8bppIn24bpp(var bmp_src : TBitmap);
var
 lazBMP_src: TLazIntfImage;
 p_src : PRGBTriple;
 i, j : LongInt;
 pal_index : integer;
begin
   // Conversión a 8 bits
   lazBMP_src:= bmp_src.CreateIntfImage;
   for j := 0 to bmp_src.height - 1 do
   begin
    p_src := lazbmp_src.GetDataLineStart(j);

    for i := 0 to bmp_src.width - 1 do
     begin
        pal_index := Find_Color(0, p_src[i].rgbtRed , p_src[i].rgbtGreen, p_src[i].rgbtBlue);
        p_src[i].rgbtRed := FPG_Header.palette[pal_index * 3];
        p_src[i].rgbtGreen := FPG_Header.palette[(pal_index * 3)+1];
        p_src[i].rgbtBlue := FPG_Header.palette[(pal_index * 3)+2];
     end;
   end;
   bmp_src.LoadFromIntfImage(lazBMP_src);
   lazBMP_src.free;
   //bmp_src.TransparentColor:=RGBToColor(FPG_Header.palette[0],FPG_Header.palette[1],FPG_Header.palette[2]);
   //bmp_src.Transparent:=true;
end;

end.
