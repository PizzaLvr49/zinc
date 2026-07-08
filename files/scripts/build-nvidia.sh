#!/usr/bin/env bash
set -xeuo pipefail

: "${NVIDIA_REPO_ID:?set to fedora-nvidia or fedora-nvidia-580}"

mkdir -p /tmp/nvidia-build
pushd /tmp/nvidia-build
dnf download dkms-nvidia --repo="${NVIDIA_REPO_ID}" --arch=noarch --destdir=/tmp/nvidia-build
rpm -i ./*dkms-nvidia*.rpm --noscripts --nodeps
popd

NVIDIA_VERSION="$(basename "$(find /usr/src -iname 'nvidia-*' -type d -maxdepth 1)" | cut -d- -f2)"
KERNEL_VERSION="$(find /usr/lib/modules -maxdepth 1 -type d ! -path /usr/lib/modules -exec basename '{}' ';' | sort | tail -n 1)"

OUTPUTDIR=out dkms install -m "nvidia/${NVIDIA_VERSION}" -k "${KERNEL_VERSION}"
find /usr/lib/modules -iname "nvidia*.ko*"

sed -i 's/omit_drivers/force_drivers/g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's/ nvidia / i915 amdgpu nvidia /g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

rm -rf /tmp/nvidia-build