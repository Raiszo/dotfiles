{
  lib,
  nodejs,
  symlinkJoin,
  vscode-utils,
  writeShellScriptBin,
}:

let
  stm32CubeCore = vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "STMicroelectronics";
      name = "stm32cube-ide-core";
      version = "1.4.0";
      arch = "linux-x64";
      hash = "sha256-4dhukhhkFglJmasH1PcEm0kOde6LIvsFIdOfokjfvJo=";
    };

    meta = {
      description = "STM32CubeIDE for Visual Studio Code core extension";
      homepage = "https://marketplace.visualstudio.com/items?itemName=STMicroelectronics.stm32cube-ide-core";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  stm32StlinkAdapter = vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "STMicroelectronics";
      name = "stm32cube-ide-debug-stlink-gdbserver";
      version = "1.4.0";
      hash = "sha256-6ObiLcaxJS7OQANQoqfoJ+N2bL2aHWylo6TPi1GnwuA=";
    };

    meta = {
      description = "STM32Cube ST-LINK GDB server debug adapter";
      homepage = "https://marketplace.visualstudio.com/items?itemName=STMicroelectronics.stm32cube-ide-debug-stlink-gdbserver";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  cubePath = "${stm32CubeCore}/share/vscode/extensions/STMicroelectronics.stm32cube-ide-core/resources/binaries/linux/x86_64";
  adapterPath = "${stm32StlinkAdapter}/share/vscode/extensions/STMicroelectronics.stm32cube-ide-debug-stlink-gdbserver/lib/adapter/STLinkDebugTargetAdapter.js";

  wrappers = writeShellScriptBin "stm32-cube" ''
    exec "${cubePath}/cube" "$@"
  '';

  dapWrapper = writeShellScriptBin "stm32-stlink-dap" ''
    export PATH="${cubePath}:$PATH"
    exec "${nodejs}/bin/node" "${adapterPath}" "$@"
  '';
in
symlinkJoin {
  name = "stm32-stlink-dap-1.4.0";
  paths = [
    stm32CubeCore
    stm32StlinkAdapter
    wrappers
    dapWrapper
  ];

  meta = {
    description = "Packaged STM32Cube CLI and ST-LINK DAP adapter for Emacs";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
