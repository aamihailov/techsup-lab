START TRANSACTION;

-- добавить техника

INSERT INTO technics
    VALUES (
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.snils )  LIKE ?
        )
   );

COMMIT;

