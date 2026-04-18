--
-- Scripts de Modificación de la Base de Datos - SGBD PostgreSQL
-- Todas las instrucciones se deben realizar en secuencia sin errores
-- Probar los scripts en detalle
--

--
-- Modificación de la Base de Datos
--



SET search_path TO red_social_pascualina;
SELECT * FROM perfil_usuario;

create table perfil_usuario
(
    id_perfil_u bigserial
        constraint pk_perfil_usuario
            primary key,
    id_usuario  bigint not null
        constraint uk_perfil_id_usuario
            unique
        constraint fk_perfil_usuario_ref_usuario
            references usuario
            on delete cascade,
    foto_perfil varchar(255),
    biografia   text,
    telefono    varchar(20),
    sitio_web   varchar(255),
    datos_extra jsonb
);

--
-- 1.- DATOS SEMI-ESTRUCTURADOS PARA DATOS PARA BIG DATA
-- Gestionar el campo "perfil_usuario" en tabla "usuarios"
-- Debe incluir otros datos diferentes al ejemplo del Anexo B
-- 1.- "agregar" un campo tipo JSON o JSNOB
-- 2.- Agregar un par de registros
-- 3.- Consultar la información agregada
-- 4.- Describir el campo y explicar su propósito
--

    ALTER TABLE perfil_usuario
    ADD COLUMN datos_extra JSONB;
-- Este campo nos puede ayudar a guardar información adicional sobre el perfil del usuario que no encaja en los campos tradicionales. Por ejemplo, podemos almacenar una lista de hobbies, la edad, o cualquier otro detalle relevante que pueda ser útil para los usuarios o para futuras consultas. Al ser un campo JSONB, nos permite flexibilidad para agregar diferentes tipos de información sin necesidad de modificar la estructura de la tabla cada vez que queramos almacenar un nuevo tipo de dato.

INSERT INTO tipo_usuario (nombre_tipo, descripcion)
VALUES ('Administrador', 'Usuario con privilegios de administración'),
       ('Usuario Regular', 'Usuario con privilegios limitados');

select * from tipo_usuario WHERE nombre_tipo ilike '%Admin%' OR nombre_tipo ilike '%REGULAR%';

INSERT INTO usuario (nombre, apellido, email, contrasena, id_tipo_usuario,fecha_registro,estado)
VALUES ('Juan', 'Pérez', 'email@email.com', md5('contrasena123'),
        (select id_tipo_usuario from tipo_usuario where nombre_tipo like '%Administrador%'), now(), 1),
    ('Alguno', 'Sanchez', 'email2@email.com', md5('contrasena561'),
        (select id_tipo_usuario from tipo_usuario where nombre_tipo like '%Usuario Regular%'), now(), 1)
    ;

select * from usuario where id_usuario in (3,4);

INSERT INTO perfil_usuario (id_usuario, foto_perfil, biografia, telefono, sitio_web, datos_extra)
VALUES ((select id_usuario from usuario where email ilike '%email@email.com%' ), 'https://example.com/foto1.jpg', 'Biografía del usuario 1', '1234567890',
        'https://example.com/usuario1', '{"hobbies": ["futbol", "lectura"], "edad": 30}'),
    ((select id_usuario from usuario where email ilike '%email2@email.com%' ), 'https://example.com/foto1.jpg', 'Biografía del usuario 1', '1234567890',
        'https://example.com/usuario1', '{"hobbies": ["futbol", "lectura"], "edad": 30}');

select U.nombre, U.apellido, TU.nombre_tipo, PU.datos_extra
from perfil_usuario pu
LEFT JOIN USUARIO U ON PU.id_usuario = U.id_usuario
LEFT JOIN tipo_usuario tu ON U.id_tipo_usuario = tu.id_tipo_usuario
;


--
-- 2.- DATOS SEMI-ESTRUCTURADOS (PARA BIG DATA o IOT)
-- Gestionar un nuevo campo "nombre_campo" (de su propia creación) en cualquier tabla (de las existentes) que considere adecuada
-- 1.- "agregar" un campo tipo JSON o JSONB
-- 2.- Agregar un par de registros de información
-- 3.- Consultar la información agregada
-- 4.- Describir el campo y explicar su propósito
--

select * from evento;
create table evento
(
    id_evento     bigserial
        constraint pk_evento
            primary key,
    id_creador    bigint       not null
        constraint fk_evento_creador
            references usuario
            on delete cascade,
    titulo_evento varchar(200) not null,
    descripcion   text,
    fecha_hora    timestamp    not null,
    ubicacion     varchar(255) not null
);

ALTER TABLE evento
ADD COLUMN detalles_extra JSONB;

INSERT INTO evento (id_creador, titulo_evento, descripcion, fecha_hora, ubicacion, detalles_extra)
VALUES ((select * from (select id_usuario from usuario where email ilike '%email@email.com%') uiu), 'Fiesta de Cumpleaños',
        'Celebración del cumpleaños de Juan', '2024-07-15 20:00:00', 'Casa de Juan',
        '{"invitados": ["Amigo1", "Amigo2"], "tema": "Fiesta de disfraces"}'),
    ((select id_usuario from usuario where email ilike '%email@email.com%'), 'Reunión de Trabajo',
        'Reunión para discutir el proyecto X', '2024-07-20 10:00:00', 'Oficina Principal',
        '{"participantes": ["Colaborador1", "Colaborador2"], "agenda": "Discusión de avances"}');


select * from evento;


-- Este campo nos puede ayudar a guardar información adicional sobre el evento que no encaja en los campos tradicionales. Por ejemplo, podemos almacenar una lista de invitados, el tema de la fiesta, o cualquier otro detalle relevante que pueda ser útil para los usuarios o para futuras consultas. Al ser un campo JSONB, nos permite flexibilidad para agregar diferentes tipos de información sin necesidad de modificar la estructura de la tabla cada vez que queramos almacenar un nuevo tipo de dato.