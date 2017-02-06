unit Sprinkles.Utils.Shuffling;

interface

uses
  System.Generics.Collections;

type
  TArrayShuffler<T> = class
  public
    class procedure FisherYatesShuffle(var AItems: array of T);
  end;

implementation

class procedure TArrayShuffler<T>.FisherYatesShuffle(var AItems: array of T);
var
  LC, RandomIndex: Integer;
  SwappedElement: T;
begin
  for LC := High(AItems) downto 1 do
  begin
    RandomIndex := Random(LC + 1);

    SwappedElement := AItems[LC];
    AItems[LC] := AItems[RandomIndex];
    AItems[RandomIndex] := SwappedElement;
  end;
end;

end.
