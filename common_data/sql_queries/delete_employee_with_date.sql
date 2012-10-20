START TRANSACTION;

-- уволить сотрудника

IF EXISTS
(
    SELECT *
    FROM (
      SELECT employee_id, type_id, MAX( employee_operation.date ),
             employee_operation_type.name AS employee_operation_name
      FROM employee_operation, employee_operation_type
      WHERE employee_id = (
        SELECT id
        FROM employee
        WHERE LOWER( employee.name )  LIKE ? AND
              LOWER( employee.phone ) LIKE ?
        ) AND type_id = employee_operation_type.id
    ) AS tmp 
    WHERE tmp.employee_operation_name = 'принят'
) 
THEN
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
END IF;

COMMIT;

