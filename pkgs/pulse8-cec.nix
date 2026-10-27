# The in-tree pulse8-cec driver (Pulse-Eight USB-CEC adapter), built out-of-tree.
# nixpkgs kernels ship CEC_CORE=m but leave MEDIA_CEC_SUPPORT off, so the driver
# is missing. Building just this one module avoids a full kernel rebuild on
# every kernel bump.
{ lib, stdenv, kernel }:

stdenv.mkDerivation {
  pname = "pulse8-cec";
  inherit (kernel) version src;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  unpackPhase = ''
    runHook preUnpack
    tar -xf $src --wildcards --strip-components=1 '*/drivers/media/cec/usb/pulse8/*'
    runHook postUnpack
  '';

  makeFlags = kernel.commonMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CONFIG_USB_PULSE8_CEC=m"
  ];

  preBuild = ''
    makeFlagsArray+=("M=$PWD/drivers/media/cec/usb/pulse8")
  '';

  buildFlags = [ "modules" ];

  # modules_install (not a plain copy) so the kernel's cmd_sign step emits the
  # .ko.cer digest that nixpkgs' module tree expects next to every module.
  installTargets = [ "modules_install" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];

  meta = {
    description = "Kernel driver for the Pulse-Eight USB-CEC adapter";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
