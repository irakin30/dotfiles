#!@bash@/bin/bash
set -euo pipefail

## Runs the nixpkgs refind installer, then signs what it put on the ESP with
## the machine's sbctl keys. The @vars@ are filled in by replaceVarsWith in
## boot.nix -- this isn't meant to be run straight from the checkout.

@refindInstaller@ "$@"

esp="@esp@"
sbctl="@sbctl@/bin/sbctl"

if [ ! -e /var/lib/sbctl/keys/db/db.key ]; then
    echo "secure boot: no sbctl keys, leaving ESP unsigned (see modules/linux/nixos/boot.nix)" >&2
    exit 0
fi

## rEFInd itself; efi/boot is the copy when installed as removable.
for f in "$esp"/efi/refind/BOOT*.EFI "$esp"/efi/boot/BOOT*.EFI; do
    if [ -e "$f" ]; then
        "$sbctl" sign "$f"
    fi
done

## Kernels are PE images ("MZ" magic). Initrds share the directory but are
## cpio archives -- not verified by the firmware, can't be signed.
for f in "$esp"/efi/refind/kernels/*; do
    if [ -f "$f" ] && [ "$(head -c 2 "$f")" = "MZ" ]; then
        "$sbctl" sign "$f"
    fi
done
