#!/bin/bash

# -----------------------------------------
# 🪟 Proxmox Helper Script: Instalar Windows 10 LTSC (ISO temporal)
# -----------------------------------------

# Configuración de la VM
VMID=9000
VM_NAME="Windows10-LTSC"
MEMORY=4096
CORES=2
DISK_SIZE="64G"
BRIDGE="vmbr0"

# ISO (Windows 10 LTSC oficial en español desde Microsoft)
WIN10_URL="https://go.microsoft.com/fwlink/p/?LinkID=2208844&clcid=0x40a&culture=es-es&country=ES"
WIN10_ISO="/tmp/Windows10.iso"

# Drivers VirtIO (última versión estable desde Fedora)
VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
VIRTIO_ISO="/tmp/virtio-win.iso"

echo "🔧 Preparando entorno temporal..."
mkdir -p /tmp

# Descargar ISO de Windows 10
if [[ ! -f "$WIN10_ISO" ]]; then
  echo "⬇️ Descargando Windows 10 LTSC ISO en español..."
  wget -O "$WIN10_ISO" "$WIN10_URL" || { echo "❌ Error al descargar Windows 10 ISO."; exit 1; }
else
  echo "✔ ISO de Windows ya existe en /tmp"
fi

# Descargar ISO de VirtIO
if [[ ! -f "$VIRTIO_ISO" ]]; then
  echo "⬇️ Descargando VirtIO drivers..."
  wget -O "$VIRTIO_ISO" "$VIRTIO_URL" || { echo "❌ Error al descargar VirtIO ISO."; exit 1; }
else
  echo "✔ ISO de VirtIO ya existe en /tmp"
fi

# Crear la VM
echo "🖥️ Creando VM $VM_NAME ($VMID)..."
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

# Crear disco en local-lvm
qm set $VMID --scsi0 local-lvm:$DISK_SIZE

# Montar los ISOs directamente desde /tmp
qm set $VMID --ide2 media=cdrom,import-from="$WIN10_ISO"
qm set $VMID --ide3 media=cdrom,import-from="$VIRTIO_ISO"

# Agregar disco EFI
qm set $VMID --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1

# VGA y USB Tablet
qm set $VMID --vga qxl
qm set $VMID --serial0 socket --usb1 host=tablet

# Iniciar la VM
qm start $VMID

echo "✅ VM $VM_NAME ($VMID) creada e iniciada con ISO temporal."
echo "💡 Puedes instalar Windows desde la consola web ahora."
