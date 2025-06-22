# 🪟 Proxmox Helper Script: Instalar Windows 10 (Automático)

Este script te permite **crear e iniciar automáticamente una máquina virtual de Windows 10 en Proxmox VE**, descargando directamente la ISO oficial en español desde Microsoft y los controladores **VirtIO** desde Fedora. Es ideal para simplificar la instalación sin tener que configurar todo manualmente.

---

## 🚀 ¿Qué hace este script?

✅ Descarga automáticamente:
- 🟦 ISO de Windows 10 en español (oficial de Microsoft)
- 🔧 Drivers VirtIO más recientes desde Fedora

✅ Crea una VM lista para instalación:
- UEFI (OVMF)
- Disco y red con VirtIO
- Consola gráfica (QXL)
- Configuración optimizada para Windows 10

✅ Inicia la máquina lista para que comiences la instalación desde la interfaz web de Proxmox.

---

## 📦 Requisitos

- Un servidor con **Proxmox VE** (v6 o superior)
- Conexión a internet (para descargar las ISOs)
- Almacenamiento disponible en `local-lvm`
- Proxmox configurado con un bridge de red (`vmbr0` por defecto)

---

## ⚙️ Cómo usar

### 1. Clonar o descargar el script

```bash
wget https://raw.githubusercontent.com/TU_USUARIO/install-win10-proxmox/main/install-win10-proxmox.sh
chmod +x install-win10-proxmox.sh
