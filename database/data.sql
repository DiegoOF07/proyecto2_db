INSERT INTO estados (entidad, nombre) VALUES
('evento', 'activo'),
('evento', 'cancelado'), 
('evento', 'terminado'),
('asiento', 'disponible'), 
('asiento', 'reservado'), 
('asiento', 'ocupado'),
('reserva', 'pendiente'), 
('reserva', 'confirmada'), 
('reserva', 'cancelada'), 
('reserva', 'expirada');

INSERT INTO usuarios (nombre, email) VALUES
('Juan Pérez', 'juan.perez@email.com'),
('María García', 'maria.garcia@email.com'),
('Carlos López', 'carlos.lopez@email.com'),
('Ana Martínez', 'ana.martinez@email.com'),
('Luis Rodríguez', 'luis.rodriguez@email.com'),
('Sofía Hernández', 'sofia.hernandez@email.com'),
('Pedro Díaz', 'pedro.diaz@email.com'),
('Laura Gómez', 'laura.gomez@email.com'),
('Jorge Ruiz', 'jorge.ruiz@email.com'),
('Mónica Castro', 'monica.castro@email.com');

INSERT INTO eventos (nombre, descripcion, fecha_evento, ubicacion, capacidad_maxima, estado_id) VALUES
('Concierto de Rock', 'Concierto de bandas locales de rock', '2023-12-15 20:00:00', 'Estadio Nacional', 5000, 1),
('Obra de Teatro: Hamlet', 'Clásico de Shakespeare', '2023-11-20 19:30:00', 'Teatro Municipal', 300, 1),
('Conferencia de Tecnología', 'Evento sobre las últimas tendencias tech', '2023-10-10 09:00:00', 'Centro de Convenciones', 200, 1),
('Partido de Fútbol: Local vs Visitante', 'Partido de la liga nacional', '2023-11-05 16:00:00', 'Estadio Ciudad', 25000, 1),
('Festival de Cine', 'Proyección de películas independientes', '2023-12-01 18:00:00', 'Cine Arte', 150, 1),
('Concierto de Jazz', 'Noche de jazz con artistas internacionales', '2024-01-20 21:00:00', 'Club de Jazz', 400, 1);

-- Asientos para evento 1 
INSERT INTO asientos (evento_id, fila, numero, tipo, precio, estado_id) VALUES
(1, 'A', '1', 'VIP', 150.00, 4),
(1, 'A', '2', 'VIP', 150.00, 4),
(1, 'A', '3', 'VIP', 150.00, 4),
(1, 'B', '1', 'Preferencial', 100.00, 4),
(1, 'B', '2', 'Preferencial', 100.00, 4),
(1, 'C', '1', 'General', 50.00, 4),
(1, 'C', '2', 'General', 50.00, 4),
(1, 'C', '3', 'General', 50.00, 4),
(1, 'C', '4', 'General', 50.00, 4),
(1, 'D', '1', 'General', 50.00, 4);

-- Asientos para evento 2
INSERT INTO asientos (evento_id, fila, numero, tipo, precio, estado_id) VALUES
(2, '1', '1', 'Platea', 80.00, 4),
(2, '1', '2', 'Platea', 80.00, 4),
(2, '2', '1', 'Balcón', 50.00, 4),
(2, '2', '2', 'Balcón', 50.00, 4);

-- Asientos para evento 3
INSERT INTO asientos (evento_id, fila, numero, tipo, precio, estado_id) VALUES
(3, 'E', '1', 'General', 30.00, 4),
(3, 'E', '2', 'General', 30.00, 4),
(3, 'E', '3', 'General', 30.00, 4);

-- Reserva asiento VIP en evento 1
INSERT INTO reservas (usuario_id, evento_id, asiento_id, estado_id, fecha_expiracion, total) VALUES
(1, 1, 1, 8, '2023-12-14 23:59:59', 150.00);
UPDATE asientos SET estado_id = 6 WHERE id = 1;

-- Reserva asiento en evento 2
INSERT INTO reservas (usuario_id, evento_id, asiento_id, estado_id, fecha_expiracion, total) VALUES
(2, 2, 11, 8, '2023-11-19 23:59:59', 80.00);
UPDATE asientos SET estado_id = 6 WHERE id = 11;

-- Reserva asiento en evento 3
INSERT INTO reservas (usuario_id, evento_id, asiento_id, estado_id, fecha_expiracion, total) VALUES
(3, 3, 15, 7, '2023-10-09 23:59:59', 30.00);
UPDATE asientos SET estado_id = 5 WHERE id = 15;

-- Reserva dos asientos en evento 1
INSERT INTO reservas (usuario_id, evento_id, asiento_id, estado_id, fecha_expiracion, total) VALUES
(4, 1, 2, 8, '2023-12-14 23:59:59', 150.00),
(4, 1, 3, 8, '2023-12-14 23:59:59', 150.00);
UPDATE asientos SET estado_id = 6 WHERE id IN (2, 3);

-- Reserva cancelada
INSERT INTO reservas (usuario_id, evento_id, asiento_id, estado_id, fecha_expiracion, total) VALUES
(5, 1, 4, 9, '2023-12-10 23:59:59', 100.00);
UPDATE asientos SET estado_id = 4 WHERE id = 4;


