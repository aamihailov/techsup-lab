START TRANSACTION;

-- удалить техника

DELETE FROM technics 
WHERE technics.employee_id =
    (
        SELECT id
        FROM employee
        WHERE LOWER( employee.name )  LIKE ? AND
              LOWER( employee.phone ) LIKE ?
    );

COMMIT;

