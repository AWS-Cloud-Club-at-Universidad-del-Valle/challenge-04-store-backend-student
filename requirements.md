# Requisitos — Backend para una Tienda Online

## 📖 Contexto (historia del problema)

Una **tienda online** necesita almacenar **tres tipos de datos** con características muy distintas:

- **Imágenes de productos:** archivos de gran tamaño, acceso frecuente, **no estructurados**.
- **Catálogo de productos:** datos **estructurados con relaciones** (categorías, precios, inventario).
- **Órdenes de compra:** **escrituras de alta frecuencia**, acceso por `orderId` o `customerId`, **esquema flexible**.

Cada tipo de dato tiene requisitos distintos. **Usar el servicio equivocado impacta el costo y el rendimiento.**

Tu misión como builder es elegir el **almacenamiento correcto para cada caso** y aprovisionarlo con **AWS CDK**, eligiendo el lenguaje de programación que prefieras.

---

## 📋 Requisitos funcionales

| # | Requisito |
|---|---|
| R1 | **S3**: bucket para imágenes de productos, con **lifecycle policy** que mueva a **S3-IA** (Infrequent Access) las imágenes con más de **90 días**. |
| R2 | **RDS (PostgreSQL)**: base de datos relacional para el catálogo (tablas: `products`, `categories`, `inventory`), en **subnet privada** (sin acceso público). |
| R3 | **DynamoDB**: tabla NoSQL para órdenes de compra con **partition key `customerId`** y **sort key `orderId`**, en modo `PAY_PER_REQUEST`. |
| R4 | **EBS**: volumen de bloque para **almacenamiento temporal** de procesamiento de órdenes, adjunto a una instancia **EC2**. |
| R5 | **Todo con CDK**: ningún recurso debe crearse manualmente en la consola. |

---

## 🧩 Servicios AWS

| Servicio | Tipo | Uso en la tienda |
|---|---|---|
| **S3** | Object Storage | Imágenes de productos |
| **RDS** | Relational DB | Catálogo y relaciones |
| **DynamoDB** | NoSQL | Órdenes de alta frecuencia |
| **EBS** | Block Storage | Procesamiento temporal |

**Conceptos clave:** Bases de datos relacionales vs NoSQL · Block vs Object Storage

---

## 📦 Entregables

- [ ] **Bucket S3** con **lifecycle policy** configurada en el stack CDK.
- [ ] Instancia **RDS PostgreSQL** en **subnet privada** (no accesible públicamente).
- [ ] Tabla **DynamoDB** con `customerId` como **PK** y `orderId` como **SK**.
- [ ] **Volumen EBS** adjunto a una EC2 para procesamiento temporal.
- [ ] **Justificación escrita** de por qué se eligió cada servicio para cada tipo de dato (en [`docs/architecture.md`](./docs/architecture.md)).
- [ ] `cdk deploy` **exitoso sin recursos creados manualmente**.

---

## 🏁 Criterios de éxito

1. Los **cuatro tipos de almacenamiento** (S3, RDS, DynamoDB, EBS) están creados y accesibles.
2. **RDS no tiene una IP pública** asignada.
3. La **lifecycle policy de S3** está configurada correctamente (transición a IA tras 90 días).
4. La **tabla DynamoDB** puede recibir escrituras con la estructura definida (`customerId` + `orderId`).

---

## 🐉 Boss Fight (cambio de requisitos en vivo)

> ⚠️ **¡La tienda creció de 10,000 a 1,000,000 de clientes!** El equipo de producto pide soportar este volumen **sin rediseñar la arquitectura**.

**¿Qué cambia?**

- **DynamoDB** ya escala solo (`PAY_PER_REQUEST`), pero debes **habilitar DynamoDB Streams** para procesar eventos de órdenes en tiempo real.
- **RDS** necesita una **Read Replica** para distribuir las lecturas del catálogo.
- El bucket **S3** necesita **replicación cross-region** para disponibilidad global.
- Actualiza tu stack CDK para reflejar estos cambios **sin recrear los recursos existentes**.

---

## 🧹 Cleanup obligatorio

Al terminar:

```bash
cd cdk
cdk destroy
```

> ⚠️ **RDS** puede tardar varios minutos en eliminarse. Si tienes una **Read Replica**, **elimínala antes** que la instancia principal.
> Revisa la consola de AWS por recursos huérfanos (snapshots de RDS, objetos/buckets S3, volúmenes EBS, ENIs).
