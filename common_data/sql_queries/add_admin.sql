START TRANSACTION;

-- добавить администратора

INSERT INTO admins 
    VALUES (
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.snils )  LIKE ?
        )
   );

COMMIT;

