START TRANSACTION;

-- добавить новую заявку

INSERT INTO task ( name, datetime, priority_id, client_id )
    VALUES( task_name, 
            ?,
            priority_id, 
            (
              SELECT id
              FROM employee
              WHERE employee.login           LIKE ? AND
                    md5( employee.password ) LIKE ?
            )            
           );

INSERT INTO task_equipment ( task_id, equipment_id )
    VALUES( 
           (
              SELECT id
              FROM task
              WHERE datetime = ( 
                SELECT MAX( datetime )
                FROM task
              )  
           ),
           (
              SELECT id
              FROM equipment
              WHERE LOWER( equipment.serial_number ) LIKE ?
           )
          );

COMMIT;
