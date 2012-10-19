DELIMITER $$

DROP PROCEDURE IF EXISTS change_equipment_owner$$
CREATE PROCEDURE change_equipment_owner (
                                         IN serial_number VARCHAR(128), 
                                         IN login VARCHAR(128), 
                                         IN password VARCHAR(128)
                                        )
BEGIN

START TRANSACTION;

-- сменить пользователя оборудования

INSERT INTO equipment_owner( equipment_id, employee_id )
    VALUES(  
            (
                SELECT equipment.id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE serial_number
            ), 
            (
                SELECT employee.id
                FROM employee
                WHERE employee.login    LIKE login AND
                      employee.password LIKE password
            ) 
        );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DELIMITER ;

