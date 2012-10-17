START TRANSACTION; 

-- сменить пользователя оборудования

INSERT INTO equipment_owner( equipment_id, employee_id )
  VALUES(  
          (
            SELECT equipment.id
            FROM equipment
            WHERE LOWER( equipment.serial_number ) = ?
          ), 
          (
            SELECT employee.id
            FROM employee
            WHERE employee.login           = ? AND
                  md5( employee.password ) = ?
          ) 
       );

COMMIT;

