unit Sprinkles.Tests.InterfacedDataModule;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TInterfacedDataModuleTester = class(TObject)
  public
    [Test]
    procedure SecurityTest;
  end;

implementation

uses
  System.Classes,
  Sprinkles.InterfacedDataModule;

procedure TInterfacedDataModuleTester.SecurityTest;
var
  Owner: TComponent;
  ObjectReference: TInterfacedDataModule;
  CountedInterfaceReference: IInterface;
begin
  Owner := TComponent.Create(nil);
  try
    ObjectReference := TInterfacedDataModule.CreateNew(Owner);   // without persistent data stored in form (dfm file)
    CountedInterfaceReference := ObjectReference;
    Assert.WillRaise(
        procedure
        begin
          ObjectReference.Free;
        end
      );
    CountedInterfaceReference := nil;   // clean up - cause destruction
    ObjectReference := nil;
  finally
    Owner.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TInterfacedDataModuleTester);

end.
