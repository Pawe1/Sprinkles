unit Sprinkles.Collections;  { TODO -opc -cdev : generics? }

{$INCLUDE Sprinkles.inc}

interface

uses
  System.Classes,
  System.Generics.Collections,   // TObjectList
  System.Generics.Defaults,   // IComparer
  Sprinkles.Lifetime;   // TDestructionDetector

type

  // improved hybrid of System.Generics.Collections.TObjectList and System.Contnrs.TComponentList
  // (generic, with dangling reference protection and proper suport for item duplicates)
  TComponentList<T: TComponent> = class(TObjectList<T>)
  private
    FDuplicates: TDuplicates;
    FDestructionDetector: TDestructionDetector;
  protected
    procedure HandleItemDestruction(ASender: TObject; AComponent: TComponent);   // unlike System.Contnrs.TComponentList it handles all item occurrences
    procedure Notify(const Value: T; Action: TCollectionNotification); override;
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean = True); overload;
    constructor Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean = True); overload;
    destructor Destroy; override;
    function Add(const Value: T): Integer;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
  end;

implementation

uses
  System.RTLConsts;   // SDuplicateItem

{$REGION 'TComponentList'}

function TComponentList<T>.Add(const Value: T): Integer;
begin
  if (Duplicates = TDuplicates.dupAccept) or (IndexOf(Value) = -1) then
    inherited Add(Value)
  else if Duplicates = TDuplicates.dupError then
    raise EListError.CreateFmt(SDuplicateItem, [ItemValue(Value)]);
end;

constructor TComponentList<T>.Create(AOwnsObjects: Boolean);
begin
  inherited;
  FDuplicates := TDuplicates.dupIgnore;
end;

constructor TComponentList<T>.Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean);
begin
  inherited;
  FDuplicates := TDuplicates.dupIgnore;
end;

constructor TComponentList<T>.Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean);
begin
  inherited;
  FDuplicates := TDuplicates.dupIgnore;
end;

destructor TComponentList<T>.Destroy;
begin
  inherited;
  FDestructionDetector.Free;   // order like in System.Generics.Collections.TObjectList
end;

procedure TComponentList<T>.HandleItemDestruction(ASender: TObject; AComponent: TComponent);
var
  Index: Integer;
begin
  Index := IndexOfItem(AComponent, TDirection.FromBeginning);
  while Index <> -1 do
  begin
    Delete(Index);
    Index := IndexOfItem(AComponent, TDirection.FromBeginning);
  end;
end;

procedure TComponentList<T>.Notify(const Value: T; Action: TCollectionNotification);
begin
  if not OwnsObjects then   // because in case of multiple list item occurrence it would work improper as System.Contnrs.TComponentList
  begin
    if not Assigned(FDestructionDetector) then
    begin
      FDestructionDetector := TDestructionDetector.Create(nil);
      FDestructionDetector.OnDestructingDetected := HandleItemDestruction;
    end;

    if Assigned(Value) then
      case Action of
        TCollectionNotification.cnAdded: FDestructionDetector.StartObserving(Value);
        TCollectionNotification.cnExtracted, TCollectionNotification.cnRemoved:
          if IndexOf(Value) = -1 then   // after removing all of the occurrences
            FDestructionDetector.StopObserving(Value);
      end;
  end;
  inherited;
end;

{$ENDREGION}

end.
