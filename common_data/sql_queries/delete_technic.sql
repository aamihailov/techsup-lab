START TRANSACTION;

-- удалить техника

DELETE FROM technics 
WHERE technics.employee_id =
    (
        SELECT id
        FROM employee
        WHERE LOWER( employee.snils )  LIKE ?
    );

COMMIT;

