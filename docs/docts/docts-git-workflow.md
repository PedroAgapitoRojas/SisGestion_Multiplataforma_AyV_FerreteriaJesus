# Git Workflow - LRPD_MA

## Proyecto
Sistema Multiplataforma de Ventas e Inventario para la Ferretería Jesús desarrollado con Flutter, Dart y metodología SCRUM.

---

# Organización de Ramas

| Rama | Propósito |
|---|---|
| main | Versión estable y funcional del proyecto |
| develop | Rama de integración del equipo |
| feature/login-auth | Login, autenticación y roles |
| feature/products-inventory | Gestión de productos e inventario |
| feature/sales-payment | Ventas y métodos de pago |
| feature/reports-dashboard | Reportes e indicadores |
| feature/ui-responsive | Diseño responsive y experiencia visual |

---

# Asignación de Integrantes

| Integrante | Rama Asignada | Responsabilidad |
|---|---|---|
| Mateo Chuquispuma / Victor Toribio | feature/login-auth | Sistema de autenticación |
| Sebastian David Campos Mora | feature/products-inventory | Gestión de productos e inventario |
| Andrea Nicole Loyola Mendoza | feature/ui-responsive | Diseño UI/UX |
| Pedro Agapito | feature/sales-payment | Registro de ventas y pagos |
| Nikoll Gisel Rojas Caycho | feature/reports-dashboard | Reportes y dashboard |

---

# Flujo de Trabajo

El proyecto utiliza un flujo basado en Git Flow simplificado:

```plaintext
feature/* → develop → main
```

## Reglas

- Ningún integrante debe trabajar directamente sobre `main`.
- Todos los cambios deben desarrollarse en ramas `feature/*`.
- Las funcionalidades terminadas deben integrarse primero en `develop`.
- Solo versiones estables pasarán a `main`.

---

# Procedimiento de Trabajo

## 1. Actualizar rama develop

```bash
git checkout develop
git pull origin develop
```

---

## 2. Entrar a la rama asignada

```bash
git checkout feature/nombre-rama
```

Ejemplo:

```bash
git checkout feature/sales-payment
```

---

## 3. Guardar cambios

```bash
git add .
git commit -m "feat: descripción del avance"
```

---

## 4. Subir avances

```bash
git push origin feature/nombre-rama
```

---

## 5. Integración

Cuando una funcionalidad esté lista:

- Crear Pull Request hacia `develop`
- Revisar el código
- Aprobar cambios
- Realizar merge

---

# Convenciones de Commits

| Tipo | Uso |
|---|---|
| feat | Nueva funcionalidad |
| fix | Corrección de errores |
| update | Actualización o mejora |
| refactor | Reestructuración de código |
| docs | Cambios en documentación |

## Ejemplos

```bash
git commit -m "feat: módulo de ventas implementado"
```

```bash
git commit -m "fix: error en login corregido"
```

```bash
git commit -m "docs: actualización del workflow"
```

---

# Tecnologías Utilizadas

- Flutter
- Dart
- Firebase
- Git & GitHub
- SCRUM

---

# Objetivo del Workflow

Mantener un desarrollo organizado, colaborativo y estable, permitiendo que cada integrante trabaje de manera independiente sin afectar el progreso general del proyecto.
