START TRANSACTION;

-- добавить пользователя оборудованием

INSERT INTO equipment_owner ( equipment_id, employee_id )
    VALUES (
        (
            SELECT id
            FROM equipment
            WHERE LOWER( equipment.serial_number ) LIKE ?
        ),
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.name )  LIKE ? AND
                  LOWER( employee.phone ) LIKE ?
        )
    );

COMMIT;

