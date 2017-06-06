unit Sprinkles.VCL.ModalBackdrop;

interface

uses
  System.Contnrs,
  Vcl.Graphics;

type

  // based on code posted on Stack Overflow by Ryan J. Mills
  TModalBackdrop = class
  private
    const
      Color = clBlack;
      Transparency: Byte = 127;
    class var
      FOverlays: TComponentList;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure OverlayForms;
    class procedure OverlayDesktop;
    class procedure Hide;
  end;

implementation

uses
  System.Classes, System.SysUtils,
  Winapi.Windows,
  Vcl.Forms;

class constructor TModalBackdrop.Create;
begin
  FOverlays := nil;
end;

class destructor TModalBackdrop.Destroy;
begin
  Hide;
  inherited;
end;

class procedure TModalBackdrop.Hide;
begin
  FreeAndNil(FOverlays);
end;

class procedure TModalBackdrop.OverlayDesktop;
var
  LC: Integer;
  Overlay: TForm;
begin
  if Assigned(FOverlays) then
    Exit;

  FOverlays := TComponentList.Create(True);

  for LC := 0 to Screen.MonitorCount - 1 do
  begin
    Overlay := TForm.Create(nil);
    FOverlays.Add(Overlay);

    Overlay.DoubleBuffered := True;   // experimental

    // do something with popupmode?

    Overlay.Position := poDesigned;
    Overlay.AlphaBlend := True;
    Overlay.AlphaBlendValue := Transparency;
    Overlay.Color := Color;
    Overlay.BorderStyle := bsNone;
    Overlay.Enabled := False;
    Overlay.BoundsRect := Screen.Monitors[LC].BoundsRect;
    SetWindowPos(Overlay.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    Overlay.Visible := True;
  end;
end;

class procedure TModalBackdrop.OverlayForms;
var
  LC: Integer;
  Form: TForm;
  Overlay: TForm;
  Forms: TComponentList;
begin
  if Assigned(FOverlays) then
    Exit;

  FOverlays := TComponentList.Create(True);

  Forms := TComponentList.Create(False);
  try
    for LC := 0 to Screen.FormCount - 1 do
      Forms.Add(Screen.Forms[LC]);
   
    for LC := 0 to Forms.Count - 1 do
    begin
      Form := Forms[LC] as TForm;

      if Form.Visible then   { TODO -opc -cdev : Problem when for example window is minimized and user click "Close" from taskbar context menu }
      begin
        Overlay := TForm.Create(Form);
        FOverlays.Add(Overlay);

        Overlay.DoubleBuffered := True;   // experimental

        // do something with popupmode?

        Overlay.Position := poOwnerFormCenter;
        Overlay.AlphaBlend := True;
        Overlay.AlphaBlendValue := Transparency;
        Overlay.Color := Color;
        Overlay.BorderStyle := bsNone;
        Overlay.Enabled := False;
        Overlay.BoundsRect := Form.BoundsRect;
        SetWindowLong(Overlay.Handle, GWL_HWNDPARENT, Form.Handle);
        SetWindowPos(Overlay.Handle, Form.handle, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
        Overlay.Visible := True;
      end;
    end;
  finally
    Forms.Free;
  end;
end;

end.
