# README

# Ver

https://gist.github.com/jrdmcgr/3eca10d05f3b02d424d6c9cf684b6b53

# Pasos

```bash

# validar template packer
packer validate ubuntu1804.json 

# construir box


# las opciones de partición se obtienen con:
ls -1 http/d-i/bionic/partman/

# y ahora son:

#export PARTMAN_FILENAME=d1pv1vg1lv2
#export PARTMAN_FILENAME=d1pv1vg2lv7
export PARTMAN_FILENAME=lvm_default


export BOX_VERSION=1.0.0
BOX_FILENAME="ubuntu-18.04-${PARTMAN_FILENAME}-virtualbox-${BOX_VERSION}.box"

export CHECKPOINT_DISABLE=1
export PACKER_LOG_PATH="packer.log" && > ${PACKER_LOG_PATH}

# construye box usando servidor de hora en internet:
time packer build -var=headless=false  -var=version=${BOX_VERSION} ubuntu1804.json

# construye box usando servidor de hora de la red local:
time packer build -var=headless=false  -var=version=${BOX_VERSION} -var=ntp_server=ntp1.mi.dominio.org ubuntu1804.json

# Inserta el nombre del box en el Vagrantfile:
sed -i -e "s@\(^[ ]*srv.vm.box_url = \)\(.*\)@\1\"${BOX_FILENAME}\"@" Vagrantfile

time vagrant up
# las pruebas que necesite realizar dentro de la VM:
vagrant ssh

# eliminamos la VM:
vagrant destroy -f

# elimino el box de mi cuenta:
vagrant box list
vagrant box remove --all --provider virtualbox cesarballardini/ubuntu1804
rm -f ./${BOX_FILENAME}

```

# Referencias

* https://wikitech.wikimedia.org/wiki/PartMan
* https://medium.com/sumup-engineering/image-creation-and-testing-with-hashicorp-packer-and-serverspec-bb2bd065441 packer + serverspec
* https://lihuen.linti.unlp.edu.ar/index.php/Preseed.cfg

