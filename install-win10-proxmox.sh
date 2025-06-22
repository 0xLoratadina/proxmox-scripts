#!/bin/bash

# ===============================
# 🪟 PROXMOX - INSTALADOR WINDOWS 10 LTSC
# ===============================

VMID=9000
VM_NAME="Windows10-LTSC"
MEMORY=4096
CORES=2
DISK_SIZE="200G"
BRIDGE="vmbr0"

ISO_DIR="/var/lib/vz/template/iso"
mkdir -p "$ISO_DIR"

WIN10_URL="https://go.microsoft.com/fwlink/p/?LinkID=2208844&clcid=0x40a&culture=es-es&country=ES"
VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win-0.1.271.iso"

WIN10_ISO="$ISO_DIR/Windows10.iso"
VIRTIO_ISO="$ISO_DIR/virtio-win.iso"

# ------------------------------
echo -e "\n🧰  INICIANDO INSTALADOR DE WINDOWS 10 LTSC EN PROXMOX"
echo    "--------------------------------------------------------"

# Paso 1: Descarga de ISOs
echo -e "\n📥 Paso 1/5: Verificando ISOs necesarios..."

if [[ -f "$WIN10_ISO" ]]; then
  echo "✅ Windows 10 LTSC ya está descargado."
else
  echo "⬇️  Descargando Windows 10 LTSC..."
  wget -q --show-progress -O "$WIN10_ISO" "$WIN10_URL"
fi

if [[ -f "$VIRTIO_ISO" ]]; then
  echo "✅ VirtIO ISO ya está descargado."
else
  echo "⬇️  Descargando VirtIO Drivers..."
  wget -q --show-progress -O "$VIRTIO_ISO" "$VIRTIO_URL"
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
  --net0 virtio,bridge=$BRIDGE > /dev/null

# Paso 3: Crear disco virtual de 200G
echo -e "\n💽 Paso 3/5: Creando disco virtual de $DISK_SIZE..."
qm disk create $VMID scsi0 $DISK_SIZE --storage local-lvm > /dev/null

# Paso 4: Configuración de periféricos y video
echo -e "\n🎛️  Paso 4/5: Ajustando configuración de hardware..."
qm set $VMID --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1 > /dev/null
qm set $VMID --tablet 1 > /dev/null
qm set $VMID --vga qxl > /dev/null

# Paso 5: Montar ISOs
echo -e "\n📀 Paso 5/5: Montando ISOs (Windows + VirtIO)..."
qm set $VMID --ide2 local:iso/Windows10.iso,media=cdrom > /dev/null
qm set $VMID --ide3 local:iso/virtio-win.iso,media=cdrom > /dev/null

# Arrancar la VM
echo -e "\n🚀 Iniciando máquina virtual..."
qm start $VMID > /dev/null

# Final
echo -e "\n✅ INSTALACIÓN COMPLETA"
echo "💡 Abre la consola de la VM \"$VM_NAME\" en la interfaz web de Proxmox para comenzar la instalación de Windows 10 LTSC."

echo -e "\n✨ Gracias por usar este instalador ✨"
echo "-----------------------------------------"
