{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    publisher = "ms-pyright";
    name = "pyright";
    version = "1.1.403";
    hash = "sha256-t5YB1wO76XSnGCG8YKW1HR0aqv+JzefrtSBfVLzuDOU=";
  };

  meta = {
    description = "VS Code static type checking for Python";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-pyright.pyright";
    homepage = "https://github.com/Microsoft/pyright#readme";
    changelog = "https://marketplace.visualstudio.com/items/ms-pyright.pyright/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ratsclub ];
  };
}
