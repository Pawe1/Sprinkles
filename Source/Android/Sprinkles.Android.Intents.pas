unit Sprinkles.Android.Intents;

interface

uses
  System.SysUtils,
  FMX.Platform.Android,   // MainActivity
  Androidapi.JNI.GraphicsContentViewText,   // JIntent & co.

  Sprinkles.Android;

type
  EIntentReceiverNotFound = class(EAndroidException);

procedure CheckIntentReceiversExist(const AIntent: JIntent);

implementation

resourcestring
  MsgIntentReceiverNotFound = 'Intent receiver not found';

procedure CheckIntentReceiversExist(const AIntent: JIntent);
begin
  if MainActivity.getPackageManager.queryIntentActivities(AIntent, TJPackageManager.JavaClass.MATCH_DEFAULT_ONLY).size < 1 then
    raise EIntentReceiverNotFound.Create(MsgIntentReceiverNotFound);
end;

end.
