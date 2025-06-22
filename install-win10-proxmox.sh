#!/bin/bash

# -----------------------------------------
# 🪟 Proxmox Helper Script: Instalar Windows 10 LTSC (ISO temporal)
# -----------------------------------------

VMID=9000
VM_NAME="Windows10-LTSC"
MEMORY=4096
CORES=2
DISK_SIZE="64G"
BRIDGE="vmbr0"

WIN10_URL="https://go.microsoft.com/fwlink/p/?LinkID=2208844&clcid=0x40a&culture=es-es&country=ES"
WIN10_ISO="/tmp/Windows10.iso"

VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
VIRTIO_ISO="/tmp/virtio-win.iso"

echo "🔧 Preparando entorno temporal..."
mkdir -p /tmp

# Descargar ISOs
[[ ! -f "$WIN10_ISO" ]] && echo "⬇️ Descargando Windows 10 LTSC ISO..." && wget -O "$WIN10_ISO" "$WIN10_URL"
[[ ! -f "$VIRTIO_ISO" ]] && echo "⬇️ Descargando VirtIO drivers..." && wget -O "$VIRTIO_ISO" "$VIRTIO_URL"

# Crear VM
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

qm set $VMID --scsi0 local-lvm:$DISK_SIZE
qm set $VMID --ide2 media=cdrom,import-from="$WIN10_ISO"
qm set $VMID --ide3 media=cdrom,import-from="$VIRTIO_ISO"
qm set $VMID --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1
qm set $VMID --vga qxl
qm set $VMID --serial0 socket --usb1 host=tablet

qm start $VMID

echo "✅ VM $VM_NAME ($VMID) creada e iniciada con ISO temporal."
