#!/bin/bash

# -----------------------------------------
# 🪟 Proxmox Helper Script: Instalar Windows 10
# Automáticamente crea una VM con ISO oficial y drivers VirtIO
# -----------------------------------------

# Configuraciones iniciales (puedes editar)
VMID=9000
VM_NAME="Windows10"
MEMORY=4096
CORES=2
DISK_SIZE="64G"
BRIDGE="vmbr0"
ISO_DIR="/var/lib/vz/template/iso"

# URLs oficiales
WIN10_URL="https://go.microsoft.com/fwlink/?LinkID=2208844&clcid=0x40a&culture=es-es&country=ES"
VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"

# Nombres de archivo
WIN10_ISO="$ISO_DIR/Windows10.iso"
VIRTIO_ISO="$ISO_DIR/virtio-win.iso"

# ------------------------
echo "🔧 Preparando entorno..."
mkdir -p "$ISO_DIR"

# Descargar Windows 10 si no existe
if [[ ! -f "$WIN10_ISO" ]]; then
  echo "⬇️ Descargando Windows 10 ISO en español desde Microsoft..."
  wget -O "$WIN10_ISO" "$WIN10_URL" || { echo "❌ Error al descargar Windows 10 ISO."; exit 1; }
else
  echo "✔ ISO de Windows 10 ya existe: $(basename "$WIN10_ISO")"
fi

# Descargar VirtIO si no existe
if [[ ! -f "$VIRTIO_ISO" ]]; then
  echo "⬇️ Descargando drivers VirtIO desde Fedora..."
  wget -O "$VIRTIO_ISO" "$VIRTIO_URL" || { echo "❌ Error al descargar VirtIO ISO."; exit 1; }
else
  echo "✔ ISO de VirtIO ya existe: $(basename "$VIRTIO_ISO")"
fi

# ------------------------
echo "🖥️ Creando VM $VM_NAME con ID $VMID..."

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
qm set $VMID --ide2 local:iso/$(basename "$WIN10_ISO"),media=cdrom
qm set $VMID --ide3 local:iso/$(basename "$VIRTIO_ISO"),media=cdrom
qm set $VMID --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1
qm set $VMID --vga qxl
qm set $VMID --serial0 socket --usb1 host=tablet

# ------------------------
echo "🚀 Iniciando VM..."
qm start $VMID

echo "✅ Listo. La máquina virtual $VM_NAME ($VMID) ha sido creada e iniciada."
echo "💡 Instala Windows desde la consola web de Proxmox."
