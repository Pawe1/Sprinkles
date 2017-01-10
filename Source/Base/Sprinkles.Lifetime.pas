unit Sprinkles.Lifetime;

{$I Sprinkles.inc}

interface

uses
  System.Classes;

type
  TFreeNotifyEvent = procedure(ASender: TObject; AComponent: TComponent) of object;   { TODO -opc -cdev : const ? }

  // Based on System.Contnrs.TComponentListNexus (and similar to dxCoreClasses.TcxFreeNotificator)
  // This class is dedicated to receive/implement free notifications in classes that are not TComponent descendants
  TFreeNotifier = class(TComponent)
  private
    FOnFreeNotify: TFreeNotifyEvent;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure StartObserving(const AComponent: TComponent);
    procedure StopObserving(const AComponent: TComponent);
    property OnFreeNotify: TFreeNotifyEvent read FOnFreeNotify write FOnFreeNotify;
  end;

implementation

{$REGION 'TFreeNotifier'}

procedure TFreeNotifier.StartObserving(const AComponent: TComponent);
begin
  if Assigned(AComponent) then
    AComponent.FreeNotification(Self);
end;

procedure TFreeNotifier.StopObserving(const AComponent: TComponent);
begin
  if Assigned(AComponent) then
    AComponent.RemoveFreeNotification(Self);
end;

procedure TFreeNotifier.Notification(AComponent: TComponent; Operation: TOperation);
begin
  // in DevExpress implementation "inherited" is called here
  if (Operation = TOperation.opRemove) and Assigned(FOnFreeNotify) then
    FOnFreeNotify(Self, AComponent);
  inherited;
end;

{$ENDREGION}

end.
