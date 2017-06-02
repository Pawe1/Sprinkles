unit Sprinkles.Lifetime;

{$I Sprinkles.inc}

interface

uses
  System.Classes;

type
  TDestructionNotifyEvent = procedure(ASender: TObject; AComponent: TComponent) of object;   { TODO -opc -cdev : const ? }

  // Based on System.Contnrs.TComponentListNexus (and similar to dxCoreClasses.TcxFreeNotificator)
  // This class is dedicated to receive/implement component destroy notifications inside types that are not TComponent descendants
  TDestructionDetector = class(TComponent)
  private
    FOnDestructingDetected: TDestructionNotifyEvent;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    property OnDestructingDetected: TDestructionNotifyEvent read FOnDestructingDetected write FOnDestructingDetected;
  end;

  TDestructionDetectorHelper = class helper for TDestructionDetector
    procedure StartObserving(const AComponent: TComponent);
    procedure StopObserving(const AComponent: TComponent);
  end;

implementation

{$REGION 'TDestructionDetector'}

procedure TDestructionDetector.Notification(AComponent: TComponent; Operation: TOperation);
begin
  // in DevExpress implementation "inherited" is called here
  if (Operation = TOperation.opRemove) and Assigned(FOnDestructingDetected) then
    FOnDestructingDetected(Self, AComponent);
  inherited;
end;

{$ENDREGION}

{$REGION 'TDestructionDetectorHelper'}

procedure TDestructionDetectorHelper.StartObserving(const AComponent: TComponent);
begin
  if Assigned(AComponent) then
    AComponent.FreeNotification(Self);
end;

procedure TDestructionDetectorHelper.StopObserving(const AComponent: TComponent);
begin
  if Assigned(AComponent) then
    AComponent.RemoveFreeNotification(Self);
end;

{$ENDREGION}

end.
