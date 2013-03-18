unit usynprghl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, SynEditTypes, SynEditHighlighter;

type

  { TSynPrgHl }


  TSynPrgHl = class(TSynCustomHighlighter)
  private
    FRWordsAttri: TSynHighlighterAttributes;
    FNWordsAttri: TSynHighlighterAttributes;
    FTokenPos, FTokenEnd: Integer;
    FLineText: String;
    procedure SetRWordsAttri(AValue: TSynHighlighterAttributes);
    procedure SetNWordsAttri(AValue: TSynHighlighterAttributes);

  public
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetToken: String; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    constructor Create(AOwner: TComponent); override;

  published
    property RWordsAttri: TSynHighlighterAttributes read FRWordsAttri
      write SetRWordsAttri;
    property NWordsAttri: TSynHighlighterAttributes read FNWordsAttri
      write SetNWordsAttri;

  end;

const
  PRG_RESERVED_WORDS : array[1..55] of string =
    ('array',
    'begin',
    'break',
    'byte' ,
    'call' ,
    'case' ,
    'clone',
    'const',
    'continue',
    'debug' ,
    'declare',
    'default',
    'dup'    ,
    'elif'   ,
    'else'   ,
    'elseif' ,
    'elsif'  ,
    'end'    ,
    'float'   ,
    'for'    ,
    'frame'  ,
    'from'   ,
    'function',
    'global' ,
    'goto'   ,
    'if'     ,
    'import' ,
    'include',
    'int'    ,
    'jmp'    ,
    'local'  ,
    'loop'   ,
    'offset' ,
    'onExit' ,
    'pointer',
    'private',
    'process',
    'program',
    'public' ,
    'repeat' ,
    'return' ,
    'short'  ,
    'sizeof' ,
    'step'   ,
    'string' ,
    'struct' ,
    'switch' ,
    'to'     ,
    'type'   ,
    'until'  ,
    'varspace',
    'void',
    'while',
    'word',
    'yield');


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FPG Editor', [TSynPrgHl]);
end;

constructor TSynPrgHl.Create(AOwner: TComponent);
var
  i :Integer;
begin
  inherited Create(AOwner);

  FRWordsAttri := TSynHighlighterAttributes.Create('reserved', 'reserved');
  AddAttribute(FRWordsAttri);
  FRWordsAttri.Foreground:=clRed;

  FNWordsAttri := TSynHighlighterAttributes.Create('normal', 'normal');
  AddAttribute(FNWordsAttri);
  FNWordsAttri.Foreground:=clBlack;


end;

procedure TSynPrgHl.SetRWordsAttri(AValue: TSynHighlighterAttributes);
begin
  FRWordsAttri.Assign(AValue);
end;

procedure TSynPrgHl.SetNWordsAttri(AValue: TSynHighlighterAttributes);
begin
  FNWordsAttri.Assign(AValue);
end;


procedure TSynPrgHl.SetLine(const NewValue: String; LineNumber: Integer);
begin
  inherited;
  FLineText := NewValue;
  FTokenEnd := 1;
  Next;
end;

procedure TSynPrgHl.Next;
var
  l: Integer;
begin
  FTokenPos := FTokenEnd;
  FTokenEnd := FTokenPos;

  l := length(FLineText);
  If FTokenPos > l then
    exit
  else
  if FLineText[FTokenEnd] in [#9, ' '] then
    while (FTokenEnd <= l) and (FLineText[FTokenEnd] in [#0..#32]) do inc (FTokenEnd)
  else
    while (FTokenEnd <= l) and not(FLineText[FTokenEnd] in [#9, ' ']) do inc (FTokenEnd)
end;

function TSynPrgHl.GetEol: Boolean;
begin
  Result := FTokenPos > length(FLineText);
end;

procedure TSynPrgHl.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenStart := @FLineText[FTokenPos];
  TokenLength := FTokenEnd - FTokenPos;
end;

function TSynPrgHl.GetTokenAttribute: TSynHighlighterAttributes;
var
  i: Integer;
begin
  // Match the text, specified by FTokenPos and FTokenEnd
  Result := FNWordsAttri;
  for i:=1 to length(PRG_RESERVED_WORDS) do
    if LowerCase(copy(FLineText, FTokenPos, FTokenEnd - FTokenPos)) = PRG_RESERVED_WORDS[i] then
    begin
      Result := FRWordsAttri;
      break;
    end;

end;

function TSynPrgHl.GetToken: String;
begin
  Result := copy(FLineText, FTokenPos, FTokenEnd - FTokenPos);
end;

function TSynPrgHl.GetTokenPos: Integer;
begin
  Result := FTokenPos - 1;
end;

function TSynPrgHl.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := FRWordsAttri;
    SYN_ATTR_IDENTIFIER: Result := FNWordsAttri;
    SYN_ATTR_WHITESPACE: Result := FNWordsAttri;
    else Result := nil;
  end;
end;

function TSynPrgHl.GetTokenKind: integer;
var
  a: TSynHighlighterAttributes;
begin
  // Map Attribute into a unique number
  a := GetTokenAttribute;
  Result := 0;
  if a = FRWordsAttri then Result := 1;
  if a = FNWordsAttri then Result := 2;
end;


end.

