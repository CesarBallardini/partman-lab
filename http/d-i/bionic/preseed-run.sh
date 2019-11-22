#!/bin/sh

##
# consigo el nombre del archivo de partman a utilizar:
#
preseed_partman=/./partman/lvm-default
if [ ! -z "$(debconf-get packer/partman)" ]
then
  preseed_partman=/./partman/"$(debconf-get packer/partman)"
fi

debconf-set preseed/include "${preseed_partman} data-seed.cfg"

##
# FIXME: aprender como usar network-console
#debconf-set preseed/include "network-console.cfg"

# ponemos en hora el installer, sino cuando arranca por primera vez fallan los repos APT por la hora mal puesta
# preseed que deberian estar en el template y asigno aca por ahora
if [ ! -z "$(debconf-get packer/ntp)" ]
then
  debconf-set clock-setup/ntp-server "$(debconf-get packer/ntp)"
fi

