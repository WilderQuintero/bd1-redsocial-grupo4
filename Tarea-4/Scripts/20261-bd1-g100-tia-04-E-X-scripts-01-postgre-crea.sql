CREATE SCHEMA IF NOT EXISTS red_social_pascualina;
SET search_path TO red_social_pascualina, public;

CREATE TABLE tipo_usuario (
    id_tipo_usuario SERIAL,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50),
    -- Definición de llaves
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario)
);

COMMENT ON TABLE tipo_usuario IS 'Clasificación de los roles (ej. monitor, estudiante, docente) para control de permisos.';

CREATE TABLE usuario (
    id_usuario BIGSERIAL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    id_tipo_usuario INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado SMALLINT NOT NULL DEFAULT 1,

    -- Definición de llaves
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email UNIQUE (email),

    -- Relación con la tabla tipo_usuario
    CONSTRAINT fk_usuario_tipo_usuario
        FOREIGN KEY (id_tipo_usuario)
        REFERENCES tipo_usuario(id_tipo_usuario)
        ON DELETE RESTRICT, -- Evita borrar un rol si tiene usuarios asociados

    CONSTRAINT ck_usuario_estado CHECK (estado IN (0, 1))
);

COMMENT ON TABLE usuario IS 'Registro central de las personas que acceden a la plataforma estudiantil.';
COMMENT ON COLUMN usuario.estado IS '0: Inactivo, 1: Activo';


CREATE TABLE perfil_usuario (
    id_perfil_u BIGSERIAL,
    id_usuario BIGINT NOT NULL,
    foto_perfil VARCHAR(255),
    biografia TEXT,
    telefono VARCHAR(20),
    sitio_web VARCHAR(255),
    datos_extra JSONB,

    -- Definición de llaves
    CONSTRAINT pk_perfil_usuario PRIMARY KEY (id_perfil_u),

    -- Relación 1:1 con la tabla usuario
    CONSTRAINT uk_perfil_id_usuario UNIQUE (id_usuario), -- Garantiza que un usuario solo tenga UN perfil
    CONSTRAINT fk_perfil_usuario_ref_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE -- Si se borra el usuario, se borra su perfil automáticamente
);

-- Comentarios para documentación
COMMENT ON TABLE perfil_usuario IS 'Almacena datos biográficos, fotos de perfil, redes sociales y preferencias del estudiante.';
COMMENT ON COLUMN perfil_usuario.id_usuario IS 'Referencia única al usuario dueño del perfil (Relación 1:1).';


CREATE TABLE solicitud_amistad (
    id_solicitud BIGSERIAL,
    id_emisor BIGINT NOT NULL,
    id_receptor BIGINT NOT NULL,
    estado SMALLINT NOT NULL DEFAULT 0, -- 0: Pendiente, 1: Rechazada (o aceptada según lógica)
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_solicitud PRIMARY KEY (id_solicitud),

    -- Relación con la tabla usuario (Emisor)
    CONSTRAINT fk_solicitud_emisor
        FOREIGN KEY (id_emisor)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con la tabla usuario (Receptor)
    CONSTRAINT fk_solicitud_receptor
        FOREIGN KEY (id_receptor)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Restricciones de integridad
    CONSTRAINT ck_solicitud_estado CHECK (estado IN (0, 1)),
    CONSTRAINT ck_no_automandarse_solicitud CHECK (id_emisor <> id_receptor)
);

-- Comentarios para documentación
COMMENT ON TABLE solicitud_amistad IS 'Registro de las invitaciones enviadas para conectar con otros estudiantes.';
COMMENT ON COLUMN solicitud_amistad.estado IS '0: Pendiente, 1: Rechazada';



CREATE TABLE amistad (
    id_amistad BIGSERIAL,
    id_usuario1 BIGINT NOT NULL,
    id_usuario2 BIGINT NOT NULL,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_amistad PRIMARY KEY (id_amistad),

    -- Relación con el primer usuario
    CONSTRAINT fk_amistad_usuario1
        FOREIGN KEY (id_usuario1)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con el segundo usuario
    CONSTRAINT fk_amistad_usuario2
        FOREIGN KEY (id_usuario2)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Restricciones de integridad
    CONSTRAINT ck_no_auto_amistad CHECK (id_usuario1 <> id_usuario2),

    -- Evita duplicar la misma relación (A con B y B con A)
    CONSTRAINT uk_amistad_unica UNIQUE (id_usuario1, id_usuario2)
);

-- Comentarios para documentación
COMMENT ON TABLE amistad IS 'Almacén de las conexiones confirmadas y vigentes entre usuarios.';


CREATE TABLE publicacion (
    id_publicacion BIGSERIAL,
    id_usuario BIGINT NOT NULL,
    contenido_texto TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado_pub SMALLINT NOT NULL DEFAULT 0, -- 0: Pública, 1: Privada

    -- Definición de llaves
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),

    -- Relación con el autor (Usuario)
    CONSTRAINT fk_publicacion_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Restricción para asegurar que el estado sea válido
    CONSTRAINT ck_publicacion_estado CHECK (estado_pub IN (0, 1))
);

-- Comentarios para documentación
COMMENT ON TABLE publicacion IS 'Contenido generado por los usuarios para ser compartido en su perfil general.';
COMMENT ON COLUMN publicacion.estado_pub IS '0: Pública, 1: Privada';


CREATE TABLE publicacion_multimedia (
    id_multimedia BIGSERIAL,
    id_publicacion BIGINT NOT NULL,
    url_archivo VARCHAR(500) NOT NULL,
    tipo_archivo VARCHAR(10) NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_multimedia PRIMARY KEY (id_multimedia),

    -- Relación con la publicación principal
    CONSTRAINT fk_multimedia_publicacion
        FOREIGN KEY (id_publicacion)
        REFERENCES publicacion(id_publicacion)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE publicacion_multimedia IS 'Permite que una publicación tenga múltiples imágenes o archivos asociados de forma atómica.';
COMMENT ON COLUMN publicacion_multimedia.tipo_archivo IS 'Almacena la extensión o formato del archivo (ej. JPG, MP4).';

CREATE TABLE comentario_publicacion (
    id_comentario BIGSERIAL,
    id_publicacion BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),

    -- Relación con la publicación (si se borra el post, se borran los comentarios)
    CONSTRAINT fk_comentario_publicacion
        FOREIGN KEY (id_publicacion)
        REFERENCES publicacion(id_publicacion)
        ON DELETE CASCADE,

    -- Relación con el autor del comentario
    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE comentario_publicacion IS 'Almacena los textos y respuestas que los usuarios escriben en una publicación general.';

-- Creación de la tabla tipo_reaccion
CREATE TABLE tipo_reaccion (
    id_tipo_reaccion SERIAL,
    nombre_reaccion VARCHAR(50) NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_tipo_reaccion PRIMARY KEY (id_tipo_reaccion),
    CONSTRAINT uk_nombre_reaccion UNIQUE (nombre_reaccion)
);

-- Comentarios para documentación
COMMENT ON TABLE tipo_reaccion IS 'Catálogo de las posibles interacciones (likes, apoyos, etc.).';


CREATE TABLE reaccion_comentario_publicacion (
    id_reaccion_com BIGSERIAL,
    id_comentario BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_reaccion_com PRIMARY KEY (id_reaccion_com),

    -- Relación con el comentario (Si se borra el comentario, se borran sus reacciones)
    CONSTRAINT fk_reaccion_ref_comentario
        FOREIGN KEY (id_comentario)
        REFERENCES comentario_publicacion(id_comentario)
        ON DELETE CASCADE,

    -- Relación con el usuario (Si se borra el usuario, se borran sus reacciones)
    CONSTRAINT fk_reaccion_ref_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con el catálogo de tipos de reacción
    CONSTRAINT fk_reaccion_ref_tipo
        FOREIGN KEY (id_tipo_reaccion)
        REFERENCES tipo_reaccion(id_tipo_reaccion)
        ON DELETE RESTRICT,

    -- Restricción para evitar que un usuario reaccione varias veces al mismo comentario
    CONSTRAINT uk_usuario_reaccion_comentario UNIQUE (id_comentario, id_usuario)
);

-- Comentarios para documentación
COMMENT ON TABLE reaccion_comentario_publicacion IS 'Registra las interacciones (likes, apoyos) aplicadas específicamente a los comentarios.';


CREATE TABLE grupo (
    id_grupo BIGSERIAL,
    id_creador BIGINT NOT NULL,
    nombre_grupo VARCHAR(150) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),

    -- Relación con el usuario creador
    CONSTRAINT fk_grupo_creador
        FOREIGN KEY (id_creador)
        REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT -- Evita borrar al creador si el grupo sigue activo
);

-- Comentarios para documentación
COMMENT ON TABLE grupo IS 'Registra las comunidades o grupos de estudio creados por los usuarios.';


CREATE TABLE perfil_grupo (
    id_perfil_g BIGSERIAL,
    id_grupo BIGINT NOT NULL,
    descripcion varchar(255), -- Para reglas, misión y visión sin límite de caracteres
    foto_portada VARCHAR(255),

    -- Definición de llaves
    CONSTRAINT pk_perfil_grupo PRIMARY KEY (id_perfil_g),

    -- Relación 1:1 con la tabla grupo
    CONSTRAINT uk_perfil_grupo_id_grupo UNIQUE (id_grupo), -- Un grupo solo tiene un perfil descriptivo
    CONSTRAINT fk_perfil_grupo_ref_grupo
        FOREIGN KEY (id_grupo)
        REFERENCES grupo(id_grupo)
        ON DELETE CASCADE -- Si el grupo se elimina, su perfil también
);

-- Comentarios para documentación
COMMENT ON TABLE perfil_grupo IS 'Contiene la descripción detallada, reglas e imagen de portada del grupo.';

CREATE TABLE admin_grupo (
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    fecha_nombramiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de Llave Primaria Compuesta
    CONSTRAINT pk_admin_grupo PRIMARY KEY (id_usuario, id_grupo),

    -- Relación con la tabla usuario
    CONSTRAINT fk_admin_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con la tabla grupo
    CONSTRAINT fk_admin_grupo_ref
        FOREIGN KEY (id_grupo)
        REFERENCES grupo(id_grupo)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE admin_grupo IS 'Registro de los usuarios que tienen facultades de moderación en un grupo.';


CREATE TABLE solicitud_grupo (
    id_sol_grupo BIGSERIAL,
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    estado_sol SMALLINT NOT NULL DEFAULT 0, -- 0: Pendiente, 1: Aceptada, 2: Rechazada
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_solicitud_grupo PRIMARY KEY (id_sol_grupo),

    -- Relación con el usuario que solicita unirse
    CONSTRAINT fk_solicitud_grupo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con el grupo destino
    CONSTRAINT fk_solicitud_grupo_ref
        FOREIGN KEY (id_grupo)
        REFERENCES grupo(id_grupo)
        ON DELETE CASCADE,

    -- Restricción para asegurar estados válidos
    CONSTRAINT ck_estado_solicitud_grupo CHECK (estado_sol IN (0, 1, 2)),

    -- Evita que el usuario mande múltiples solicitudes pendientes al mismo grupo
    CONSTRAINT uk_usuario_grupo_pendiente UNIQUE (id_usuario, id_grupo)
);

-- Comentarios para documentación
COMMENT ON TABLE solicitud_grupo IS 'Control de las peticiones de ingreso a grupos que requieren aprobación.';
COMMENT ON COLUMN solicitud_grupo.estado_sol IS '0: Pendiente, 1: Aceptada, 2: Rechazada';


CREATE TABLE miembro_grupo (
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    fecha_union TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de Llave Primaria Compuesta
    -- Esto garantiza que no haya registros duplicados para la misma relación usuario-grupo
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),

    -- Relación con el usuario
    CONSTRAINT fk_miembro_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con el grupo
    CONSTRAINT fk_miembro_grupo_ref
        FOREIGN KEY (id_grupo)
        REFERENCES grupo(id_grupo)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE miembro_grupo IS 'Listado de integrantes que pertenecen a cada comunidad o grupo.';

CREATE TABLE publicacion_grupo (
    id_pub_grupo BIGSERIAL,
    id_grupo BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    contenido_texto TEXT,
    fecha_pub_gr TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_publicacion_grupo PRIMARY KEY (id_pub_grupo),

    -- Relación con el grupo (si el grupo se elimina, sus posts también)
    CONSTRAINT fk_pub_grupo_ref_grupo
        FOREIGN KEY (id_grupo)
        REFERENCES grupo(id_grupo)
        ON DELETE CASCADE,

    -- Relación con el autor (si el usuario se elimina, sus posts en grupos también)
    CONSTRAINT fk_pub_grupo_ref_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE publicacion_grupo IS 'Contenido y mensajes compartidos exclusivamente dentro de un grupo académico.';

CREATE TABLE pub_grupo_multimedia (
    id_multimedia_gr BIGSERIAL,
    id_pub_grupo BIGINT NOT NULL,
    url_archivo VARCHAR(500) NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_pub_grp_multimedia PRIMARY KEY (id_multimedia_gr),

    -- Relación con la publicación del grupo
    CONSTRAINT fk_multimedia_pub_grupo
        FOREIGN KEY (id_pub_grupo)
        REFERENCES publicacion_grupo(id_pub_grupo)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE pub_grupo_multimedia IS 'Almacena de forma individual cada archivo asociado a un post de grupo.';
COMMENT ON COLUMN pub_grupo_multimedia.url_archivo IS 'Ruta completa o URL del recurso (S3, Cloudinary, servidor local).';

CREATE TABLE comentario_grupo (
    id_com_grupo BIGSERIAL,
    id_pub_grupo BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    texto_comentario TEXT NOT NULL,
    fecha_com_gr TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_comentario_grupo PRIMARY KEY (id_com_grupo),

    -- Relación con la publicación del grupo
    CONSTRAINT fk_com_grupo_ref_pub
        FOREIGN KEY (id_pub_grupo)
        REFERENCES publicacion_grupo(id_pub_grupo)
        ON DELETE CASCADE,

    -- Relación con el autor del comentario
    CONSTRAINT fk_com_grupo_ref_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

-- Comentarios para documentación
COMMENT ON TABLE comentario_grupo IS 'Almacena las opiniones y mensajes de respuesta dentro de las publicaciones de un grupo.';

CREATE TABLE reaccion_comentario_grupo (
    id_reacc_com_gr BIGSERIAL,
    id_comentario_grupo BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,

    -- Definición de llaves
    CONSTRAINT pk_reacc_com_gr PRIMARY KEY (id_reacc_com_gr),

    -- Relación con el comentario del grupo
    CONSTRAINT fk_reaccion_grp_ref_comentario
        FOREIGN KEY (id_comentario_grupo)
        REFERENCES comentario_grupo(id_com_grupo)
        ON DELETE CASCADE,

    -- Relación con el usuario que reacciona
    CONSTRAINT fk_reaccion_grp_ref_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con el catálogo maestro de tipos de reacción (Tabla 10)
    CONSTRAINT fk_reaccion_grp_ref_tipo
        FOREIGN KEY (id_tipo_reaccion)
        REFERENCES tipo_reaccion(id_tipo_reaccion)
        ON DELETE RESTRICT,

    -- Restricción para que un usuario solo pueda reaccionar una vez a un mismo comentario
    CONSTRAINT uk_usuario_reaccion_com_grupo UNIQUE (id_comentario_grupo, id_usuario)
);

-- Comentarios para documentación
COMMENT ON TABLE reaccion_comentario_grupo IS 'Registra las interacciones sociales sobre los comentarios realizados dentro de un grupo.';

CREATE TABLE evento (
    id_evento BIGSERIAL,
    id_creador BIGINT NOT NULL,
    titulo_evento VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_hora TIMESTAMP NOT NULL,
    ubicacion VARCHAR(255) NOT NULL, -- Puede ser URL o salón físico

    CONSTRAINT pk_evento PRIMARY KEY (id_evento),

    -- Relación con el organizador
    CONSTRAINT fk_evento_creador
        FOREIGN KEY (id_creador)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

COMMENT ON TABLE evento IS 'Información sobre actividades, tutorías o reuniones programadas.';

CREATE TABLE asistente_evento (
    id_usuario BIGINT NOT NULL,
    id_evento BIGINT NOT NULL,
    estado_asistencia SMALLINT NOT NULL DEFAULT 0, -- 0: Confirmado, 1: Interesado, 2: Cancelado
    fecha_confirmacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- Llave primaria compuesta para evitar duplicidad de asistencia
    CONSTRAINT pk_asistente_evento PRIMARY KEY (id_usuario, id_evento),

    CONSTRAINT fk_asistente_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_asistente_evento_ref
        FOREIGN KEY (id_evento)
        REFERENCES evento(id_evento)
        ON DELETE CASCADE,

    -- Restricción de estados válidos
    CONSTRAINT ck_estado_asistencia CHECK (estado_asistencia IN (0, 1, 2))
);

COMMENT ON TABLE asistente_evento IS 'Registro de quórum o personas interesadas en participar.';
COMMENT ON COLUMN asistente_evento.estado_asistencia IS '0: Confirmado, 1: Interesado, 2: Cancelado';

CREATE TABLE reaccion_evento (
    id_reacc_ev BIGSERIAL,
    id_evento BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,

    CONSTRAINT pk_reacc_ev PRIMARY KEY (id_reacc_ev),

    CONSTRAINT fk_reacc_ev_evento
        FOREIGN KEY (id_evento)
        REFERENCES evento(id_evento)
        ON DELETE CASCADE,

    CONSTRAINT fk_reacc_ev_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    -- Relación con el catálogo maestro (Tabla 10)
    CONSTRAINT fk_reacc_ev_tipo
        FOREIGN KEY (id_tipo_reaccion)
        REFERENCES tipo_reaccion(id_tipo_reaccion)
        ON DELETE RESTRICT,

    -- Un usuario solo reacciona una vez al evento
    CONSTRAINT uk_usuario_reaccion_evento UNIQUE (id_evento, id_usuario)
);

COMMENT ON TABLE reaccion_evento IS 'Interacciones rápidas de los usuarios sobre la información de un evento.';
