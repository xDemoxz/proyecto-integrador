# MySQL SQL Templates

Este documento contiene una colección de scripts base para trabajar con MySQL.

---

# 1. Crear una base de datos (DDL)

```sql
CREATE DATABASE nombre_base_datos;
```

Seleccionar la base de datos:

```sql
USE nombre_base_datos;
```

---

# 2. Crear una tabla (DDL)

```sql
CREATE TABLE nombre_tabla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    fecha_creacion DATE,
    activo BOOLEAN DEFAULT TRUE
);
```

---

# 3. Crear una tabla con clave foránea (DDL)

```sql
CREATE TABLE departamentos (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    salario DECIMAL(10,2),

    id_departamento INT,

    CONSTRAINT fk_empleado_departamento
        FOREIGN KEY (id_departamento)
        REFERENCES departamentos(id_departamento)
);
```

---

# 4. Modificar una tabla (DDL)

Agregar una columna

```sql
ALTER TABLE nombre_tabla
ADD telefono VARCHAR(20);
```

Eliminar una columna

```sql
ALTER TABLE nombre_tabla
DROP COLUMN telefono;
```

Cambiar el tipo de dato

```sql
ALTER TABLE nombre_tabla
MODIFY telefono VARCHAR(50);
```

Renombrar una columna

```sql
ALTER TABLE nombre_tabla
CHANGE telefono celular VARCHAR(20);
```

Renombrar una tabla

```sql
RENAME TABLE nombre_tabla TO nuevo_nombre;
```

---

# 5. Eliminar tablas (DDL)

Eliminar una tabla

```sql
DROP TABLE nombre_tabla;
```

Eliminar varias tablas

```sql
DROP TABLE tabla1, tabla2, tabla3;
```

Eliminar la base de datos

```sql
DROP DATABASE nombre_base_datos;
```

---

# 6. Insertar datos (DML)

Insertar un registro

```sql
INSERT INTO nombre_tabla (
    nombre,
    descripcion
)
VALUES (
    'Juan',
    'Administrador'
);
```

Insertar varios registros

```sql
INSERT INTO nombre_tabla (
    nombre,
    descripcion
)
VALUES
('Juan','Administrador'),
('Pedro','Analista'),
('Maria','Docente');
```

---

# 7. Consultar datos (DQL)

Todos los registros

```sql
SELECT * FROM nombre_tabla;
```

Columnas específicas

```sql
SELECT nombre, descripcion
FROM nombre_tabla;
```

Con condición

```sql
SELECT *
FROM nombre_tabla
WHERE nombre = 'Juan';
```

Ordenar

```sql
SELECT *
FROM nombre_tabla
ORDER BY nombre ASC;
```

Orden descendente

```sql
SELECT *
FROM nombre_tabla
ORDER BY nombre DESC;
```

Limitar resultados

```sql
SELECT *
FROM nombre_tabla
LIMIT 10;
```

---

# 8. Actualizar datos (DML)

```sql
UPDATE nombre_tabla
SET nombre = 'Carlos'
WHERE id = 1;
```

Actualizar varias columnas

```sql
UPDATE nombre_tabla
SET
    nombre = 'Carlos',
    descripcion = 'Supervisor'
WHERE id = 1;
```

---

# 9. Eliminar registros (DML)

Eliminar un registro

```sql
DELETE FROM nombre_tabla
WHERE id = 1;
```

Eliminar todos los registros

```sql
DELETE FROM nombre_tabla;
```

Vaciar la tabla

```sql
TRUNCATE TABLE nombre_tabla;
```

---

# 10. Relaciones (JOIN)

INNER JOIN

```sql
SELECT *
FROM empleados e
INNER JOIN departamentos d
ON e.id_departamento = d.id_departamento;
```

LEFT JOIN

```sql
SELECT *
FROM empleados e
LEFT JOIN departamentos d
ON e.id_departamento = d.id_departamento;
```

RIGHT JOIN

```sql
SELECT *
FROM empleados e
RIGHT JOIN departamentos d
ON e.id_departamento = d.id_departamento;
```

---

# 11. Agregar restricciones (DDL)

Agregar PRIMARY KEY

```sql
ALTER TABLE nombre_tabla
ADD PRIMARY KEY (id);
```

Agregar FOREIGN KEY

```sql
ALTER TABLE empleados
ADD CONSTRAINT fk_departamento
FOREIGN KEY (id_departamento)
REFERENCES departamentos(id_departamento);
```

Agregar UNIQUE

```sql
ALTER TABLE usuarios
ADD CONSTRAINT uq_correo
UNIQUE (correo);
```

---

# 12. Crear índices

```sql
CREATE INDEX idx_nombre
ON nombre_tabla(nombre);
```

Eliminar índice

```sql
DROP INDEX idx_nombre
ON nombre_tabla;
```

---

# 13. Crear vistas

```sql
CREATE VIEW vista_empleados AS

SELECT
    nombre,
    salario
FROM empleados;
```

Consultar una vista

```sql
SELECT *
FROM vista_empleados;
```

Eliminar vista

```sql
DROP VIEW vista_empleados;
```

---

# 14. Mostrar información

Mostrar tablas

```sql
SHOW TABLES;
```

Mostrar bases de datos

```sql
SHOW DATABASES;
```

Ver estructura de una tabla

```sql
DESCRIBE nombre_tabla;
```

Ver script de creación

```sql
SHOW CREATE TABLE nombre_tabla;
```

---

# 15. Clasificación de sublenguajes SQL

## DDL (Data Definition Language)

- CREATE
- ALTER
- DROP
- TRUNCATE
- RENAME

## DML (Data Manipulation Language)

- INSERT
- UPDATE
- DELETE

## DQL (Data Query Language)

- SELECT

## DCL (Data Control Language)

- GRANT
- REVOKE

## TCL (Transaction Control Language)

- COMMIT
- ROLLBACK
- SAVEPOINT
- START TRANSACTION

---

# 16. Transacciones

```sql
START TRANSACTION;

UPDATE cuentas
SET saldo = saldo - 100
WHERE id = 1;

UPDATE cuentas
SET saldo = saldo + 100
WHERE id = 2;

COMMIT;
```

Deshacer cambios

```sql
ROLLBACK;
```