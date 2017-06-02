unit Sprinkles.InterfacedComponent;

interface

uses
  System.Classes;

type
  TInterfacedComponent = class(TComponent)
{$IFNDEF AUTOREFCOUNT}
  private
    FOwnerIsComponent: Boolean;
    const
      objDestroyingFlag = Integer($80000000);
    function GetRefCount: Integer; inline;
{$ENDIF}
  protected
{$IFNDEF AUTOREFCOUNT}
    [Volatile] FRefCount: Integer;
    class procedure __MarkDestroying(const Obj); static; inline;
{$ENDIF}
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    procedure AfterConstruction; override;
{$IFNDEF AUTOREFCOUNT}
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read GetRefCount;
{$ENDIF}
  end;

implementation

resourcestring
  STryingToDestroyOwnedInstanceWithReferences = 'Trying to destroy an owned instance of class %s named "%s" that still has %d interface reference(s) left';

{$IFNDEF AUTOREFCOUNT}
function TInterfacedComponent.GetRefCount: Integer;
begin
  Result := FRefCount and not objDestroyingFlag;
end;

class procedure TInterfacedComponent.__MarkDestroying(const Obj);
var
  LRef: Integer;
begin
  repeat
    LRef := TInterfacedComponent(Obj).FRefCount;
  until AtomicCmpExchange(TInterfacedComponent(Obj).FRefCount, LRef or objDestroyingFlag, LRef) = LRef;
end;

procedure TInterfacedComponent.AfterConstruction;
begin
  inherited;
  FOwnerIsComponent := Assigned(Owner) and (Owner is TComponent);
{$IFNDEF AUTOREFCOUNT}
// Release the constructor's implicit refcount
  AtomicDecrement(FRefCount);
{$ENDIF}
end;

procedure TInterfacedComponent.BeforeDestruction;
begin
  if RefCount <> 0 then
  begin
    if not FOwnerIsComponent then
      System.Error(reInvalidPtr)
    else
      raise EInvalidOperation.CreateFmt(STryingToDestroyOwnedInstanceWithReferences, [ClassName, Name, RefCount]);
  end;
  inherited;
end;

// Set an implicit refcount so that refcounting during construction won't destroy the object.
class function TInterfacedComponent.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TInterfacedComponent(Result).FRefCount := 1;
end;
{$ENDIF AUTOREFCOUNT}

function TInterfacedComponent.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TInterfacedComponent._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TInterfacedComponent._Release: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
  begin
    // Mark the refcount field so that any refcounting during destruction doesn't infinitely recurse.
    __MarkDestroying(Self);
    Destroy;
  end;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

end.
