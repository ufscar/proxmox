# Script criado pela Secretaria de Informatica - SIn - UFSCar
# Versao 1 - Data: 07/11/2025
#
# Colaboracao das Equipes:
# DeOTIC
# DeTIC-Ar
# DeTIC-Ls
# DeTIC-So
#
#!/bin/bash
#Ajustar as variaveis de acordo com o HOST e CAMPUS que o script esta rodando
REMOTO='2'
LOCAL='1'
CAMPUS='scl'

HOST_REMOTO='pve-server-'$REMOTO'-'$CAMPUS'.ufscar.br'
DIR_HOST_REMOTO='/etc/pve/nodes/pve-server-'$REMOTO'-'$CAMPUS'/qemu-server/*'
DIR_HOST_LOCAL='/etc/pve/nodes/pve-server-'$LOCAL'-'$CAMPUS'/qemu-server/.'

# Testa se o DNS do host remoto esta acessivel
ping -c1 $HOST_REMOTO 2>/dev/null 1>/dev/null
if [ "$?" = 0 ]
then
  echo "Servidor Online - OK"
else
  echo "Servidor Offline - ERROR"

  # Corrige o numero de quoruns exigidos
  pvecm expected 1

  # Verifica se tem VM rodando no host remoto
  if [ "$(ls -A $DIR_HOST_REMOTO)" ]
  then
    # Diretorio do host remoto contem VM, entao move para o host local
    mv $DIR_HOST_REMOTO $DIR_HOST_LOCAL

    # Pega a lista de ID de todas as VMs existentes no CLUSTER PROXMOX
    VM_LIST=`qm list | awk '/[0-9][0-9][0-9]/{print}' | cut -c 8-10`

    # Percorre linha por linha da variavel VM_LIST para iniciar as VMs
    while IFS= read -r line; do
      qm start $line
    done <<< "$VM_LIST"
  fi
fi
