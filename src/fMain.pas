unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Menus, System.Actions, FMX.ActnList, FMX.StdActns, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.TabControl;

type
  TForm1 = class(TForm)
    ActionList1: TActionList;
    ToolBar1: TToolBar;
    FileExit1: TFileExit;
    MainMenu1: TMainMenu;
    mnuFichier: TMenuItem;
    mnuFichierQuitter: TMenuItem;
    mnuMac: TMenuItem;
    mnuFichierOuvrir: TMenuItem;
    mnuFichierEnregistrer: TMenuItem;
    mnuFichierSeparateur: TMenuItem;
    btnNouveau: TButton;
    btnOuvrir: TButton;
    btnEnregistrer: TButton;
    btnFermer: TButton;
    svgOuvrir: TPath;
    svgEnregistrer: TPath;
    svgFermer: TPath;
    svgNew: TPath;
    mnuFichierFermer: TMenuItem;
    mnuFichierNouveau: TMenuItem;
    actNouveauFichier: TAction;
    actChargerFichier: TAction;
    actEnregistrerFichier: TAction;
    actFermerFichier: TAction;
    StyleBook1: TStyleBook;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    TabControl1: TTabControl;
    procedure FormCreate(Sender: TObject);
    procedure actNouveauFichierExecute(Sender: TObject);
    procedure actFermerFichierExecute(Sender: TObject);
    procedure actChargerFichierExecute(Sender: TObject);
    procedure actEnregistrerFichierExecute(Sender: TObject);
    procedure mmoChangeTracking(Sender: TObject);
  private
    procedure CreerUnOngletVide;
    procedure MetAJourTitreOnglet;
    procedure PositionneSurMemoDeLOngletActif;
    { Déclarations privées }
  protected
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils;

procedure TForm1.actChargerFichierExecute(Sender: TObject);
begin
  if OpenDialog1.Execute and (OpenDialog1.FileName <> '') and
    tfile.Exists(OpenDialog1.FileName) then
  begin
    CreerUnOngletVide;
    TabControl1.ActiveTab.tagstring := OpenDialog1.FileName;
    (TabControl1.ActiveTab.TagObject as tmemo).Lines.LoadFromFile
      (TabControl1.ActiveTab.tagstring);
    TabControl1.ActiveTab.tag := 0;
    MetAJourTitreOnglet;
  end;
  PositionneSurMemoDeLOngletActif;
end;

procedure TForm1.actEnregistrerFichierExecute(Sender: TObject);
var
  mmo: tmemo;
  NomDuFichierOuvert: string;
begin
  if assigned(TabControl1.ActiveTab) and
    assigned(TabControl1.ActiveTab.TagObject) and
    (TabControl1.ActiveTab.TagObject is tmemo) and
    (TabControl1.ActiveTab.tag = 1) then
    mmo := TabControl1.ActiveTab.TagObject as tmemo
  else
    exit;

  if (mmo.Lines.Count < 1) or ((mmo.Lines.Count = 1) and (mmo.Lines[0].isempty))
  then
  begin
    mmo.setfocus;
    TabControl1.ActiveTab.tag := 0;
    exit;
  end;

  NomDuFichierOuvert := TabControl1.ActiveTab.tagstring;
  if NomDuFichierOuvert.isempty and SaveDialog1.Execute and
    (SaveDialog1.FileName <> '') then
    NomDuFichierOuvert := SaveDialog1.FileName;

  if not NomDuFichierOuvert.isempty then
  begin
    mmo.Lines.SaveToFile(NomDuFichierOuvert, tencoding.UTF8);
    TabControl1.ActiveTab.tagstring := NomDuFichierOuvert;
    TabControl1.ActiveTab.tag := 0;
    MetAJourTitreOnglet;
  end;

  mmo.setfocus;
end;

procedure TForm1.actFermerFichierExecute(Sender: TObject);
begin
  if assigned(TabControl1.ActiveTab) then
  begin
    if TabControl1.ActiveTab.tag = 1 then
      actEnregistrerFichierExecute(Sender);
    TabControl1.delete(TabControl1.ActiveTab.Index);
  end;
  PositionneSurMemoDeLOngletActif;
end;

procedure TForm1.actNouveauFichierExecute(Sender: TObject);
begin
  CreerUnOngletVide;
  MetAJourTitreOnglet;
  PositionneSurMemoDeLOngletActif;
end;

procedure TForm1.CreerUnOngletVide;
var
  ti: ttabitem;
  mmo: tmemo;
begin
  ti := TabControl1.Add;
  ti.Text := '';
  ti.tagstring := '';
  ti.tag := 0;
  mmo := tmemo.Create(ti);
  mmo.Parent := ti;
  ti.TagObject := mmo;
  mmo.Align := talignlayout.Client;
  mmo.Lines.Clear;
  mmo.OnChangeTracking := mmoChangeTracking;
  TabControl1.ActiveTab := ti;
  mmo.setfocus;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IF not Defined(MACOS)}
  // tout sauf macOS
  mnuMac.Visible := false;
{$ELSE}
  // sur macOS
  mnuFichierSeparateur.Visible := false;
  mnuFichierQuitter.Visible := false;
{$ENDIF}
  OpenDialog1.InitialDir := TPath.GetDocumentsPath;
  SaveDialog1.InitialDir := TPath.GetDocumentsPath;
end;

procedure TForm1.MetAJourTitreOnglet;
begin
  TabControl1.ActiveTab.Text := TPath.GetFileNameWithoutExtension
    (TabControl1.ActiveTab.tagstring);
  if TabControl1.ActiveTab.tag = 1 then
    TabControl1.ActiveTab.Text := TabControl1.ActiveTab.Text + '(*)';
end;

procedure TForm1.PositionneSurMemoDeLOngletActif;
begin
  if assigned(TabControl1.ActiveTab) and
    assigned(TabControl1.ActiveTab.TagObject) and
    (TabControl1.ActiveTab.TagObject is tmemo) then
    (TabControl1.ActiveTab.TagObject as tmemo).setfocus;
end;

procedure TForm1.mmoChangeTracking(Sender: TObject);
begin
  if TabControl1.ActiveTab.tag = 0 then
  begin
    TabControl1.ActiveTab.tag := 1;
    MetAJourTitreOnglet;
  end;
end;

end.
