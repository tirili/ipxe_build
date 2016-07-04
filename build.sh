#!/bin/bash
# tiri.linux / Powered by tiri GmbH, Hamburg http://www.tiri.li/

# Integration of SSL Cert for trusted transfer of tiri.linux Bootstrap Files
openssl s_client -connect www.tiri.hamburg:443 -prexit 2>/dev/null </dev/null| \
  sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' | tee trust.crt

# syslinux/isolinux requirements (on RedHat)
[ ! -e /usr/share/syslinux/isolinux.bin -a -x /usr/bin/yum ] && yum install syslinux

# Now build iPXE Bootstrapper (for use with VMware Workstation e1000 ROM)
make clean
time make bin/ipxe.iso bin/ipxe.lkrn bin/8086100f.mrom \
  EMBED=tiri.linux.ipxe ISOLINUX_BIN=/usr/share/syslinux/isolinux.bin \
  TRUST=trust.crt DEBUG=dhcp:1 NO_WERROR=1 V=1

# Show config Stanza for .vmx file
echo '# Add this in your VMware Workstation .vmx file'
cat << EOVMX
ethernet0.present = "TRUE"
ethernet0.connectionType = "nat"
ethernet0.virtualDev = "e1000"
bios.bootOrder = "ethernet0"
e1000bios.filename = "8086100f.mrom"
ethernet0.opromsize = "$(ls -Al bin/8086100f.mrom | awk '{print $5}')"
EOVMX
