unit utestfpglistview;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, uFPGListView;

type

  { TForm1 }

  TForm1 = class(TForm)
    FPGListView1: TFPGListView;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

