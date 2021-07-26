unit CastleViewportScreenBuffer;

interface

{$coperators on}
{$macro on}
{$define nl:=+ LineEnding +}

{$ifdef ANDROID}{$define GLES}{$endif}
{$ifdef iOS}{$define GLES}{$endif}

uses
  Classes, SysUtils,
  {$ifdef GLES}
  CastleGLES20,
  {$else}
  GL, GLExt,
  {$endif}
  CastleViewport, CastleVectors, CastleRenderingCamera, CastleImages, CastleGLImages,
  CastleComponentSerialize, CastleRectangles, CastleRenderContext, CastleGLShaders, CastleGLUtils;

type
  TCastleViewportScreenBuffer = class(TCastleViewport)
  strict private
    FImages: array[0..2] of TDrawableImage;
    FPreviousScreenTextureUnit: Integer;
  protected
    procedure RenderFromViewEverything(const RenderingCamera: TRenderingCamera); override;
    procedure ReconstructBuffer(const AIndex: Integer);
  public
    Flip: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CaptureCurrentScreen(const ATextureUnit: Integer);
  published
    property PreviousScreenTextureUnit: Integer read FPreviousScreenTextureUnit write FPreviousScreenTextureUnit default 15;
  end;

var
  CurrentViewportScreenBuffer: TCastleViewportScreenBuffer;

implementation

procedure TCastleViewportScreenBuffer.RenderFromViewEverything(const RenderingCamera: TRenderingCamera);
begin
  CurrentViewportScreenBuffer := Self;
  Self.Flip := Self.Flip mod 2;
  Self.ReconstructBuffer(Self.Flip);
  // Bind previous color buffer to FPreviousScreenTextureUnit
  glActiveTexture(GL_TEXTURE0 + Self.FPreviousScreenTextureUnit);
  glBindTexture(GL_TEXTURE_2D, Self.FImages[Self.Flip mod 2].Texture);
  //
  Self.FImages[Self.Flip].RenderToImageBegin;
  inherited;
  Self.FImages[Self.Flip].RenderToImageEnd;
  // Final result
  Self.FImages[Self.Flip].Draw(0, 0);
  CurrentViewportScreenBuffer := nil;
end;

constructor TCastleViewportScreenBuffer.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  for I := 0 to 2 do
    Self.FImages[I] := nil;
  Self.Flip := 0;
  Self.FPreviousScreenTextureUnit := 15;
end;

destructor TCastleViewportScreenBuffer.Destroy;
var
  I: Integer;
begin
  for I := 0 to 2 do
    FreeAndNil(Self.FImages[I]);
  inherited;
end;

procedure TCastleViewportScreenBuffer.CaptureCurrentScreen(const ATextureUnit: Integer);
begin
  Self.ReconstructBuffer(2);
  // Switch to capture buffer
  Self.FImages[Self.Flip].RenderToImageEnd;
  Self.FImages[2].RenderToImageBegin;
  Self.FImages[Self.Flip].Draw(0, 0);
  // Bind captured color buffer to ATextureUnit
  glActiveTexture(GL_TEXTURE0 + ATextureUnit);
  glBindTexture(GL_TEXTURE_2D, Self.FImages[2].Texture);
  // Switch back to render buffer
  Self.FImages[2].RenderToImageEnd;
  Self.FImages[Self.Flip].RenderToImageBegin;
end;

procedure TCastleViewportScreenBuffer.ReconstructBuffer(const AIndex: Integer);
var
  SR: TRectangle;
begin
  SR := Self.RenderRect.Round;
  // Reconstruct the buffers when width/height change
  if (Self.FImages[AIndex] = nil) or (SR.Width <> Self.FImages[AIndex].Width) or (SR.Height <> Self.FImages[AIndex].Height) then
  begin
    if Self.FImages[AIndex] <> nil then
    begin
      FreeAndNil(Self.FImages[AIndex]);
    end;
    Self.FImages[AIndex] := TDrawableImage.Create(TRGBImage.Create(SR.Width, SR.Height), True, True);
    Self.FImages[AIndex].RepeatS := True;
    Self.FImages[AIndex].RepeatT := True;
  end;
end;

initialization
  RegisterSerializableComponent(TCastleViewportScreenBuffer, 'Viewport (With Screen Buffer)');

end.
