# Recursos de ejemplo — Backend de Tienda Online

Contenido de ejemplo para arrancar rápido. **Puedes usarlo tal cual o reemplazarlo por tus propios datos.**
Estos archivos resuelven "qué datos van en cada almacén" para que te concentres en **elegir y aprovisionar**
el servicio correcto con CDK.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `schema.sql` | Esquema **relacional** del catálogo para **RDS PostgreSQL**: tablas `categories`, `products` e `inventory` con sus relaciones (claves foráneas). |
| `seed-data.sql` | Datos de prueba para poblar el catálogo y verificar que RDS funciona. |
| `sample-order.json` | Ejemplo de **ítem de DynamoDB** (una orden) con la estructura esperada: `customerId` (PK) + `orderId` (SK) y campos flexibles. |
| `user-data.sh` | Script de arranque de la **EC2 de procesamiento**: formatea y monta el **volumen EBS** en `/data` para el buffer temporal de órdenes. |

---

## 🗄️ RDS PostgreSQL — catálogo

El esquema modela la parte **estructurada y relacional** de la tienda. Una vez desplegado RDS,
puedes cargarlo así (desde una máquina con acceso a la subnet privada):

```bash
psql -h <RDS_ENDPOINT> -U <USUARIO> -d <DB> -f schema.sql
psql -h <RDS_ENDPOINT> -U <USUARIO> -d <DB> -f seed-data.sql
```

> La contraseña NO debería estar en el código. Usa **AWS Secrets Manager** (CDK lo integra con RDS).

---

## 📦 DynamoDB — órdenes

Las órdenes son el caso **NoSQL**: alta frecuencia de escritura y acceso por cliente/orden.
`sample-order.json` muestra la forma de un ítem. Para escribir una orden de prueba:

```bash
aws dynamodb put-item \
  --table-name <NOMBRE_TABLA> \
  --item file://sample-order.json
```

Para leer todas las órdenes de un cliente (consulta por partition key):

```bash
aws dynamodb query \
  --table-name <NOMBRE_TABLA> \
  --key-condition-expression "customerId = :c" \
  --expression-attribute-values '{":c":{"S":"CUST-001"}}'
```

---

## 💽 EBS — procesamiento temporal

`user-data.sh` prepara el disco de bloque adjunto a la EC2: lo formatea (si hace falta) y lo monta
en `/data`, un espacio efímero para procesar órdenes antes de persistirlas. Pásalo como **user data**
del Launch Template / instancia en tu stack CDK.

> El resto (bucket S3, RDS, tabla DynamoDB, VPC, Security Groups, IAM, volumen EBS) lo diseñas tú.
> Estos archivos solo resuelven "qué datos corren dentro" para que te concentres en la arquitectura.

---

## 🖼️ S3 — imágenes

No hay un archivo de ejemplo para imágenes: sube cualquier archivo a tu bucket para probar.

```bash
aws s3 cp alguna-imagen.jpg s3://<NOMBRE_BUCKET>/products/
```

Verifica que la **lifecycle policy** aparezca en la consola de S3 (o con `aws s3api get-bucket-lifecycle-configuration`).
