unit Sprinkles;

{$INCLUDE Sprinkles.inc}

interface

uses
  System.SysUtils;   // TStringHelper, ...

type
  TGUIDFormat = (
    N,   // 32 digits: 00000000000000000000000000000000
    D,   // 32 digits separated by hyphens: 00000000-0000-0000-0000-000000000000 / canonical form (RFC4122)
    B,   // 32 digits separated by hyphens, enclosed in braces: {00000000-0000-0000-0000-000000000000}
    P    // 32 digits separated by hyphens, enclosed in parentheses: (00000000-0000-0000-0000-000000000000)
    //X [not supported yet]     // Four hexadecimal values enclosed in braces, where the fourth value is a subset of eight hexadecimal values that is also enclosed in braces: {0x00000000,0x0000,0x0000,{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}}
  );

  TGUIDConverter = record
  private
    class function AddBraces(const S: string): string; static; inline;
    class function AddParentheses(const S: string): string; static; inline;
    class function RemoveBrackets(const S: string): string; static; inline;
    class function DigitsToCanonicalForm(const S: string): string; static; inline;
  public
    class function Parse(const S: string): TGUID; static;
    class function TryParse(const S: string; out Value: TGUID): Boolean; inline; static;
    class function ToString(const Value: TGUID): string; overload; inline; static;
    class function ToString(const Value: TGUID; const AFormat: TGUIDFormat): string; overload; inline; static;
  end;

  TGUIDValidator = record
  private
    const
      RegExGUIDFormatN = '(?i)' +
        '\A' +
        '([0-9A-F]{32})' +
        '\Z';
      RegExGUIDFormatD = '(?i)' +
        '\A' +
        '([0-9A-F]{8}(?:-[0-9A-F]{4}){3}-[0-9A-F]{12})' +
        '\Z';
      RegExGUIDFormatB = '(?i)' +
        '\A' +
        '(?:{)' +
        '([0-9A-F]{8}(?:-[0-9A-F]{4}){3}-[0-9A-F]{12})' +
        '(?:})' +
        '\Z';
      RegExGUIDFormatP = '(?i)' +
        '\A' +
        '(?:\()' +
        '([0-9A-F]{8}(?:-[0-9A-F]{4}){3}-[0-9A-F]{12})' +
        '(?:\))' +
        '\Z';
  public
    class function IsValidGUID(const S: string): Boolean; static;
  end;

implementation

uses
  System.RegularExpressions;

resourcestring
  MsgInvalidGUID = '"%s" is not a valid GUID value';

{$REGION 'TGUIDConverter'}

class function TGUIDConverter.AddBraces(const S: string): string;
begin
  Assert(S.Length = 36);
  Result := '{' + S + '}';
end;

class function TGUIDConverter.AddParentheses(const S: string): string;
begin
  Assert(S.Length = 36);
  Result := '(' + S + ')';
end;

class function TGUIDConverter.DigitsToCanonicalForm(const S: string): string;
begin
  Assert(S.Length = 32);
  Result := S.Insert(20, '-');
  Result := Result.Insert(16, '-');
  Result := Result.Insert(12, '-');
  Result := Result.Insert(8, '-');
end;

class function TGUIDConverter.Parse(const S: string): TGUID;
var
  CanonicalForm: string;
begin
  try
    case S.Length of
      32:
        begin
          CanonicalForm := DigitsToCanonicalForm(S);
          Result := TGUID.Create(AddBraces(CanonicalForm));
        end;

      36: Result := TGUID.Create(AddBraces(S));

      38:
        if (S.Chars[0] = '{') and (S.Chars[37] = '}') then
          Result := TGUID.Create(S)
        else if (S.Chars[0] = '(') and (S.Chars[37] = ')') then
          Result := TGUID.Create(AddBraces(RemoveBrackets(S)))
        else
          Abort;
    else
      Abort;
    end;
  except
    raise EArgumentException.CreateFmt(MsgInvalidGUID, [S]);
  end;
end;

class function TGUIDConverter.RemoveBrackets(const S: string): string;
begin
  Assert(S.Length = 38);
  Result := S.Substring(1, 36);
end;

class function TGUIDConverter.ToString(const Value: TGUID; const AFormat: TGUIDFormat): string;
var
  CanonicalForm: string;
begin
  case AFormat of
    TGUIDFormat.N:
      begin
        CanonicalForm := RemoveBrackets(Value.ToString);
        Result := StringReplace(CanonicalForm, '-', '', [rfReplaceAll]);
      end;
    TGUIDFormat.D: Result := RemoveBrackets(Value.ToString);
    TGUIDFormat.B: Result := Value.ToString;
    TGUIDFormat.P:
      begin
        CanonicalForm := RemoveBrackets(Value.ToString);
        Result := AddParentheses(CanonicalForm);
      end;
  end;
end;

class function TGUIDConverter.ToString(const Value: TGUID): string;
begin
  Result := ToString(Value, TGUIDFormat.D);
end;

class function TGUIDConverter.TryParse(const S: string; out Value: TGUID): Boolean;
begin
  try
    Result := True;
    Value := Parse(S);
  except
    Result := False;
  end;
end;

{$ENDREGION}

class function TGUIDValidator.IsValidGUID(const S: string): Boolean;
begin
  Result := False;
  case S.Length of
    32: Result := TRegEx.IsMatch(S, RegExGUIDFormatN);
    36: Result := TRegEx.IsMatch(S, RegExGUIDFormatD);
    38:
      case S.Chars[0] of
        '{': Result := TRegEx.IsMatch(S, RegExGUIDFormatB);
        '(': Result := TRegEx.IsMatch(S, RegExGUIDFormatP);
      end;
  end;
end;

end.
