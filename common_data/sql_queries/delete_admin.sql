START TRANSACTION;

-- удалить администратора

DELETE FROM admins 
WHERE admins.employee_id =
    (
        SELECT id
        FROM employee
        WHERE LOWER( employee.snils )  LIKE ?
    );

COMMIT;

