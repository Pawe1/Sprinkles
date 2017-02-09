unit Sprinkles.Android.Intents.Common;

interface

type
  TMapZoomLevel = 1..23;

  TLocation = class abstract
  public
    class procedure ShowOnMap(const AURI: string); overload;
    class procedure ShowOnMap(const ALatitude, ALongitude: Double); overload;
    class procedure ShowOnMap(const ALatitude, ALongitude: Double; const AZoom: TMapZoomLevel); overload;
    class procedure ShowOnMap(const ALatitude, ALongitude: Double; const ALabel: string); overload;
  end;

implementation

uses
  FMX.Platform.Android,   // MainActivity
  Androidapi.Helpers,   // StringToJString
  Androidapi.JNI.GraphicsContentViewText,   // JIntent & co.
  Androidapi.JNI.Net,   // Jnet_Uri & co.

  System.SysUtils,
  Sprinkles.Android.Intents;

{ TLocation }

class procedure TLocation.ShowOnMap(const AURI: string);
var
  Intent: JIntent;
  Data: Jnet_Uri;
begin
  Data := TJnet_Uri.JavaClass.parse(StringToJString(AURI));

  Intent := TJIntent.Create;
  with Intent do
  begin
    setAction(TJIntent.JavaClass.ACTION_VIEW);
    setData(Data);
  end;

  CheckIntentReceiversExist(Intent);
  MainActivity.startActivity(Intent)
end;

class procedure TLocation.ShowOnMap(const ALatitude, ALongitude: Double);
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DecimalSeparator := '.';
  ShowOnMap(Format('geo:%g,%g', [ALatitude, ALongitude], FormatSettings));
end;

class procedure TLocation.ShowOnMap(const ALatitude, ALongitude: Double; const AZoom: TMapZoomLevel);
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DecimalSeparator := '.';
  ShowOnMap(Format('geo:%g,%g?z=%d', [ALatitude, ALongitude, AZoom], FormatSettings));
end;

class procedure TLocation.ShowOnMap(const ALatitude, ALongitude: Double; const ALabel: string);
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DecimalSeparator := '.';
  ShowOnMap(Format('geo:0,0?q=%g,%g(%s)', [ALatitude, ALongitude, ALabel], FormatSettings));
end;

end.
