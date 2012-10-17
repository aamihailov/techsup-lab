START TRANSACTION;

-- поместить оборудование на ремонт

INSERT INTO task ( name, datetime, priority_id, client_id )
  VALUES( task_name, 
          ( SELECT NOW() ),
          priority_id, 
          (
            SELECT id
            FROM employee
            WHERE employee.login           LIKE ? AND
                  md5( employee.password ) LIKE ?
          )
        );

INSERT INTO task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
          ( 
            SELECT MAX( datetime )
            FROM task 
          ),
          (
            SELECT id
            FROM task
            WHERE task.datetime = ( 
              SELECT MAX( datetime )
              FROM task
            )  
          ),
          (
            SELECT id
            FROM employee
            WHERE employee.login           LIKE ? AND
                  md5( employee.password ) LIKE ?
          ),
          (
            SELECT id
            FROM task_state
            WHERE task_state.name = 'новая'
          )   
        );

INSERT INTO task_equipment ( task_id, equipment_id )
  VALUES( 
          (
            SELECT id
            FROM task
            WHERE task.datetime = ( 
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

INSERT INTO equipment_operation( datetime, equipment_id, eq_oper_type_id )
  VALUES(
          ( 
            SELECT MAX( datetime )
            FROM task 
          ),
          (
            SELECT id
            FROM equipment
            WHERE LOWER( equipment.serial_number ) LIKE ?
          ),
          (
            SELECT id
            FROM equipment_operation_type
            WHERE equipment_operation_type.name = 'помещение на ремонт'
          )
        );

COMMIT;

