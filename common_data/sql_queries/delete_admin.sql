START TRANSACTION;

-- удалить администратора

DELETE FROM admins 
WHERE admins.employee_id =
    (
        SELECT id
        FROM employee
        WHERE LOWER( employee.name )  LIKE ? AND
              LOWER( employee.phone ) LIKE ?
    );

COMMIT;

