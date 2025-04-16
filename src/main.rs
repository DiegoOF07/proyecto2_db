use std::time::{Instant};
use tokio::task;
use tokio_postgres::{NoTls, Error};
use rand::Rng;
use chrono::Utc;

#[tokio::main]
async fn main() -> Result<(), Error> {
    let conn_string = "host=postgres_db user=postgres password=secret dbname=Proyecto2_DB";

    test_isolation_level("READ COMMITTED", 5, conn_string).await?;
    test_isolation_level("READ COMMITTED", 10, conn_string).await?;
    test_isolation_level("REPEATABLE READ", 5, conn_string).await?;
    test_isolation_level("REPEATABLE READ", 10, conn_string).await?;
    test_isolation_level("SERIALIZABLE", 5, conn_string).await?;
    test_isolation_level("SERIALIZABLE", 10, conn_string).await?;
    test_isolation_level("SERIALIZABLE", 20, conn_string).await?;
    test_isolation_level("SERIALIZABLE", 30, conn_string).await?;

    Ok(())
}

async fn test_isolation_level(level: &str, num_users: usize, conn_string: &str) -> Result<(), Error> {
    println!("\nProbando nivel {} con {} usuarios concurrentes...", level, num_users);

    let start_time = Instant::now();
    let mut handles = vec![];

    for i in 0..num_users {
        let conn_string = conn_string.to_string();
        let level = level.to_string();
        
        let handle = task::spawn(async move {
            match simulate_user_behavior(&conn_string, &level, i).await {
                Ok(_) => println!("Usuario {} completado", i),
                Err(e) => eprintln!("Error en usuario {}: {}", i, e),
            }
        });
        
        handles.push(handle);
    }

    // Esperar a que todas las tareas terminen
    for handle in handles {
        if let Err(e) = handle.await {
            eprintln!("Error en tarea: {}", e);
        }
    }

    let duration = start_time.elapsed();
    println!("Prueba completada en {:?}", duration);

    Ok(())
}

async fn simulate_user_behavior(conn_string: &str, isolation_level: &str, user_id: usize) -> Result<(), Error> {
    // Conectar a la base de datos
    let (mut client, connection) = tokio_postgres::connect(conn_string, NoTls).await?;

    // Ejecutar la conexión en segundo plano
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("Error de conexión: {}", e);
        }
    });

    // Configurar nivel de aislamiento
    client.execute(&format!("SET TRANSACTION ISOLATION LEVEL {}", isolation_level), &[]).await?;

    // Comportamiento aleatorio del usuario (reserva, consulta o cancelación)
    let action = rand::thread_rng().gen_range(0..3);

    match action {
        0 => make_reservation(&mut client, user_id).await?,
        1 => query_events(&mut client, user_id).await?,
        2 => cancel_reservation(&mut client, user_id).await?,
        _ => unreachable!(),
    }

    Ok(())
}

async fn make_reservation(client: &mut tokio_postgres::Client, user_id: usize) -> Result<(), Error> {
    let transaction = client.transaction().await?;

    // 1. Consultar eventos activos
    let rows = transaction.query(
        "SELECT id, nombre FROM eventos WHERE estado_id = 1 LIMIT 5", 
        &[]
    ).await?;

    if rows.is_empty() {
        return Ok(());
    }

    let event_id: i32 = rows[0].get(0);
    let event_name: String = rows[0].get(1);

    // 2. Buscar asientos disponibles
    let seat_rows = transaction.query(
        "SELECT id, fila, numero, precio FROM asientos 
         WHERE evento_id = $1 AND estado_id = 4 
         LIMIT 1 FOR UPDATE", 
        &[&event_id]
    ).await?;

    if seat_rows.is_empty() {
        println!("Usuario {}: No hay asientos disponibles para {}", user_id, event_name);
        return Ok(());
    }

    let seat_id: i32 = seat_rows[0].get(0);
    let seat_row: String = seat_rows[0].get(1);
    let seat_number: String = seat_rows[0].get(2);
    let price: f64 = seat_rows[0].get(3);

    // 3. Crear reserva
    transaction.execute(
        "INSERT INTO reservas (...) VALUES ($1, $2, $3, 7, $4, $5)",
        &[&(user_id as i32), &event_id, &seat_id, 
         &(Utc::now() + chrono::Duration::hours(24)).naive_utc(), &price]
    ).await?;

    // 4. Actualizar estado del asiento
    transaction.execute(
        "UPDATE asientos SET estado_id = 5 WHERE id = $1",
        &[&seat_id]
    ).await?;

    // Confirmar transacción
    match transaction.commit().await {
        Ok(_) => println!("Usuario {}: Reserva exitosa para {} - Asiento {}{}", 
                         user_id, event_name, seat_row, seat_number),
        Err(e) => println!("Usuario {}: Error en reserva - {}", user_id, e),
    }

    Ok(())
}

async fn query_events(client: &mut tokio_postgres::Client, user_id: usize) -> Result<(), Error> {
    let transaction = client.transaction().await?;

    // Consultar eventos y asientos disponibles
    let rows = transaction.query(
        "SELECT e.id, e.nombre, COUNT(a.id) as asientos_disponibles
         FROM eventos e
         LEFT JOIN asientos a ON e.id = a.evento_id AND a.estado_id = 4
         WHERE e.estado_id = 1
         GROUP BY e.id, e.nombre", 
        &[]
    ).await?;

    println!("Usuario {}: Consulta de eventos", user_id);
    for row in rows {
        let id: i32 = row.get(0);
        let nombre: String = row.get(1);
        let disponibles: i64 = row.get(2);
        println!("  Evento {}: {} ({} disponibles)", id, nombre, disponibles);
    }

    transaction.commit().await?;
    Ok(())
}

async fn cancel_reservation(client: &mut tokio_postgres::Client, user_id: usize) -> Result<(), Error> {
    let transaction = client.transaction().await?;

    // Buscar reservas pendientes del usuario
    let rows = transaction.query(
        "SELECT r.id, e.nombre, a.fila, a.numero 
         FROM reservas r
         JOIN eventos e ON r.evento_id = e.id
         JOIN asientos a ON r.asiento_id = a.id
         WHERE r.usuario_id = $1 AND r.estado_id = 7
         LIMIT 1", 
        &[&(user_id as i32)]
    ).await?;

    if rows.is_empty() {
        println!("Usuario {}: No tiene reservas pendientes", user_id);
        return Ok(());
    }

    let reserva_id: i32 = rows[0].get(0);
    let event_name: String = rows[0].get(1);
    let seat_row: String = rows[0].get(2);
    let seat_number: String = rows[0].get(3);

    // Cancelar reserva
    transaction.execute(
        "UPDATE reservas SET estado_id = 9 WHERE id = $1",
        &[&reserva_id]
    ).await?;

    // Liberar asiento
    transaction.execute(
        "UPDATE asientos SET estado_id = 4
         WHERE id IN (SELECT asiento_id FROM reservas WHERE id = $1)",
        &[&reserva_id]
    ).await?;

    match transaction.commit().await {
        Ok(_) => println!("Usuario {}: Cancelada reserva para {} - Asiento {}{}", 
                         user_id, event_name, seat_row, seat_number),
        Err(e) => println!("Usuario {}: Error al cancelar - {}", user_id, e),
    }

    Ok(())
}