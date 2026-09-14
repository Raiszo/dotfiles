{ buildGoModule }:

buildGoModule {
  pname = "generate-json-schemas";
  version = "1.0.0";
  src = ../scripts-go;
  vendorHash = "sha256-Nl7vnwzofiZ/Xx1favUvNmVM3l/gje/aIg0tAMnv1Zo=";
  subPackages = [ "cmd/generate-json-schemas" ];

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';
}
