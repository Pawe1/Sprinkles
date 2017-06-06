unit Sprinkles.IO;

{$INCLUDE Sprinkles.inc}

interface

uses
  System.Classes,
  System.SysUtils,   // EDirectoryNotFoundException, TEncoding, ... 
  System.RegularExpressions;   // TRegEx

type
  TFileSystemFamily = (Unix, Windows);

  // Overlay for universal path combination (with support for non-native file system)
  TPathBuilder = record
  private
    const
      DirectorySeparatorChars: array [TFileSystemFamily] of Char = ('/', '\');
  private
    FFileSystemFamily: TFileSystemFamily;
    function IsNativeDirectorySeparatorUsed: Boolean; inline;
    function IsCombinedPathIncorrect(const APath1, APath2, ACombinedPath: string): Boolean; inline;
  public
    constructor Create(const AFileSystemFamily: TFileSystemFamily);
    property FileSystemFamily: TFileSystemFamily read FFileSystemFamily;
    function Combine(const APath1, APath2: string): string; inline;
  end;

  TRegExTextSearcher = class abstract
  private
    FLine: string;
    FPattern: string;
    FReader: TTextReader;
    FRegEx: TRegEx;
    function IsMatch(const ALine: string): Boolean;
  public
    function FindFirstLine: Boolean; virtual;
    function FindNextLine: Boolean; virtual; abstract;
    function ReadLine: string;
    property Pattern: string write FPattern;
  end;

  TRegExStreamSearcher = class(TRegExTextSearcher)
  private
  public
    constructor Create(Stream: TStream); overload;
    constructor Create(Stream: TStream; DetectBOM: Boolean); overload;
    constructor Create(Stream: TStream; Encoding: TEncoding; DetectBOM: Boolean = False; BufferSize: Integer = 4096); overload;
    constructor Create(const Filename: string); overload;
    constructor Create(const Filename: string; DetectBOM: Boolean); overload;
    constructor Create(const Filename: string; Encoding: TEncoding; DetectBOM: Boolean = False; BufferSize: Integer = 4096); overload;
    destructor Destroy; override;
    function FindFirstLine: Boolean; override;
    function FindNextLine: Boolean; override;
  end;

procedure CheckDirectoryExists(const APath: string; AFollowLink: Boolean = True);

implementation

uses
  System.RTLConsts,   // SPathNotFound
  System.IOUtils;

resourcestring
  SDirectoryNotFoundException = 'Directory not found: %s';

{$REGION 'TPathBuilder'}

function TPathBuilder.Combine(const APath1, APath2: string): string;
begin
  Result := TPath.Combine(APath1, APath2);   // Result is always correct only if paths use same standard as local file system
  if IsCombinedPathIncorrect(APath1, APath2, Result) then
    Result := APath1 + DirectorySeparatorChars[FFileSystemFamily] + APath2;
end;

constructor TPathBuilder.Create(const AFileSystemFamily: TFileSystemFamily);
begin
  FFileSystemFamily := AFileSystemFamily;
end;

function TPathBuilder.IsNativeDirectorySeparatorUsed: Boolean;
begin
  Result := TPath.DirectorySeparatorChar = DirectorySeparatorChars[FFileSystemFamily];
end;

function TPathBuilder.IsCombinedPathIncorrect(const APath1, APath2, ACombinedPath: string): Boolean;
begin
  Result := (not IsNativeDirectorySeparatorUsed) and (ACombinedPath = APath1 + TPath.DirectorySeparatorChar + APath2);
end;

{$ENDREGION}

constructor TRegExStreamSearcher.Create(Stream: TStream; Encoding: TEncoding; DetectBOM: Boolean; BufferSize: Integer);
begin
  FReader := TStreamReader.Create(Stream, Encoding, DetectBOM, BufferSize);
end;

constructor TRegExStreamSearcher.Create(Stream: TStream; DetectBOM: Boolean);
begin
  FReader := TStreamReader.Create(Stream, DetectBOM);
end;

constructor TRegExStreamSearcher.Create(Stream: TStream);
begin
  FReader := TStreamReader.Create(Stream);
end;

constructor TRegExStreamSearcher.Create(const Filename: string; Encoding: TEncoding; DetectBOM: Boolean; BufferSize: Integer);
begin
  FReader := TStreamReader.Create(Filename, Encoding, DetectBOM, BufferSize);
end;

constructor TRegExStreamSearcher.Create(const Filename: string; DetectBOM: Boolean);
begin
  FReader := TStreamReader.Create(Filename, DetectBOM);
end;

constructor TRegExStreamSearcher.Create(const Filename: string);
begin
  FReader := TStreamReader.Create(Filename);
end;

destructor TRegExStreamSearcher.Destroy;
begin
  FReader.Free;
  inherited;
end;

function TRegExStreamSearcher.FindFirstLine: Boolean;
begin
  inherited;
  (FReader as TStreamReader).BaseStream.Position := 0;
  Result := FindNextLine;
end;

function TRegExStreamSearcher.FindNextLine: Boolean;
var
  Line: string;
begin
  Result := False;
  while not (FReader as TStreamReader).EndOfStream do
  begin
    Line := FReader.ReadLine;
    if IsMatch(Line) then
    begin
      FLine := Line;
      Result := True;
      Break;
    end;
  end;
end;

function TRegExTextSearcher.FindFirstLine: Boolean;
begin
  FRegEx := TRegEx.Create(FPattern);
end;

function TRegExTextSearcher.IsMatch(const ALine: string): Boolean;
begin
  Result := FRegEx.IsMatch(ALine);
end;

function TRegExTextSearcher.ReadLine: string;
begin
  Result := FLine;
end;

procedure CheckDirectoryExists(const APath: string; AFollowLink: Boolean = True);
begin
  if not TDirectory.Exists(APath, AFollowLink) then
    raise EDirectoryNotFoundException.CreateFmt(SDirectoryNotFoundException, [APath]);
end;

end.
