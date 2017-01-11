unit Sprinkles.IO;

{$INCLUDE Sprinkles.inc}

interface

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

procedure CheckDirectoryExists(const APath: string; AFollowLink: Boolean = True);

implementation

uses
  System.SysUtils,
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

procedure CheckDirectoryExists(const APath: string; AFollowLink: Boolean = True);
begin
  if not TDirectory.Exists(APath, AFollowLink) then
    raise EDirectoryNotFoundException.CreateFmt(SDirectoryNotFoundException, [APath]);
end;

end.
