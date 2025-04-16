CREATE TABLE estados (
    id SERIAL PRIMARY KEY,
    entidad VARCHAR(50) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
	UNIQUE(entidad, nombre)
);

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE eventos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_evento TIMESTAMP NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    capacidad_maxima INTEGER NOT NULL,
    estado_id INTEGER NOT NULL REFERENCES estados(id) 
);

CREATE TABLE asientos (
    id SERIAL PRIMARY KEY,
    fila VARCHAR(10) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
	evento_id INTEGER NOT NULL REFERENCES eventos(id),
    estado_id INTEGER NOT NULL REFERENCES estados(id)
);

CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    evento_id INTEGER NOT NULL REFERENCES eventos(id),
	asiento_id INTEGER NOT NULL REFERENCES asientos(id),
    estado_id INTEGER NOT NULL REFERENCES estados(id),
	fecha_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    total DECIMAL(10,2) NOT NULL
);

