unit Sprinkles.Tests.InterfacedComponent;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TInterfacedComponentTester = class(TObject)
  public
    [Test]
    procedure SecurityTest;
  end;

implementation

uses
  System.Classes,
  Sprinkles.InterfacedComponent;

procedure TInterfacedComponentTester.SecurityTest;
var
  Owner: TComponent;
  ObjectReference: TInterfacedComponent;
  CountedInterfaceReference: IInterface;
begin
  Owner := TComponent.Create(nil);
  try
    ObjectReference := TInterfacedComponent.Create(Owner);
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
  TDUnitX.RegisterTestFixture(TInterfacedComponentTester);

end.
