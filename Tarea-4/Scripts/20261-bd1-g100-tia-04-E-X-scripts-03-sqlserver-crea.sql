-- Creación de la base de datos
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'red_social_pascualina')
BEGIN
    CREATE DATABASE red_social_pascualina;
END
GO

USE red_social_pascualina;
GO

-- 1. TIPO_USUARIO
CREATE TABLE tipo_usuario (
    id_tipo_usuario INT IDENTITY(1,1),
    nombre_tipo NVARCHAR(50) NOT NULL,
    descripcion NVARCHAR(50),
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario)
);

-- 2. USUARIO
CREATE TABLE usuario (
    id_usuario BIGINT IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL,
    contrasena NVARCHAR(255) NOT NULL,
    id_tipo_usuario INT NOT NULL,
    fecha_registro DATETIME2 DEFAULT GETDATE() NOT NULL,
    estado TINYINT NOT NULL DEFAULT 1, -- 0: Inactivo, 1: Activo

    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT fk_usuario_tipo_usuario 
        FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario(id_tipo_usuario),
    CONSTRAINT ck_usuario_estado CHECK (estado IN (0, 1))
);

-- 3. PERFIL_USUARIO
CREATE TABLE perfil_usuario (
    id_perfil_u BIGINT IDENTITY(1,1),
    id_usuario BIGINT NOT NULL,
    foto_perfil NVARCHAR(255),
    biografia NVARCHAR(MAX),
    telefono NVARCHAR(20),
    sitio_web NVARCHAR(255),
    datos_extra NVARCHAR(MAX), -- Almacena JSON en SQL Server

    CONSTRAINT pk_perfil_usuario PRIMARY KEY (id_perfil_u),
    CONSTRAINT uk_perfil_id_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_perfil_usuario_ref_usuario 
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_perfil_datos_extra_json CHECK (ISJSON(datos_extra) > 0)
);

-- 4. SOLICITUD_AMISTAD
CREATE TABLE solicitud_amistad (
    id_solicitud BIGINT IDENTITY(1,1),
    id_emisor BIGINT NOT NULL,
    id_receptor BIGINT NOT NULL,
    estado TINYINT NOT NULL DEFAULT 0, -- 0: Pendiente, 1: Rechazada
    fecha_envio DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_solicitud PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_solicitud_emisor FOREIGN KEY (id_emisor) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_solicitud_receptor FOREIGN KEY (id_receptor) REFERENCES usuario(id_usuario),
    CONSTRAINT ck_solicitud_estado CHECK (estado IN (0, 1)),
    CONSTRAINT ck_no_automandarse_solicitud CHECK (id_emisor <> id_receptor)
);

-- 5. AMISTAD
CREATE TABLE amistad (
    id_amistad BIGINT IDENTITY(1,1),
    id_usuario1 BIGINT NOT NULL,
    id_usuario2 BIGINT NOT NULL,
    fecha_inicio DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_amistad PRIMARY KEY (id_amistad),
    CONSTRAINT fk_amistad_usuario1 FOREIGN KEY (id_usuario1) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_amistad_usuario2 FOREIGN KEY (id_usuario2) REFERENCES usuario(id_usuario),
    CONSTRAINT ck_no_auto_amistad CHECK (id_usuario1 <> id_usuario2),
    CONSTRAINT uk_amistad_unica UNIQUE (id_usuario1, id_usuario2)
);

-- 6. PUBLICACION
CREATE TABLE publicacion (
    id_publicacion BIGINT IDENTITY(1,1),
    id_usuario BIGINT NOT NULL,
    contenido_texto NVARCHAR(MAX),
    fecha_creacion DATETIME2 DEFAULT GETDATE() NOT NULL,
    estado_pub TINYINT NOT NULL DEFAULT 0, -- 0: Pública, 1: Privada

    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_usuario 
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_publicacion_estado CHECK (estado_pub IN (0, 1))
);

-- 7. PUBLICACION_MULTIMEDIA
CREATE TABLE publicacion_multimedia (
    id_multimedia BIGINT IDENTITY(1,1),
    id_publicacion BIGINT NOT NULL,
    url_archivo NVARCHAR(500) NOT NULL,
    tipo_archivo NVARCHAR(10) NOT NULL,

    CONSTRAINT pk_multimedia PRIMARY KEY (id_multimedia),
    CONSTRAINT fk_multimedia_publicacion 
        FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE
);

-- 8. COMENTARIO_PUBLICACION
CREATE TABLE comentario_publicacion (
    id_comentario BIGINT IDENTITY(1,1),
    id_publicacion BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    contenido NVARCHAR(MAX) NOT NULL,
    fecha_comentario DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_publicacion 
        FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE NO ACTION, -- Evita ciclos de cascada
    CONSTRAINT fk_comentario_usuario 
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- 9. TIPO_REACCION
CREATE TABLE tipo_reaccion (
    id_tipo_reaccion INT IDENTITY(1,1),
    nombre_reaccion NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_tipo_reaccion PRIMARY KEY (id_tipo_reaccion),
    CONSTRAINT uk_nombre_reaccion UNIQUE (nombre_reaccion)
);

-- 10. REACCION_COMENTARIO_PUBLICACION
CREATE TABLE reaccion_comentario_publicacion (
    id_reaccion_com BIGINT IDENTITY(1,1),
    id_comentario BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,

    CONSTRAINT pk_reacc_com PRIMARY KEY (id_reaccion_com),
    CONSTRAINT fk_reaccion_ref_comentario FOREIGN KEY (id_comentario) REFERENCES comentario_publicacion(id_comentario) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_ref_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_reaccion_ref_tipo FOREIGN KEY (id_tipo_reaccion) REFERENCES tipo_reaccion(id_tipo_reaccion),
    CONSTRAINT uk_usuario_reaccion_comentario UNIQUE (id_comentario, id_usuario)
);

-- 11. GRUPO
CREATE TABLE grupo (
    id_grupo BIGINT IDENTITY(1,1),
    id_creador BIGINT NOT NULL,
    nombre_grupo NVARCHAR(150) NOT NULL,
    fecha_creacion DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario)
);

-- 12. PERFIL_GRUPO
CREATE TABLE perfil_grupo (
    id_perfil_g BIGINT IDENTITY(1,1),
    id_grupo BIGINT NOT NULL,
    descripcion NVARCHAR(255),
    foto_portada NVARCHAR(255),

    CONSTRAINT pk_perfil_grupo PRIMARY KEY (id_perfil_g),
    CONSTRAINT uk_perfil_grupo_id_grupo UNIQUE (id_grupo),
    CONSTRAINT fk_perfil_grupo_ref_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
);

-- 13. SOLICITUD_GRUPO
CREATE TABLE solicitud_grupo (
    id_sol_grupo BIGINT IDENTITY(1,1),
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    estado_sol TINYINT NOT NULL DEFAULT 0, -- 0: Pendiente, 1: Aceptada, 2: Rechazada
    fecha_solicitud DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_solicitud_grupo PRIMARY KEY (id_sol_grupo),
    CONSTRAINT fk_solicitud_grupo_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_solicitud_grupo_ref FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE NO ACTION,
    CONSTRAINT ck_estado_solicitud_grupo CHECK (estado_sol IN (0, 1, 2)),
    CONSTRAINT uk_usuario_grupo_pendiente UNIQUE (id_usuario, id_grupo)
);

-- 14. MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    fecha_union DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_miembro_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_miembro_grupo_ref FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE NO ACTION
);

-- 15. EVENTO
CREATE TABLE evento (
    id_evento BIGINT IDENTITY(1,1),
    id_creador BIGINT NOT NULL,
    titulo_evento NVARCHAR(200) NOT NULL,
    descripcion NVARCHAR(MAX),
    fecha_hora DATETIME2 NOT NULL,
    ubicacion NVARCHAR(255) NOT NULL,

    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_creador FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- 16. ASISTENTE_EVENTO
CREATE TABLE asistente_evento (
    id_usuario BIGINT NOT NULL,
    id_evento BIGINT NOT NULL,
    estado_asistencia TINYINT NOT NULL DEFAULT 0, -- 0: Confirmado, 1: Interesado, 2: Cancelado
    fecha_confirmacion DATETIME2 DEFAULT GETDATE() NOT NULL,

    CONSTRAINT pk_asistente_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_asistente_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE NO ACTION,
    CONSTRAINT fk_asistente_evento_ref FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE,
    CONSTRAINT ck_estado_asistencia CHECK (estado_asistencia IN (0, 1, 2))
);
GO
