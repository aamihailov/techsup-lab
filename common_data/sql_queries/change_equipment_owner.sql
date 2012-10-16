-- сменить пользователя оборудования

INSERT INTO equipment_owner( equipment_id, employee_id )
  VALUES(  
          (
            SELECT equipment.id
            FROM equipment
            WHERE equipment.serial_number = ?
          ), 
          (
            SELECT employee.id
            FROM employee
            WHERE LOWER( employee.login )    = ? AND
                  LOWER( employee.password ) = ?
          ) 
       );
