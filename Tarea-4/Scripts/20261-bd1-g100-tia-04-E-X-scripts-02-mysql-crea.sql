-- Creación de la base de datos (Equivalente a SCHEMA en PostgreSQL)
CREATE DATABASE IF NOT EXISTS red_social_pascualina;
USE red_social_pascualina;

-- 1. TIPO_USUARIO
CREATE TABLE tipo_usuario (
    id_tipo_usuario INT AUTO_INCREMENT,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50),
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario)
) ENGINE=InnoDB COMMENT='Clasificación de los roles (ej. monitor, estudiante, docente)';

-- 2. USUARIO
CREATE TABLE usuario (
    id_usuario BIGINT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    id_tipo_usuario INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado TINYINT NOT NULL DEFAULT 1 COMMENT '0: Inactivo, 1: Activo',
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT fk_usuario_tipo_usuario
        FOREIGN KEY (id_tipo_usuario)
        REFERENCES tipo_usuario(id_tipo_usuario)
        ON DELETE RESTRICT,
    CONSTRAINT ck_usuario_estado CHECK (estado IN (0, 1))
) ENGINE=InnoDB COMMENT='Registro central de las personas';

-- 3. PERFIL_USUARIO
CREATE TABLE perfil_usuario (
    id_perfil_u BIGINT AUTO_INCREMENT,
    id_usuario BIGINT NOT NULL,
    foto_perfil VARCHAR(255),
    biografia TEXT,
    telefono VARCHAR(20),
    sitio_web VARCHAR(255),
    datos_extra JSON, -- MySQL usa JSON en lugar de JSONB
    CONSTRAINT pk_perfil_usuario PRIMARY KEY (id_perfil_u),
    CONSTRAINT uk_perfil_id_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_perfil_usuario_ref_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Datos biográficos y preferencias';

-- 4. SOLICITUD_AMISTAD
CREATE TABLE solicitud_amistad (
    id_solicitud BIGINT AUTO_INCREMENT,
    id_emisor BIGINT NOT NULL,
    id_receptor BIGINT NOT NULL,
    estado TINYINT NOT NULL DEFAULT 0 COMMENT '0: Pendiente, 1: Rechazada',
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_solicitud PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_solicitud_emisor FOREIGN KEY (id_emisor) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_solicitud_receptor FOREIGN KEY (id_receptor) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_solicitud_estado CHECK (estado IN (0, 1)),
    CONSTRAINT ck_no_automandarse_solicitud CHECK (id_emisor <> id_receptor)
) ENGINE=InnoDB;

-- 5. AMISTAD
CREATE TABLE amistad (
    id_amistad BIGINT AUTO_INCREMENT,
    id_usuario1 BIGINT NOT NULL,
    id_usuario2 BIGINT NOT NULL,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_amistad PRIMARY KEY (id_amistad),
    CONSTRAINT fk_amistad_usuario1 FOREIGN KEY (id_usuario1) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_amistad_usuario2 FOREIGN KEY (id_usuario2) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_no_auto_amistad CHECK (id_usuario1 <> id_usuario2),
    CONSTRAINT uk_amistad_unica UNIQUE (id_usuario1, id_usuario2)
) ENGINE=InnoDB;

-- 6. PUBLICACION
CREATE TABLE publicacion (
    id_publicacion BIGINT AUTO_INCREMENT,
    id_usuario BIGINT NOT NULL,
    contenido_texto TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado_pub TINYINT NOT NULL DEFAULT 0 COMMENT '0: Pública, 1: Privada',
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_publicacion_estado CHECK (estado_pub IN (0, 1))
) ENGINE=InnoDB;

-- 7. PUBLICACION_MULTIMEDIA
CREATE TABLE publicacion_multimedia (
    id_multimedia BIGINT AUTO_INCREMENT,
    id_publicacion BIGINT NOT NULL,
    url_archivo VARCHAR(500) NOT NULL,
    tipo_archivo VARCHAR(10) NOT NULL,
    CONSTRAINT pk_multimedia PRIMARY KEY (id_multimedia),
    CONSTRAINT fk_multimedia_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. COMENTARIO_PUBLICACION
CREATE TABLE comentario_publicacion (
    id_comentario BIGINT AUTO_INCREMENT,
    id_publicacion BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. TIPO_REACCION
CREATE TABLE tipo_reaccion (
    id_tipo_reaccion INT AUTO_INCREMENT,
    nombre_reaccion VARCHAR(50) NOT NULL,
    CONSTRAINT pk_tipo_reaccion PRIMARY KEY (id_tipo_reaccion),
    CONSTRAINT uk_nombre_reaccion UNIQUE (nombre_reaccion)
) ENGINE=InnoDB;

-- 10. REACCION_COMENTARIO_PUBLICACION
CREATE TABLE reaccion_comentario_publicacion (
    id_reaccion_com BIGINT AUTO_INCREMENT,
    id_comentario BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,
    CONSTRAINT pk_reacc_com PRIMARY KEY (id_reaccion_com),
    CONSTRAINT fk_reaccion_ref_comentario FOREIGN KEY (id_comentario) REFERENCES comentario_publicacion(id_comentario) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_ref_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_ref_tipo FOREIGN KEY (id_tipo_reaccion) REFERENCES tipo_reaccion(id_tipo_reaccion) ON DELETE RESTRICT,
    CONSTRAINT uk_usuario_reaccion_comentario UNIQUE (id_comentario, id_usuario)
) ENGINE=InnoDB;

-- 11. GRUPO
CREATE TABLE grupo (
    id_grupo BIGINT AUTO_INCREMENT,
    id_creador BIGINT NOT NULL,
    nombre_grupo VARCHAR(150) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 12. PERFIL_GRUPO
CREATE TABLE perfil_grupo (
    id_perfil_g BIGINT AUTO_INCREMENT,
    id_grupo BIGINT NOT NULL,
    descripcion VARCHAR(255),
    foto_portada VARCHAR(255),
    CONSTRAINT pk_perfil_grupo PRIMARY KEY (id_perfil_g),
    CONSTRAINT uk_perfil_grupo_id_grupo UNIQUE (id_grupo),
    CONSTRAINT fk_perfil_grupo_ref_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 13. ADMIN_GRUPO
CREATE TABLE admin_grupo (
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    fecha_nombramiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_admin_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_admin_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_admin_grupo_ref FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 14. SOLICITUD_GRUPO
CREATE TABLE solicitud_grupo (
    id_sol_grupo BIGINT AUTO_INCREMENT,
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    estado_sol TINYINT NOT NULL DEFAULT 0 COMMENT '0: Pendiente, 1: Aceptada, 2: Rechazada',
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_solicitud_grupo PRIMARY KEY (id_sol_grupo),
    CONSTRAINT fk_solicitud_grupo_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_solicitud_grupo_ref FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    CONSTRAINT ck_estado_solicitud_grupo CHECK (estado_sol IN (0, 1, 2)),
    CONSTRAINT uk_usuario_grupo_pendiente UNIQUE (id_usuario, id_grupo)
) ENGINE=InnoDB;

-- 15. MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (
    id_usuario BIGINT NOT NULL,
    id_grupo BIGINT NOT NULL,
    fecha_union TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_miembro_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_miembro_grupo_ref FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 16. PUBLICACION_GRUPO
CREATE TABLE publicacion_grupo (
    id_pub_grupo BIGINT AUTO_INCREMENT,
    id_grupo BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    contenido_texto TEXT,
    fecha_pub_gr TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_publicacion_grupo PRIMARY KEY (id_pub_grupo),
    CONSTRAINT fk_pub_grupo_ref_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_pub_grupo_ref_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 17. PUB_GRUPO_MULTIMEDIA
CREATE TABLE pub_grupo_multimedia (
    id_multimedia_gr BIGINT AUTO_INCREMENT,
    id_pub_grupo BIGINT NOT NULL,
    url_archivo VARCHAR(500) NOT NULL,
    CONSTRAINT pk_pub_grp_multimedia PRIMARY KEY (id_multimedia_gr),
    CONSTRAINT fk_multimedia_pub_grupo FOREIGN KEY (id_pub_grupo) REFERENCES publicacion_grupo(id_pub_grupo) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 18. COMENTARIO_GRUPO
CREATE TABLE comentario_grupo (
    id_com_grupo BIGINT AUTO_INCREMENT,
    id_pub_grupo BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    texto_comentario TEXT NOT NULL,
    fecha_com_gr TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_comentario_grupo PRIMARY KEY (id_com_grupo),
    CONSTRAINT fk_com_grupo_ref_pub FOREIGN KEY (id_pub_grupo) REFERENCES publicacion_grupo(id_pub_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_com_grupo_ref_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 19. REACCION_COMENTARIO_GRUPO
CREATE TABLE reaccion_comentario_grupo (
    id_reacc_com_gr BIGINT AUTO_INCREMENT,
    id_comentario_grupo BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,
    CONSTRAINT pk_reacc_com_gr PRIMARY KEY (id_reacc_com_gr),
    CONSTRAINT fk_reaccion_grp_ref_comentario FOREIGN KEY (id_comentario_grupo) REFERENCES comentario_grupo(id_com_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_grp_ref_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_grp_ref_tipo FOREIGN KEY (id_tipo_reaccion) REFERENCES tipo_reaccion(id_tipo_reaccion) ON DELETE RESTRICT,
    CONSTRAINT uk_usuario_reaccion_com_grupo UNIQUE (id_comentario_grupo, id_usuario)
) ENGINE=InnoDB;

-- 20. EVENTO
CREATE TABLE evento (
    id_evento BIGINT AUTO_INCREMENT,
    id_creador BIGINT NOT NULL,
    titulo_evento VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_hora DATETIME NOT NULL, -- DATETIME suele ser preferible para fechas fijas de eventos
    ubicacion VARCHAR(255) NOT NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_creador FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 21. ASISTENTE_EVENTO
CREATE TABLE asistente_evento (
    id_usuario BIGINT NOT NULL,
    id_evento BIGINT NOT NULL,
    estado_asistencia TINYINT NOT NULL DEFAULT 0 COMMENT '0: Confirmado, 1: Interesado, 2: Cancelado',
    fecha_confirmacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_asistente_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_asistente_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_asistente_evento_ref FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE,
    CONSTRAINT ck_estado_asistencia CHECK (estado_asistencia IN (0, 1, 2))
) ENGINE=InnoDB;

-- 22. REACCION_EVENTO
CREATE TABLE reaccion_evento (
    id_reacc_ev BIGINT AUTO_INCREMENT,
    id_evento BIGINT NOT NULL,
    id_usuario BIGINT NOT NULL,
    id_tipo_reaccion INT NOT NULL,
    CONSTRAINT pk_reacc_ev PRIMARY KEY (id_reacc_ev),
    CONSTRAINT fk_reacc_ev_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE,
    CONSTRAINT fk_reacc_ev_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_reacc_ev_tipo FOREIGN KEY (id_tipo_reaccion) REFERENCES tipo_reaccion(id_tipo_reaccion) ON DELETE RESTRICT,
    CONSTRAINT uk_usuario_reaccion_evento UNIQUE (id_evento, id_usuario)
) ENGINE=InnoDB;