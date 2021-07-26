unit CastleSceneScreenBuffer;

{$coperators on}
{$macro on}
{$define nl:=+ LineEnding +}

{$ifdef ANDROID}{$define GLES}{$endif}
{$ifdef iOS}{$define GLES}{$endif}

interface

uses
  Classes, SysUtils,
  CastleScene, CastleComponentSerialize, CastleTransform;

type
  TCastleSceneScreenBuffer = class(TCastleScene)
  strict private
    FScreenTextureUnit: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LocalRender(const Params: TRenderParams); override;
  published
    property ScreenTextureUnit: Integer read FScreenTextureUnit write FScreenTextureUnit default 7;
  end;

implementation

uses
  CastleViewportScreenBuffer;

constructor TCastleSceneScreenBuffer.Create(AOwner: TComponent);
begin
  inherited;
  Self.FScreenTextureUnit := 7;
end;

procedure TCastleSceneScreenBuffer.LocalRender(const Params: TRenderParams);
begin
  if CurrentViewportScreenBuffer <> nil then
  begin
    CurrentViewportScreenBuffer.CaptureCurrentScreen(Self.FScreenTextureUnit);
  end;
  inherited;
end;

initialization
  RegisterSerializableComponent(TCastleSceneScreenBuffer, 'Scene (With Screen Buffer)');

end.
