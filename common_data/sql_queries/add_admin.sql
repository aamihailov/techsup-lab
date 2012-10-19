START TRANSACTION;

-- добавить администратора

INSERT INTO admins 
    VALUES (
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.name )  LIKE ? AND
                  LOWER( employee.phone ) LIKE ?
        )
   );

COMMIT;

