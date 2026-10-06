#!/bin/bash
# ─────────────────────────────────────────────────────────────
# user-data de EJEMPLO — Reto 4: EC2 de procesamiento de órdenes
#
# Este script se ejecuta al arrancar la instancia EC2 (Amazon Linux 2023
# o Amazon Linux 2). Prepara el VOLUMEN EBS adjunto como almacenamiento
# TEMPORAL de bloque: lo formatea (si está vacío) y lo monta en /data.
#
# ¿Por qué EBS y no S3 aquí? Porque es un buffer de trabajo efímero,
# de bloque, adjunto a la instancia: ideal para procesar órdenes antes
# de persistirlas en DynamoDB.
#
# Cómo lo usa tu stack CDK:
#   - Pásalo como user-data del Launch Template / instancia EC2.
#   - Asegúrate de adjuntar un volumen EBS adicional (p. ej. /dev/xvdf o
#     /dev/nvme1n1 según el tipo de instancia).
# ─────────────────────────────────────────────────────────────
set -euxo pipefail

# Nombre del dispositivo del volumen EBS adicional.
# En instancias Nitro suele ser /dev/nvme1n1; en otras, /dev/xvdf.
# Ajusta según el deviceName que definas en tu stack CDK.
DEVICE="/dev/nvme1n1"
if [ ! -b "$DEVICE" ]; then
  DEVICE="/dev/xvdf"
fi

MOUNT_POINT="/data"
mkdir -p "$MOUNT_POINT"

# Formatea el volumen SOLO si no tiene sistema de archivos (evita borrar datos)
if ! blkid "$DEVICE" >/dev/null 2>&1; then
  mkfs -t xfs "$DEVICE"
fi

# Monta y persiste en /etc/fstab
mount "$DEVICE" "$MOUNT_POINT" || true
UUID=$(blkid -s UUID -o value "$DEVICE" || true)
if [ -n "${UUID}" ] && ! grep -q "$UUID" /etc/fstab; then
  echo "UUID=${UUID}  ${MOUNT_POINT}  xfs  defaults,nofail  0  2" >> /etc/fstab
fi

# Carpeta de trabajo para el buffer temporal de órdenes
mkdir -p "${MOUNT_POINT}/orders-processing"
echo "EBS montado en ${MOUNT_POINT} para procesamiento temporal de órdenes." \
  > "${MOUNT_POINT}/README.txt"
