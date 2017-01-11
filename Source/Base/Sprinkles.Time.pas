unit Sprinkles.Time;

{$INCLUDE Sprinkles.inc}

interface

function QuarterOf(const AValue: TDateTime): Word;

function StartOfTheQuarter(const AValue: TDateTime): TDateTime;
function EndOfTheQuarter(const AValue: TDateTime): TDateTime;
function StartOfAQuarter(const AYear, AQuarter: Word): TDateTime;
function EndOfAQuarter(const AYear, AQuarter: Word): TDateTime;

implementation

uses
  System.SysUtils,   // DecodeDate, EncodeDate, ...
  System.DateUtils;   // EndOfTheMonth & co.

{$REGION 'Time calculations connected with quarters'}

function QuarterOf(const AValue: TDateTime): Word;
var
  LYear, LMonth, LDay: Word;
begin
  DecodeDate(AValue, LYear, LMonth, LDay);
  Result := ((LMonth - 1) div 3) + 1;
end;

function StartOfTheQuarter(const AValue: TDateTime): TDateTime;
var
  LYear, LMonth, LDay: Word;
begin
  DecodeDate(AValue, LYear, LMonth, LDay);
  Result := EncodeDate(LYear, ((LMonth - 1) div 3) * 3 + 1, 1);
end;

function EndOfTheQuarter(const AValue: TDateTime): TDateTime;
var
  LYear, LMonth, LDay: Word;
begin
  DecodeDate(AValue, LYear, LMonth, LDay);
  Result := EndOfAMonth(LYear, ((LMonth - 1) div 3) * 3 + 3);
end;

function StartOfAQuarter(const AYear, AQuarter: Word): TDateTime;
begin
  Result := EncodeDate(AYear, AQuarter * 3 - 2, 1);
end;

function EndOfAQuarter(const AYear, AQuarter: Word): TDateTime;
begin
  Result := EndOfAMonth(AYear, AQuarter * 3);
end;

{$ENDREGION}

end.
