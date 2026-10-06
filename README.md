# Reto 4 — Backend para una Tienda Online

> **Nivel:** Intermedio · **Programa:** AWS Cloud Practitioner Challenge · **AWS SBG Univalle**

Selecciona y aprovisiona con **AWS CDK** el **almacenamiento correcto para cada tipo de dato** de una tienda online: **imágenes** de productos, **catálogo** de productos y **órdenes** de compra.

---

## 🎯 Objetivo

Decidir el **tipo de almacenamiento correcto** para cada componente de una tienda online y aprovisionarlo usando **AWS CDK**, entendiendo las diferencias entre almacenamiento de **objetos (S3)**, **en bloque (EBS)**, **relacional (RDS)** y **NoSQL (DynamoDB)**.

La historia completa del problema y los requisitos funcionales están en **[`requirements.md`](./requirements.md)**.

---

## 🧠 La decisión clave del reto

No hay un único "almacenamiento bueno": cada dato pide el servicio correcto. Elegir mal impacta **costo** y **rendimiento**.

| Tipo de dato | Características | Servicio esperado | Por qué |
|---|---|---|---|
| **Imágenes de productos** | Archivos grandes, no estructurados, acceso frecuente al inicio que decae con el tiempo | **S3** (Object Storage) | Barato, escalable, servible por HTTP/CDN; la **lifecycle policy** abarata las imágenes viejas moviéndolas a S3-IA |
| **Catálogo de productos** | Estructurado, con relaciones (categorías, precios, inventario) | **RDS PostgreSQL** (Relational) | Integridad referencial, joins, SQL |
| **Órdenes de compra** | Escrituras de alta frecuencia, acceso por `orderId`/`customerId`, esquema flexible | **DynamoDB** (NoSQL) | Escala horizontal, latencia baja, clave-valor |
| **Procesamiento temporal** | Buffer de trabajo efímero en una EC2 | **EBS** (Block Storage) | Disco de bloque adjunto a la instancia |

---

## 🧰 Prerrequisitos

Antes de empezar, asegúrate de tener:

- [ ] **Node.js** 18+ (necesario para el CLI de CDK, sin importar el lenguaje que elijas)
- [ ] **AWS CLI** configurado con credenciales válidas (`aws configure`)
- [ ] **AWS CDK CLI** instalado globalmente:
  ```bash
  npm install -g aws-cdk
  cdk --version
  ```
- [ ] Runtime del lenguaje que vayas a usar (uno de):
  - **TypeScript / JavaScript** → Node.js 18+
  - **Python** → Python 3.9+ y `pip`
  - **Java** → JDK 11+ y Maven
  - **Go** → Go 1.18+
  - **C#** → .NET 6+
- [ ] Un cliente **PostgreSQL** (`psql`) **solo si** quieres conectarte a RDS para probar el esquema (opcional).

---

## 🚀 Inicio Rápido

Este Starter Kit **no incluye el proyecto CDK ya inicializado**: tú eliges el lenguaje.

### 1. Inicializa tu proyecto CDK en la carpeta `cdk/`

```bash
cd cdk
```

Elige **uno** de los siguientes lenguajes y ejecútalo dentro de `cdk/`:

```bash
# TypeScript
cdk init app --language typescript

# Python
cdk init app --language python

# Java
cdk init app --language java

# Go
cdk init app --language go

# C#
cdk init app --language csharp
```

> 💡 `cdk init` requiere que la carpeta esté vacía. La carpeta `cdk/` viene vacía a propósito para que puedas inicializar en tu lenguaje preferido.

### 2. Bootstrap del entorno (solo una vez por cuenta/región)

```bash
cdk bootstrap
```

### 3. Sintetiza, despliega y destruye

```bash
cdk synth      # Genera la plantilla de CloudFormation (valida tu código)
cdk deploy     # Despliega la infraestructura en AWS
cdk destroy    # Elimina TODOS los recursos (¡obligatorio al terminar!)
```

---

## 📁 Estructura del repositorio

```
challenge-04-store-backend-student/
├── README.md              # Este archivo (inicio rápido)
├── requirements.md        # Historia del problema y requisitos funcionales
├── cdk/                   # 👉 Inicializa aquí tu proyecto CDK (viene vacía)
├── application/           # Recursos de EJEMPLO (esquema SQL, seed, user-data)
│   ├── schema.sql
│   ├── seed-data.sql
│   ├── sample-order.json
│   ├── user-data.sh
│   └── README.md
└── docs/
    └── architecture.md    # Plantilla para que documentes tu arquitectura
```

---

## 🗂️ ¿Qué hay en cada carpeta?

| Carpeta / Archivo | Para qué sirve |
|---|---|
| `cdk/` | Aquí construyes tu infraestructura como código. Empieza vacía. |
| `application/` | Recursos **de ejemplo** para no perder tiempo: el **esquema SQL** del catálogo (`schema.sql`), datos de prueba (`seed-data.sql`), un ejemplo de ítem de DynamoDB (`sample-order.json`) y un `user-data.sh` para la EC2 de procesamiento. **Puedes usarlos tal cual o reemplazarlos.** |
| `docs/architecture.md` | Plantilla para que documentes tu diseño y **justifiques cada elección** de almacenamiento. |
| `requirements.md` | Lo que tu solución debe cumplir. |

---

## ✅ Lo que debes construir (resumen)

1. **Bucket S3** para imágenes de productos, con **lifecycle policy** (mover a S3-IA lo que tenga más de 90 días).
2. **RDS PostgreSQL** para el catálogo (`products`, `categories`, `inventory`) en **subnet privada** (sin IP pública).
3. **Tabla DynamoDB** para órdenes: PK `customerId`, SK `orderId`, `PAY_PER_REQUEST`.
4. **Volumen EBS** para procesamiento temporal de órdenes en una instancia EC2.
5. **Justificación escrita** de por qué elegiste cada servicio para cada tipo de dato.

Todo definido con **CDK**. **Ningún recurso se crea manualmente.**

Consulta **[`requirements.md`](./requirements.md)** para el detalle y los criterios de éxito.

---

## 🧹 Cleanup (¡importante!)

Al terminar el reto, elimina todos los recursos para evitar costos:

```bash
cd cdk
cdk destroy
```

> ⚠️ **RDS** puede tardar **varios minutos** en eliminarse. Si creaste una **Read Replica** (Boss Fight), **elimínala antes** que la instancia principal.
> Revisa la consola de AWS por **recursos huérfanos** (snapshots de RDS, buckets S3 con objetos, volúmenes EBS).

---

## 📚 Recursos útiles

- [AWS CDK — Documentación oficial](https://docs.aws.amazon.com/cdk/v2/guide/home.html)
- [AWS CDK API Reference](https://docs.aws.amazon.com/cdk/api/v2/)
- [Amazon S3](https://docs.aws.amazon.com/s3/) · [RDS](https://docs.aws.amazon.com/rds/) · [DynamoDB](https://docs.aws.amazon.com/dynamodb/) · [EBS](https://docs.aws.amazon.com/ebs/)
- [S3 Storage Classes](https://aws.amazon.com/s3/storage-classes/) · [SQL vs NoSQL](https://aws.amazon.com/nosql/)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

_AWS Student Builder Group — Universidad del Valle_
