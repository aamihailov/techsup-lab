START TRANSACTION;

-- уволить сотрудника

INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
    VALUES ( 
        ?,
        (
            SELECT id
            FROM employee_operation_type
            WHERE LOWER( employee_operation_type.name ) = 'уволен'
        ),
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.name )  LIKE ? AND
                  LOWER( employee.phone ) LIKE ?
        ),
        (
            SELECT id
            FROM department
            WHERE LOWER( department.name ) LIKE ?
        )
    ); 

UPDATE employee
    SET employee.login    = NULL,
        employee.password = NULL
    WHERE LOWER( employee.name )  LIKE ? AND
          LOWER( employee.phone ) LIKE ?;

COMMIT;
