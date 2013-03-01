program pfpgeditor;


uses
  Forms, Dialogs, uFrmMain, uBMP, uTools, uSort, uPCX, ufrmView,
  uLoadImage, uCopyPalette, uPAL, uColor16bits, uFPGConvert,
  ufrmFPGImages, ufrmNewFPG, ufrmAnimate, ufrmConfig, uFrmExport,
  uExportToFiles, ufrmPalette, uFrmSplahs, uinifile, uLanguage,
  uAAText, uColorTable, uFNT, uFrmBpp, uFrmCFG, uFrmMainFNT, uFrmAbout,
  uFrmInputBox, uFrmMessageBox, Interfaces, uFrmFNTView,
  uMAPGraphic, uFPG, uFPGListView, ufrmZipFenix;

{$R *.res}

begin
  Application.Initialize;
  Application.Title:='FPG Editor';

  try
  except
   showmessage('Error, no se encuentran suficientes recursos para iniciar el programa.'
             + ' Salga de uno o más programas si desea ejecutar este programa.');
   Exit;
  end;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAnimate, frmAnimate);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmFPGImages, frmFPGImages);
  Application.CreateForm(TfrmInputBox, frmInputBox);
  Application.CreateForm(TfrmMessageBox, frmMessageBox);
  Application.CreateForm(TfrmNewFPG, frmNewFPG);
  Application.CreateForm(TfrmPalette, frmPalette);
  Application.CreateForm(TfrmView, frmView);
  Application.CreateForm(TfrmMainFNT, frmMainFNT);
  Application.CreateForm(TFrmCFG, FrmCFG);
  Application.CreateForm(TfBPP, fBPP);
  Application.CreateForm(TFrmAbout, FrmAbout);
  Application.CreateForm(TfrmFNTView, frmFNTView);
  Application.CreateForm(TfrmZipFenix, frmZipFenix);
  //Application.CreateForm(TfrmSplash, frmSplash);
  Application.Run;
end.
