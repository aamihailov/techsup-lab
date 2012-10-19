START TRANSACTION;

-- добавить техника

INSERT INTO technics
    VALUES (
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.name )  LIKE ? AND
                  LOWER( employee.phone ) LIKE ?
        )
   );

COMMIT;

