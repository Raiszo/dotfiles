{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cpackget";
  version = "2.2.1";

  # Upstream's Linux executable is statically linked.
  src = fetchurl {
    url = "https://github.com/Open-CMSIS-Pack/cpackget/releases/download/v${finalAttrs.version}/cpackget_${finalAttrs.version}_linux_amd64.tar.gz";
    hash = "sha256-VlY36puKB1t5FUa8gZznU09PwMSprnQf4kEPH9gL2fY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 cpackget "$out/bin/cpackget"
    install -Dm644 LICENSE.txt "$out/share/licenses/cpackget/LICENSE.txt"
    install -Dm644 third_party_licenses.md "$out/share/licenses/cpackget/third_party_licenses.md"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/cpackget" --version | grep -F "cpackget version ${finalAttrs.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Open-CMSIS-Pack package installer";
    homepage = "https://github.com/Open-CMSIS-Pack/cpackget";
    license = lib.licenses.asl20;
    mainProgram = "cpackget";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
