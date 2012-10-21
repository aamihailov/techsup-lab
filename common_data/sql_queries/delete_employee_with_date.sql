START TRANSACTION;

-- уволить сотрудника

CREATE TEMPORARY TABLE temp AS(
  SELECT *
  FROM (
    SELECT employee_id, type_id, MAX( employee_operation.date ),
           employee_operation_type.name AS employee_operation_name,
           employee_operation.department_id
    FROM employee_operation, employee_operation_type
    WHERE employee_id = (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils )  LIKE ?
    ) AND type_id = employee_operation_type.id
  ) AS tmp 
  WHERE tmp.employee_operation_name = 'принят'
);

IF EXISTS
(
    SELECT *
    FROM temp
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
                WHERE LOWER( employee.snils )  LIKE ?
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
        WHERE LOWER( employee.snils )  LIKE ?;
END IF;

COMMIT;
