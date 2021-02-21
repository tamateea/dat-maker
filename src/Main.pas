(*

DatMaker V1.0

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*)

unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, FileCtrl, OpenGl1x, minmax, progsettings,
  MQOout, tricenters, FileRSM, spuds, Textures, ShlObj, trig, OpenMQO, MakeDat, Buttons;

  //, FileRSMnewV2
//Textures,

type
  TMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    OpenFolder1: TMenuItem;
    N1: TMenuItem;
    Export1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    N3DS1: TMenuItem;
    About1: TMenuItem;
    Help1: TMenuItem;
    About2: TMenuItem;
    FileListBox: TFileListBox;
    FileOpen: TOpenDialog;
    ColorDialog: TColorDialog;
    Panel3: TPanel;
    CheckBox1: TCheckBox;
    Button2: TButton;
    Label5: TLabel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    c_fill: TCheckBox;
    c_edges: TCheckBox;
    c_points: TCheckBox;
    c_grid: TCheckBox;
    c_axis: TCheckBox;
    Label3: TLabel;
    TRI: TCheckBox;
    c_cullface: TCheckBox;
    Label2: TLabel;
    Label1: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    C_Box: TComboBox;
    Button1: TButton;
    panel4: TPanel;
    MQOv21: TMenuItem;
    Convert1: TMenuItem;
    Old2New1: TMenuItem;
    New2Old1: TMenuItem;
    CheckBox9: TCheckBox;
    Edit1: TEdit;
    Label4: TLabel;
    Settings1: TMenuItem;
    SaveSettings1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Shape1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      procedure Shape4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      procedure Shape5MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      procedure Shape6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      procedure Shape7MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FileListBoxClick(Sender: TObject);
    procedure FileListBoxDblClick(Sender: TObject);
    procedure c_cullfaceClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure OpenFolder1Click(Sender: TObject);
    procedure N3DS1Click(Sender: TObject);
    procedure debug1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);


    procedure Button4Click(Sender: TObject);
    procedure C_BoxChange(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
    procedure TRIClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit1Exit(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SaveColors1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    
      private
    procedure Draw(Sender: TObject; var Done: Boolean);
    procedure glInit;
    procedure DrawGrid(num: Integer; size: Single);
    procedure SwitchView(Ortho: Boolean=false);
  end;

const
  version = '1.3 ';
  ambient : array[1..4] of GLfloat = (0.5, 0.5, 0.5, 1.0);

var
  Main1: TMain;
  DC, RC, Base: Cardinal;
  Mx, My, mkey, texnum, persp, transval: Integer;
  Ax, Ay, Zoom, panX, panY: Single;
  cmap: array of TVector3f;
  edgecolor,t1,t2,t3,t4,t5,bfill: TVector3f;
  FileName, colorstr : String;


    // Textures
  myTexture : array[0..49] of glUint;


implementation

{$R *.dfm}




procedure UpdateTitle;
var Title: String;
begin
  Title := Format('DatMaker v%s [v:%d f:%d]', [version, Length(V), Length(F)]);
  Main1.Caption := Title;
  Application.Title := Title;
end;

function BrowseDialogCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
    SendMessage(Wnd, BFFM_SETSELECTION, 1, Integer(@Main1.FileListBox.Directory[1]));
  Result := 0;
end;

function BrowseDialog(Title: String; Flag: Integer): String;
var
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of Char;
  TempPath : array[0..MAX_PATH] of Char;
begin
  Result:='';
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  with BrowseInfo do begin
    hwndOwner := Application.Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    ulFlags := Flag;
    lpfn := BrowseDialogCallBack;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Result := TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;

procedure TMain.glInit;
var
  i: Byte;
  f: Cardinal;
  index, y, x: Integer;
  color, saturation, cx, r, g, b, sat, sat2, rc, gc, bc: Single;
begin
  glShadeModel(GL_SMOOTH);
  glClearColor(0.75, 0.75, 0.75, 1);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHTING);
  glEnable(GL_NORMALIZE);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_TEXTURE_2D);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @ambient);
  if c_cullface.Enabled then glEnable(GL_CULL_FACE);
  Base := glGenLists(96);
  f := CreateFont(-12, 0, 0, 0, 0, 0, 0, 0,
         ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
         ANTIALIASED_QUALITY, FF_DONTCARE or DEFAULT_PITCH,
         '_sans'
       );
  SelectObject(DC, f);
  wglUseFontBitmaps(DC, 32, 96, Base);

  edgecolor[0] := 0.8; edgecolor[1] := 0.8; edgecolor[2] := 0;
  Shape2.Brush.Color := rgb(
    Round(edgecolor[0] * 255), Round(edgecolor[1] * 255), Round(edgecolor[2] * 255)
  );

  // Color Map Generation
  SetLength(cmap, 512 * 128);
  index := 0;
  for y := 0 to 511 do begin
    color := y / 8 / 64 + 0.0078125;
    saturation := (y and 7) / 8 + 0.0625;
    for x := 0 to 127 do begin
      cx := x / 128;
      r := cx;
      g := cx;
      b := cx;
      if saturation <> 0.0 then begin
        if cx < 0.5 then
          sat := cx * (1 + saturation)
        else
          sat := (cx + saturation) - cx * saturation;
        sat2 := 2 * cx - sat;
        rc := color + 0.3;
        if rc > 1 then
          rc := rc - 1;
        gc := color;
        bc := color - 0.3;
        if bc < 0 then
          bc := bc + 1;
        if 6 * rc < 1 then
          r := sat2 + (sat - sat2) * 6 * rc
        else if 2 * rc < 1 then
          r := sat
        else if 3 * rc < 2 then
          r := sat2 + (sat - sat2) * (0.7 - rc) * 6
        else
          r := sat2;
        if 6 * gc < 1 then
          g := sat2 + (sat - sat2) * 6 * gc
        else if 2 * gc < 1 then
          g := sat
        else if 3 * gc < 2 then
          g := sat2 + (sat - sat2) * (0.7 - gc) * 6
        else
          g := sat2;
        if 6 * bc < 1 then
          b := sat2 + (sat - sat2) * 6 * bc
        else if 2 * bc < 1 then
          b := sat
        else if 3 * bc < 2 then
          b := sat2 + (sat - sat2) * (0.7 - bc) * 6
        else
          b := sat2;
      end;
      cmap[index][0] := r;
      cmap[index][1] := g;
      cmap[index][2] := b;
      Inc(index);
    end;
  end;
  MakeCMAP3;
 Makecmap2;
end;

procedure glPrint(Text: String; px: Single=0; py: Single=0; pz: Single=0; r: Single=0; g: Single=0; b: Single=0);
begin
  if Text <> '' then
  begin
    glColor3f(r, g, b);
    glRasterPos3f(px, py, pz);
    glPushAttrib(GL_LIST_BIT);
    glListBase(Base - 32);
    glCallLists(Length(Text), GL_UNSIGNED_BYTE, PChar(Text));
    glPopAttrib;
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
var
  pfd: TPIXELFORMATDESCRIPTOR;
  pf: Integer;
begin

  t1[0] := 1.0; t1[1] := 1.0; t1[2] := 1.0;
  t2[0] := 0.0; t2[1] := 0.0; t2[2] := 0.0;
  t3[0] := 1.0; t3[1] := 0.5; t3[2] := 1.0;
  t4[0] := 1.0; t4[1] := 1.0; t4[2] := 0.0;
  t5[0] := 0.0; t5[1] := 1.0; t5[2] := 0.0;
  bfill[0] := 0.753; bfill[1] := 0.753; bfill[2] := 0.753;


  Animate := False;
  Fskin := 0;
  Vskin := 0;
  TP := 255;
  Zoom := -10;
  Ax := -45;
  Ay := 15;
  panX := 0;
  panY := 0;
  objcx := 0.0;  objcy := 0.0; objcz := 0.0;
  Model_Version := 0;
  persp := 50;
  UserPri := 0;

  InitOpenGL;

  DC := GetDC(Panel1.Handle);
  pfd.nSize := SizeOf(pfd);
  pfd.nVersion := 1;
  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or 0;
  pfd.iPixelType := PFD_TYPE_RGBA;
  pfd.cRedBits := 8;
  pfd.cGreenBits := 8;
  pfd.cBlueBits := 8;
  pfd.cColorBits := 32;
  pf := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, pf, @pfd);
  RC := wglCreateContext(dc);
  wglMakeCurrent(DC, RC);
  glInit;
  glEnable(GL_TEXTURE_2D);
//  for texnum := 0 to 49 do
//  begin
//  LoadTexture('textures/'+IntToStr(texnum)+'.bmp', myTexture[texnum], FALSE);
//  end;
    //it's here, calling the bmp loader from textures unit instead of bmp unit...
  //causes the image to be black, why?
  //argh, the texture environment labels were changed!!!!
  //use decals instead.

// LoadTexture('30b.tga', myTexture, FALSE);
 // FileListBox.ApplyFilePath('Models');

  LoadSettings;
  If Settings_Loaded = True then
  begin
  edgecolor := setedgecolor ;
  t1 := set_t1;
  t2 := set_t2;
  t3 := set_t3;
  t4 := set_t4;
  t5 := set_t5;
  bfill := set_bfill;
  Shape7.Brush.Color := RGB(Round(t5[0]*255), Round(t5[1]*255), Round(t5[2]*255));
  Shape6.Brush.Color := RGB(Round(t3[0]*255), Round(t3[1]*255), Round(t3[2]*255));
  Shape5.Brush.Color := RGB(Round(t4[0]*255), Round(t4[1]*255), Round(t4[2]*255));
  Shape4.Brush.Color := RGB(Round(t2[0]*255), Round(t2[1]*255), Round(t2[2]*255));
  Shape3.Brush.Color := RGB(Round(t1[0]*255), Round(t1[1]*255), Round(t1[2]*255));
  Shape2.Brush.Color := RGB(Round(edgecolor[0]*255), Round(edgecolor[1]*255), Round(edgecolor[2]*255));
  Shape1.Brush.Color := RGB(Round(bfill[0]*255), Round(bfill[1]*255), Round(bfill[2]*255));
  glClearColor(bfill[0], bfill[1], bfill[2], 1);

    FileListBox.Directory := '.';
    FileOpen.InitialDir := Dir_user;
    FileListBox.Directory := FileOpen.InitialDir; // reset
    FileListBox.FileName := Cur_file_user;

   //with Sender as TFileListBox do
 //  FileListBox.OnClick := ;

  end;

  Application.OnIdle := Draw;
end;

procedure TMain.Draw(Sender: TObject; var Done: Boolean);
var
  i, j: Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  Switchview;
  glLoadIdentity;
  glTranslatef(panX, panY, Zoom);
  glTranslatef(objcx, objcy, objcz);      //move to center
  glRotatef(Ay, 1, 0, 0);
  glRotatef(Ax, 0, 1, 0);
  glTranslatef(-objcx, -objcy, -objcz);          //move back

//        glPointSize(10.0);
//        glBegin(GL_POINTS);
//         glColor3f(0, 1, 0);
//         glVertex3f(objcx, objcy, objcz);
//         glEnd;


  if c_grid.Checked then DrawGrid(6, 1.7);

   glPushMatrix;
  glScalef(1 / 50, 1 / 50, 1 / 50);
   glDisable(GL_TEXTURE_2D);

  for i := 0 to High(F) do begin
    //if (M[i] Shl 3) < 2 then begin
      if (c_fill.Checked) then begin
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        glEnable(GL_LIGHTING);
 //       If c_facefill.Checked then glDisable(GL_LIGHTING);
        If Checkbox7.Checked then transval := 512
        else transval := 255;
        glBegin(GL_TRIANGLES);
        glColor4f(cmap[C[i]][0], cmap[C[i]][1], cmap[C[i]][2], (255 - A[i]) / transval);
        if (Checkbox8.Checked) AND (High(Fskin) > 0) then glColor4f(CMap3[Fskin[i]][0], CMap3[Fskin[i]][1], CMap3[Fskin[i]][2],1.0);
     //   If Checkbox8.Checked then glColor4f(bfill[0], bfill[1], bfill[2], 1.0);
        glNormal3fv(@N[F[i][0]]);
        glVertex3f(V[F[i][0]][0], V[F[i][0]][1], V[F[i][0]][2]);
        glNormal3fv(@N[F[i][1]]);
        glVertex3f(V[F[i][1]][0], V[F[i][1]][1], V[F[i][1]][2]);
        glNormal3fv(@N[F[i][2]]);
        glVertex3f(V[F[i][2]][0], V[F[i][2]][1], V[F[i][2]][2]);
        glEnd;


      end;
      if c_edges.Checked then begin
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glDisable(GL_LIGHTING);
        glBegin(GL_TRIANGLES);
        glColor3f(edgecolor[0], edgecolor[1], edgecolor[2]);
        glVertex3f(V[F[i][0]][0], V[F[i][0]][1], V[F[i][0]][2]);
        glVertex3f(V[F[i][1]][0], V[F[i][1]][1], V[F[i][1]][2]);
        glVertex3f(V[F[i][2]][0], V[F[i][2]][1], V[F[i][2]][2]);
        glEnd;
      end;





        if (CheckBox1.Checked) OR (CheckBox3.Checked) OR (CheckBox5.Checked) then begin
         glPointSize(4.0);
         glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
         glDisable(GL_LIGHTING);
         glBegin(GL_POINTS);
         glColor4f(t2[0], t2[1], t2[2], 1.0);
         glNormal3fv(@N[F[i][0]]);
         glVertex3f(TriMids[i][0], TriMids[i][1], TriMids[i][2]);
         glEnd;
         If CheckBox1.Checked then glPrint('  '+IntToStr(i), TriMids[i][0], TriMids[i][1], TriMids[i][2], t2[0], t2[1], t2[2]);
         if ((CheckBox3.Checked) AND (High(Fskin) > 0)) then glPrint(' ____'+IntToStr(Fskin[i]), TriMids[i][0], TriMids[i][1], TriMids[i][2], t4[0], t4[1], t4[2]);
         if ((CheckBox5.Checked) AND (High(t_pri) > 0)) then glPrint(' ________'+IntToStr(t_pri[i]), TriMids[i][0], TriMids[i][1], TriMids[i][2], t5[0], t5[1], t5[2])
         else if ((CheckBox5.Checked) AND (Gi1 > 0) AND (i=1)) then glPrint(' ________PRIORITY FLAG = '+IntToStr(Gi1), TriMids[i][0], TriMids[i][1], TriMids[i][2], t5[0], t5[1], t5[2]);
 //         if c_vertnums.Checked then glPrint(' '+IntToStr(i), V[i][0], V[i][1], V[i][2], 1, 1, 1);
 //         if (c_skin.Checked) AND (High(Skin) > 0) then glPrint(' ____'+IntToStr(Skin[i]), V[i][0], V[i][1], V[i][2], 1, 1, 0.5);

      end;


    //end else begin
      // Textured Face
    //end;
  end;  //end of for loop



    if (c_points.Checked) OR (CheckBox2.Checked) OR (CheckBox4.Checked) then begin
      for i := 0 to High(V) do begin
         glPointSize(4.0);
         glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
         glDisable(GL_LIGHTING);
         glBegin(GL_POINTS);
         glColor3f(t1[0], t1[1], t1[2]);
         glVertex3f(V[i][0], V[i][1], V[i][2]);
         glEnd;
  //       glClear(GL_DEPTH_BUFFER_BIT);
          if CheckBox2.Checked then glPrint(' '+IntToStr(i), V[i][0], V[i][1], V[i][2], t1[0], t1[1], t1[2]);
          if (CheckBox4.Checked) AND (High(Skin) > 0) then glPrint(' ____'+IntToStr(Skin[i]), V[i][0], V[i][1], V[i][2], t3[0], t3[1], t3[2]);
      end;


  end;

  glPopMatrix;

  glDisable(GL_LIGHTING);
  if c_axis.Checked then begin
  SwitchView(true);
  glClear(GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
//  glTranslatef(0, 0, -10);
//  glPrint(IntToStr(Model_version), 5, 5, 0, 1.0, 1.0, 1.00);
  glTranslatef(30, 30, -30);
  glRotatef(Ay, 1, 0, 0);
  glRotatef(Ax, 0, 1, 0);
  glLineWidth(1);
  glBegin(GL_LINES);
    glColor3f(0.5, 0, 0);
    glVertex3f(10, 0, 0);
    glVertex3f(20, 0, 0);
  glEnd;
  glBegin(GL_LINES);
    glColor3f(0, 0.5, 0);
    glVertex3f(0, 10, 0);
    glVertex3f(0, 20, 0);
  glEnd;
  glBegin(GL_LINES);
    glColor3f(0, 0, 0.5);
    glVertex3f(0, 0, 10);
    glVertex3f(0, 0, 20);
  glEnd;
  glPrint('X', 25, 0, 0, 0.5, 0, 0);
  glPrint('Y', 0, 25, 0, 0, 0, 0.5);
  glPrint('Z', 0, 0, 25, 0, 0.5, 0);
 // glTranslatef(-5, 0, 0);
  glPrint(IntToStr(Model_version), 0, 0, 0, 1.0, 1.0, 1.00);
// glPrint(IntToStr(UserPri), 0, 0, 0, 1.0, 1.0, 1.00);
  end;

  SwapBuffers(DC);
end;

procedure TMain.DrawGrid(num: Integer; size: Single);
var i: Integer;
begin

  glLineWidth(1);
  glColor3f(0.4, 0.4, 0.4);
  glBegin(GL_LINES);
  for i := -num to num do
    if i <> 0 then begin
      glVertex3f(-num * size, 0, i * size); glVertex3f(num * size, 0, i * size);
      glVertex3f(i * size, 0, -num * size); glVertex3f(i * size, 0, num * size);
    end;
  glEnd;
  glLineWidth(2);
  glColor3f(0, 0, 0);
  glBegin(GL_LINES);
  glVertex3f(0, 0, size * num);  glVertex3f(0, 0, -size * num);
  glVertex3f(size * num, 0, 0);  glVertex3f(-size * num, 0, 0);
  glEnd;
end;

procedure TMain.SwitchView(Ortho: Boolean=false);
begin
  glViewport(0, 0, Panel1.Width, Panel1.Height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  if not Ortho then
    gluPerspective(persp, Panel1.Width / Panel1.Height, 0.01, 10000)
  else
    glOrtho(0, Panel1.Width, 0, Panel1.Height, 0.01, 500);
  glMatrixMode(GL_MODELVIEW);
end;

procedure TMain.Shape1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape1.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    bfill[0] := r / 255; bfill[1] := g / 255; bfill[2] := b / 255;
    glClearColor(bfill[0], bfill[1], bfill[2], 1);
  end;
end;

procedure TMain.Shape2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape2.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    edgecolor[0] := r / 255; edgecolor[1] := g / 255; edgecolor[2] := b / 255;
  end;
end;

procedure TMain.Shape3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape3.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    t1[0] := r / 255; t1[1] := g / 255; t1[2] := b / 255;
  end;
end;

procedure TMain.Shape4MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape4.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    t2[0] := r / 255; t2[1] := g / 255; t2[2] := b / 255;
  end;
end;

procedure TMain.Shape5MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape5.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    t4[0] := r / 255; t4[1] := g / 255; t4[2] := b / 255;
  end;
end;

procedure TMain.Shape6MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape6.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    t3[0] := r / 255; t3[1] := g / 255; t3[2] := b / 255;
      end;
end;


procedure TMain.Shape7MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r, g, b: Integer;
begin
  if ColorDialog.Execute then begin
    Shape7.Brush.Color := ColorDialog.Color;
    r := ColorDialog.Color and $ff;
    g := (ColorDialog.Color Shr 8) and $ff;
    b := (ColorDialog.Color Shr 16) and $ff;
    t5[0] := r / 255; t5[1] := g / 255; t5[2] := b / 255;
    end;
end;

procedure TMain.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then mkey := 1 else if (Button = mbRight) AND (not(ssShift in shift)) then mkey := 2 else if (Button = mbRight) AND (ssShift in shift) then mkey := 3 else mkey := 4;
  Mx := X;
  My := y;
end;

procedure TMain.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mkey := 0;
end;

procedure TMain.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if mkey > 0 then begin
    if mkey < 3 then Ax := Ax - (Mx - X) / 2;
    if mkey = 1 then
      Ay := Ay - (My - Y) / 2
    else if mkey = 2 then begin
        Zoom := Zoom - (My - Y) / 20;
        if Zoom >= 0 then Zoom := 0;
      end else if mkey = 3 then begin
         panX := panX - (Mx-X)/20;
         panY := panY - (Y-My)/20;
      end;
    Mx := X;
    My := Y;
  end;
end;

procedure TMain.FileListBoxClick(Sender: TObject);
var
FileExt : String;
NameLen : Integer;
begin
  begin
    FileName := FileListBox.FileName;
    FileExt := FileListBox.FileName;
    NameLen :=  Length(FileExt);
    Delete(FileExt,1,NameLen - 4);
//    MessageBox(0, PChar('fileExt'), PChar(FileExt), MB_OK);

//    if (FileExt <> '.mqo') then LoadRSM(FileListBox.FileName)
//    else LoadMQO(FileListBox.FileName);

    if (FileExt = '.mqo') then LoadMQO(FileListBox.FileName)
    else LoadRSM(FileListBox.FileName);



//    if (AnsiCompareStr(FileExt,'.mqo')=0) then LoadMQO(FileOpen.FileName)
//    else if (AnsiCompareStr(FileExt,'.dat') =0) then LoadRSM(FileOpen.FileName)
//    else if (FileExt = '.mdl') then LoadRSM(FileOpen.FileName);

  end;
//    DoStuff;
//Animate := False;
If High(v) > 0 then FindMinMax;
GetCenters;
  UpdateTitle;
  Cur_file_user := FileName;
end;

procedure TMain.FileListBoxDblClick(Sender: TObject);
var
FileExt : String;
NameLen : Integer;
begin
    begin
    FileName := FileListBox.FileName;
    FileExt := FileListBox.FileName;
        NameLen :=  Length(FileExt);
    Delete(FileExt,1,NameLen - 4);
 //   MessageBox(0, PChar('fileExt'), PChar(FileExt), MB_OK);
    if (FileExt = '.mqo') then LoadMQO(FileOpen.FileName)
    else if (FileExt = '.dat') OR (FileExt = '.mdl') then LoadRSM(FileOpen.FileName);


    end;
    If High(v) > 0 then FindMinMax;
    //    DoStuff;
 //   Animate := False;
 GetCenters;
  UpdateTitle;
  Cur_file_user := FileName;
end;

procedure TMain.c_cullfaceClick(Sender: TObject);
begin
  if c_cullface.Checked then
    glEnable(GL_CULL_FACE) else
    glDisable(GL_CULL_FACE);
end;

procedure TMain.Open1Click(Sender: TObject);
var
 FileExt: string;
  NameLen: Integer;
begin
  if FileOpen.Execute then
    begin
    FileName := FileOpen.FileName;
    FileExt := FileOpen.FileName;
    NameLen :=  Length(FileExt);
    Delete(FileExt,1,NameLen - 4);
//    MessageBox(0, PChar('fileExt'), PChar(FileExt), MB_OK);
    if (FileExt = '.mqo') then LoadMQO(FileOpen.FileName)
    else if (FileExt = '.dat') OR (FileExt = '.mdl') then LoadRSM(FileOpen.FileName) ;

    end;
  //  DoStuff;
//  Animate := False;
If High(v) > 0 then FindMinMax;
GetCenters;
  UpdateTitle;
end;

procedure TMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMain.OpenFolder1Click(Sender: TObject);
var Path: String;
begin
  Path := BrowseDialog('Select a folder', BIF_RETURNONLYFSDIRS);
  if Path <> '' then begin
    FileListBox.ApplyFilePath(Path);
    FileOpen.InitialDir := Path;
    Dir_user := FileOpen.InitialDir;
  end;
end;



procedure TMain.N3DS1Click(Sender: TObject);
begin
if GNumTriangles <= 0 then
  begin
  MessageBox(0, 'No File Loaded.', 'Error', 0);
   Exit;
 end;
MQOoutput;
end;

procedure TMain.debug1Click(Sender: TObject);
begin
//SaveRSM('debug.txt')
end;

procedure TMain.Button1Click(Sender: TObject);
var
ik1,k2 : Integer;

begin

If GNumTriangles > 0 then SaveRSM(FileName)
else MessageBox(0, PChar('No model data'), PChar('Error'), MB_OK);

//buuton1  make.dat
end;



procedure TMain.Button4Click(Sender: TObject);
var
ti,tk : Integer;
begin
//BUTTON4

end;


procedure TMain.C_BoxChange(Sender: TObject);
begin
//combobox
   SplitFlag := False;
   TP := 255;
   If C_Box.ItemIndex <> 0 then Animate := True
   else Animate := False;
   If C_Box.ItemIndex = 1 then begin Vskin := 153; Fskinval := 102; end; //blanks
   If C_Box.ItemIndex = 2 then begin Vskin := 1; Fskinval := 0; end; //head
   If C_Box.ItemIndex = 3 then begin Vskin := 8; Fskinval := 4; end; //Amulet
   If C_Box.ItemIndex = 4 then begin Vskin := 28; Fskinval := 16; TP:= 10; end; //left hand
   If C_Box.ItemIndex = 5 then begin Vskin := 50; Fskinval := 29; end; //right hand
   If C_Box.ItemIndex = 6 then begin Vskin := 27; Fskinval := 15; SplitFlag := True; TP:= 10; end; //gloves
   If C_Box.ItemIndex = 7 then begin Vskin := 45; Fskinval := 25; SplitFlag := True; end; //shoes

end;

procedure TMain.Help1Click(Sender: TObject);
begin
MessageBox(0, PChar('       Jagex' +#$0D+
'          Is'+#$0D+
'        GAY'), PChar('Help'), MB_OK);
end;

procedure TMain.About2Click(Sender: TObject);
begin

MessageBox(0, PChar('DatMaker V1.3 By Flappy Paps Software INC.'+#$0D+
'                     Original by Bentski'), PChar('About'), MB_OK);
end;

procedure TMain.TRIClick(Sender: TObject);
begin

If TRI.Checked then TriPri := True
else TriPri := False;
end;

procedure TMain.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  // #8 is Backspace
  if not (Key in [#13,#8, '0'..'9']) then begin
    Key := #0;
   // ShowMessage('Invalid key');
    // Discard the key
    Key := #0;
  end;


end;

procedure TMain.Edit1Exit(Sender: TObject);
begin
//get the value from the edit box and convert to number
UserPri := StrToInt(Edit1.text);
If UserPri < 0 then UserPri := 0;
If UserPri >254 Then UserPri := 254;
Edit1.text := IntToStr(UserPri);
Label4.Caption := IntToStr(UserPri);
end;

procedure TMain.Button2Click(Sender: TObject);
var ktmpname : String;
begin
//refresh path.
    ktmpname := FileListBox.FileName;
    FileListBox.Directory := '.';
    FileListBox.Directory := FileOpen.InitialDir; // reset
    Dir_user := FileOpen.InitialDir;
    FileListBox.FileName := ktmpname;
    Cur_file_user := ktmpname;
end;

procedure TMain.SaveColors1Click(Sender: TObject);
begin
setedgecolor := edgecolor;
set_t1 := t1;
set_t2 := t2;
set_t3 := t3;
set_t4 := t4;
set_t5 := t5;
set_bfill := bfill;

SaveSettings;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //
  setedgecolor := edgecolor;
set_t1 := t1;
set_t2 := t2;
set_t3 := t3;
set_t4 := t4;
set_t5 := t5;
set_bfill := bfill;

SaveSettings;
Delay(200);
end;

end.
