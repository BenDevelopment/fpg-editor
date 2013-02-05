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

unit uLanguage;


interface

uses Forms, FileUtil, inifiles, SysUtils, uinifile;

const
 NUM_OF_STRINGS                 = 200;

 LNG_LOADING_FILES = 58;
 LNG_SAVE_CHANGES = 59;
 LNG_WARNING = 60;
 LNG_WILL_BE_SELECT_IMAGE = 61;
 LNG_ONLY_ONE_IMAGE_EDIT = 62;
 LNG_UNZIP_FPG = 63;
 LNG_EXISTS_FILE_OVERWRITE = 64;
 LNG_FPG_SELECT_ONLY_ONE = 65;
 LNG_EXPORT = 66;
 LNG_SELECT_MORE_IMAGES_FOR_ANIMATE = 67;
 LNG_NOT_IMAGES_FOR_CONVERT = 68;
 LNG_ERROR = 69;
 LNG_ADAPT_IMAGES = 70;
 LNG_PROCESING_IMAGES = 71;
 LNG_ANALISING_IMAGES = 72;
 LNG_UPDATE_IMAGES = 73;
 LNG_PALETTE_PRECISION = 74;
 LNG_INFO = 75;
 LNG_SAVE_FPG = 76;
 LNG_CORRECT_SAVING = 77;
 LNG_WRONG_FPG = 78;
 LNG_CREATING_CONVERT_TABLE = 79;
 LNG_EXIST_CODE = 110;
 LNG_INCORRECT_SIZEOFICON = 111;
 LNG_SURE_DELETE_ALLPOINTS = 112;
 LNG_INSERT_COORD = 113;
 LNG_NOTLOAD_PALETTE = 118;
 LNG_FILE_EXIST = 119;
 LNG_FILE_NOTEXIST = 120;
 LNG_NOTFPG = 126;
 LNG_NOT_FOUND_PALETTE = 127;
 LNG_NOT_OPEN_FILE = 128;
 LNG_FILE_LANGUAGE_INCORRECT = 129;
 LNG_NOT_CLIPBOARD_IMAGE = 130;
 LNG_NOT_EXIST_FPG = 131;
 LNG_IMAGE_TO_CLIPBOARD = 134;
 LNG_IMAGE_TO = 137;
 LNG_PALETTE_TO = 138;
 LNG_ARE_YOU_SURE_DELETE_IMAGES = 140;
 LNG_IMAGES_MOVED_RECICLEDBIN = 141;

var
 LNG_STRINGS : array [ 0 .. NUM_OF_STRINGS ] of string;
 LNG_DESCRIPTION, LNG_INF : string;

 procedure load_language;
 procedure load_lnginfo;

implementation

procedure load_lnginfo;
var
 lngfile : TIniFile;
begin
 lngfile := TIniFile.Create(inifile_language);

 LNG_DESCRIPTION := lngfile.ReadString('LNG', 'Description', 'NULL');
 LNG_INF := lngfile.ReadString('LNG', 'INFO', 'NULL');

 lngfile.Destroy;
end;

procedure load_language;
var
 lngfile : TIniFile;
 i : integer;
begin
 // Si no existe el fichero cambia al lenguaje por defecto
 if not FileExistsUTF8(inifile_language) { *Converted from FileExists*  } then
 begin
  inifile_language := ExtractFileDir(Application.ExeName) + sDEFAULT_LNG;
  write_inifile;
 end;

 lngfile := TIniFile.Create(inifile_language);

 LNG_DESCRIPTION := lngfile.ReadString('LNG', 'Description', 'NULL');
 LNG_INF := lngfile.ReadString('LNG', 'INFO', 'NULL');

 for i := 0 to NUM_OF_STRINGS - 1 do
  LNG_STRINGS[ i ] := lngfile.ReadString('LNG', IntToStr(i), 'NULL');

 lngfile.Destroy;
end;

end.
