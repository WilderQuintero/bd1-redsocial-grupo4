--
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL
-- Todas las instrucciones se deben realizar en secuencia sin errores
-- Probar los scripts en detalle
--

--
-- Modificación de Tablas
--

--
-- Gestionar una tabla "nueva"
-- 1.- "agregar" una nueva tabla a la base de datos que tenga relación con el sistema
-- 2.- Darle un nombre "coherente"
-- 3.- Agregar campos coherentes con la tabla
-- 4.- Realizar todas las operaciones que se solicitan a continuación
--


-- 1.
-- Crear una tabla "nueva" de su iniciativa (una tabla coherente con el sistema con su nombre, no coloque "nueva" como nombre)
--
SET search_path TO red_social_pascualina;

    CREATE TABLE probando_ando (
    id_proyecto SERIAL,
    descripcion TEXT
);

-- 2
-- Agregar una clave primaria y otros 3 campos cualquiera a la tabla "nueva"
-- Mínimo un campo tipo texto y uno numérico

    ALTER TABLE probando_ando
    ADD PRIMARY KEY (id_proyecto);

    ALTER TABLE probando_ando
    ADD COLUMN nombre_proyecto VARCHAR(50) NOT NULL,
    ADD COLUMN presupuesto_estimado NUMERIC(12, 2);

--

-- 3
-- Quitar uno de los campos de la tabla "nueva"
--
    ALTER TABLE probando_ando
    DROP COLUMN descripcion;

-- 4
-- Cambiar el nombre de la tabla "nueva" a otro nombre "otro_nombre"
-- Todas las operaciones siguientes se realizan sobre la tabla renombrada
--
    ALTER TABLE probando_ando
    RENAME TO probando_ando_2;

-- 5
-- Agregar un campo único a la tabla
--
    ALTER TABLE probando_ando_2
    ADD COLUMN codigo_unico VARCHAR(20) UNIQUE;

-- 6
-- Agregar 2 fechas de inicio y fin; y colocar un control de orden de fechas
--
    ALTER TABLE probando_ando_2
    ADD COLUMN fecha_inicio DATE,
    ADD COLUMN fecha_fin DATE,
    ADD CONSTRAINT chk_fecha CHECK (fecha_inicio <= fecha_fin);


-- 7
-- Agregar 1 campo entero y colocar un control para que no sea negativo
--
    ALTER TABLE probando_ando_2
    ADD COLUMN numero_participantes INT,
    ADD CONSTRAINT chk_participantes CHECK (numero_participantes >= 0);


-- 8
-- Modificar el tamaño de un campo texto de la tabla renombra
--
    ALTER TABLE probando_ando_2
    ALTER COLUMN nombre_proyecto TYPE VARCHAR(100);


-- 9
-- Modificar el campo numeríco y colocar un control de rango
--
    ALTER TABLE probando_ando_2
    ALTER COLUMN presupuesto_estimado TYPE NUMERIC(15, 2),
    ADD CONSTRAINT chk_presupuesto CHECK (presupuesto_estimado >= 0 AND presupuesto_estimado <= 1000000);



-- 10
-- Agregar un índice a la tabla (cualquier campo)
--
    CREATE INDEX idx_codigo_unico ON probando_ando_2 (codigo_unico);



--
-- 11
-- Eliminar una de las fechas
--

    ALTER TABLE probando_ando_2
    DROP COLUMN fecha_fin;


-- 12
-- Borrar todos los datos de una tabla sin dejar traza
--
