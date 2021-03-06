#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${dir}/../../" && pwd)"

# import global configuration
source ${root}/run.config

out="${dir}/vmlinuz-linuxboot"
kernel_version=${ST_MBR_BOOTLOADER_KERNEL_VERSION}
kernel_config=${ST_MBR_BOOTLOADER_KERNEL_CONFIG}
cmdline=${ST_LINUXBOOT_CMDLINE}

bash "${root}/stboot-installation/make_initramfs.sh"

echo
echo "[INFO]: Patching kernel configuration to include configured command line:"
echo "cmdline: ${cmdline}"
cp "${kernel_config}" "${kernel_config}.patch"
sed -i "s/CONFIG_CMDLINE=.*/CONFIG_CMDLINE=\"${cmdline}\"/" "${kernel_config}.patch"

bash "${root}/stboot-installation/build_kernel.sh" "${root}/${kernel_config}" "${out}" "${kernel_version}"

trap - EXIT
