unit Sprinkles.InterfacedDataModule;

{$I Sprinkles.inc}

interface

uses
  System.Classes;

type

  // Same as TDataModule but with enabled reference counted interfaces
  // based on System.TInterfacedObject & article of Jeroen Wiert Pluimers
  // http://wiert.me/2009/08/10/delphi-using-fastmm4-part-2-tdatamodule-descendants-exposing-interfaces-or-the-introduction-of-a-tinterfaceddatamodule/
  TInterfacedDataModule = class(TDataModule, IInterface)
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
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
{$IFNDEF AUTOREFCOUNT}
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read GetRefCount;
{$ENDIF}
  end;

implementation

resourcestring
  STryingToDestroyOwnedInstanceWithReferences = 'Trying to destroy an owned instance of class %s named "%s" that still has %d interface reference(s) left';

{$IFNDEF AUTOREFCOUNT}
function TInterfacedDataModule.GetRefCount: Integer;
begin
  Result := FRefCount and not objDestroyingFlag;
end;

class procedure TInterfacedDataModule.__MarkDestroying(const Obj);
var
  LRef: Integer;
begin
  repeat
    LRef := TInterfacedDataModule(Obj).FRefCount;
  until AtomicCmpExchange(TInterfacedDataModule(Obj).FRefCount, LRef or objDestroyingFlag, LRef) = LRef;
end;

procedure TInterfacedDataModule.AfterConstruction;
begin
  inherited;
  FOwnerIsComponent := Assigned(Owner) and (Owner is TComponent);
// Release the constructor's implicit refcount
  AtomicDecrement(FRefCount);
end;

procedure TInterfacedDataModule.BeforeDestruction;
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
class function TInterfacedDataModule.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TInterfacedDataModule(Result).FRefCount := 1;
end;
{$ENDIF AUTOREFCOUNT}

function TInterfacedDataModule._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TInterfacedDataModule._Release: Integer;
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
