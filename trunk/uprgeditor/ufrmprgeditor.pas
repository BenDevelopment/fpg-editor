unit ufrmprgeditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynMemo, Forms, Controls, Graphics,
  Dialogs, Menus, ActnList, ComCtrls, StdActns,
  usynprghl
  ;



type

  { TfrmPRGEditor }

  TfrmPRGEditor = class(TForm)
    aCompile: TAction;
    aExit: TAction;
    aExecute: TAction;
    aSave: TAction;
    ActionList: TActionList;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditDelete1: TEditDelete;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    MainMenu: TMainMenu;
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
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    SearchFind1: TSearchFind;
    SearchFindFirst1: TSearchFindFirst;
    SearchFindNext1: TSearchFindNext;
    SearchReplace1: TSearchReplace;
    StatusBar: TStatusBar;
    SynMemo1: TSynMemo;
    procedure aExitExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SearchFind1Accept(Sender: TObject);
    procedure TFindDialogFind(Sender: TObject);
  private
    { private declarations }
    highlr: TSynPrgHl;
  public
    found : boolean;
    fpos : integer;
    { public declarations }
  end;

var
  frmPRGEditor: TfrmPRGEditor;

resourcestring
  LNG_PRG_EDITOR ='Editor de Archivos de Programa';

implementation

{$R *.lfm}

{ TfrmPRGEditor }

procedure TfrmPRGEditor.FileOpen1Accept(Sender: TObject);
begin
  SynMemo1.Lines.LoadFromFile( FileOpen1.Dialog.FileName);;
  Caption:=LNG_PRG_EDITOR + ' - ' + ExtractFileNameOnly(  FileOpen1.Dialog.FileName);
end;

procedure TfrmPRGEditor.FileSaveAs1Accept(Sender: TObject);
begin
  SynMemo1.Lines.SaveToFile(FileSaveAs1.Dialog.FileName);
  FileOpen1.Dialog.FileName:=FileSaveAs1.Dialog.FileName;
  Caption:=LNG_PRG_EDITOR + ' - ' + ExtractFileNameOnly(  FileOpen1.Dialog.FileName);
end;

procedure TfrmPRGEditor.FormCreate(Sender: TObject);
begin
  Caption:=LNG_PRG_EDITOR;
  highlr := TSynPrgHl.Create(Self);
  SynMemo1.Highlighter:= highlr;
end;

procedure TfrmPRGEditor.SearchFind1Accept(Sender: TObject);
begin
end;

procedure TfrmPRGEditor.TFindDialogFind(Sender: TObject);
var
  FindS: String;
  IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
  Res : integer;
begin
  {FPos is global}
  Found:= False;
  FLen := Length(SearchFind1.Dialog.FindText);
  SLen := Length(SynMemo1.Lines.Text);
  FindS := SearchFind1.Dialog.FindText;

 //following 'if' added by mike
  if frMatchcase in SearchFind1.Dialog.Options then
     IPos := Pos(FindS, Copy(SynMemo1.Lines.Text,FPos+1,SLen-FPos))
  else
     IPos := Pos(AnsiUpperCase(FindS),AnsiUpperCase( Copy(SynMemo1.Lines.Text,FPos+1,SLen-FPos)));

  If IPos > 0 then begin
    FPos := FPos + IPos;
 //   Hoved.BringToFront;       {Edit control must have focus in }
    SynMemo1.SetFocus;
    Self.ActiveControl := SynMemo1;
    SynMemo1.SelStart:= FPos;  // -1;   mike   {Select the string found by POS}
    SynMemo1.SelEnd:=SynMemo1.SelStart + FLen;     //Memo1.SelLength := FLen;
    Found := True;
    FPos:=FPos+FLen-1;   //mike - move just past end of found item

  end
  Else
  begin
    Res := MessageDlg('Text was not found!',
           'Find', mtInformation ,  [mbOK],0);
    FPos := 0;
  end;

end;

procedure TfrmPRGEditor.aSaveExecute(Sender: TObject);
begin
  if FileOpen1.Dialog.FileName = '' then
     FileSaveAs1.Execute
  else
     SynMemo1.Lines.SaveToFile(FileOpen1.Dialog.FileName);
end;

procedure TfrmPRGEditor.aExitExecute(Sender: TObject);
begin
  Close;
end;

end.

