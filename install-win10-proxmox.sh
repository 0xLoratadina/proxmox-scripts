#!/bin/bash

# -----------------------------------------
# 🪠 Proxmox Helper Script: Instalar Windows 10 LTSC (ISO temporal)
# -----------------------------------------

VMID=9000
VM_NAME="Windows10-LTSC"
MEMORY=4096
CORES=2
DISK_SIZE=200  # GB
BRIDGE="vmbr0"

WIN10_URL="https://go.microsoft.com/fwlink/p/?LinkID=2208844&clcid=0x40a&culture=es-es&country=ES"
WIN10_ISO="/var/lib/vz/template/iso/Windows10.iso"

VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win-0.1.271.iso"
VIRTIO_ISO="/var/lib/vz/template/iso/virtio-win.iso"

# Estilo visual bonito
echo -e "\n🧰  INICIANDO INSTALADOR DE WINDOWS 10 LTSC EN PROXMOX"
echo    "--------------------------------------------------------"

# Paso 1: Verificar o descargar ISOs
mkdir -p /var/lib/vz/template/iso

echo -e "\n📅 Paso 1/5: Verificando ISOs necesarios..."
if [ ! -f "$WIN10_ISO" ]; then
    echo "⬇️  Descargando Windows 10 LTSC..."
    wget -O "$WIN10_ISO" "$WIN10_URL"
else
    echo "✅ Windows 10 LTSC ya está descargado."
fi

if [ ! -f "$VIRTIO_ISO" ]; then
    echo "⬇️  Descargando VirtIO Drivers..."
    wget -O "$VIRTIO_ISO" "$VIRTIO_URL"
else
    echo "✅ VirtIO ISO ya está descargado."
fi

# Paso 2: Crear la VM
echo -e "\n🛠️  Paso 2/5: Creando Máquina Virtual \"$VM_NAME\"..."
qm create $VMID \
  --name $VM_NAME \
  --memory $MEMORY \
  --cores $CORES \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --ostype win10 \
  --scsihw virtio-scsi-pci \
  --boot order=ide2 \
  --agent enabled=1 \
  --net0 virtio,bridge=$BRIDGE

# Paso 3: Crear disco virtual

echo -e "\n💽 Paso 3/5: Configurando disco virtual de ${DISK_SIZE}G..."
qm set $VMID --scsi0 local-lvm:${DISK_SIZE}

# Paso 4: Configurar hardware adicional
echo -e "\n🎛️  Paso 4/5: Ajustando configuración de hardware..."
qm set $VMID --vga qxl
qm set $VMID --serial0 socket
qm set $VMID --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1

# Paso 5: Montar ISOs

echo -e "\n💼 Paso 5/5: Montando ISOs (Windows + VirtIO)..."
qm set $VMID --ide2 local:iso/$(basename $WIN10_ISO),media=cdrom
qm set $VMID --ide3 local:iso/$(basename $VIRTIO_ISO),media=cdrom

# Iniciar la VM
echo -e "\n🚀 Iniciando máquina virtual..."
qm start $VMID

echo -e "\n✅ INSTALACIÓN COMPLETA"
echo    "💡 Abre la consola de la VM \"$VM_NAME\" en la interfaz web de Proxmox para comenzar la instalación de Windows 10 LTSC."
echo -e "\n✨ Gracias por usar este instalador ✨"
echo    "-----------------------------------------"
