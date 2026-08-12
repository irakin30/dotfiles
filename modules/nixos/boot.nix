
{config, pkgs, ...}: 

{
  environment.systemPackages = with pkgs; [
    sbctl
    limine-full
  ];
  
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; 
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        secureBoot = {
          enable = true;
          sbctl = pkgs.sbctl; 
          autoGenerateKeys = true; 
          autoEnrollKeys.enable = true;
          autoEnrollKeys.extraArgs = [
          "--microsoft"
          "--firmware-builtin"
          ]; 
        };
        extraEntries = 
        "
        /Windows
            protocol: efi
            path: uuid(6b92341c-c19b-4e5e-8e34-06ad22ac36e2):/EFI/Microsoft/Boot/bootmgfw.efi
        ";
        maxGenerations = 5;
      };
    };
  };
}
