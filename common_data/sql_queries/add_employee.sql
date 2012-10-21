START TRANSACTION;

-- принять сотрудника на работу

IF EXISTS
(
  SELECT *
  FROM employee
  WHERE LOWER( employee.snils )  LIKE ?
)
THEN
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
        WHERE LOWER( employee.snils )  LIKE ?
        ) AND type_id = employee_operation_type.id
    ) AS tmp 
    WHERE tmp.employee_operation_name = 'уволен'
  ) 
  THEN
    UPDATE employee
    SET employee.login    = ?,
        employee.password = ?
    WHERE employee.id = (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils )  LIKE ?
    );  

    INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
    VALUES ( 
            (  SELECT CURDATE() ),
            (
              SELECT id
              FROM employee_operation_type
              WHERE LOWER( employee_operation_type.name ) = 'принят'
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
  END IF;  
ELSE 
  INSERT INTO employee ( snils, name, phone, addr, login, password, role_id )
    VALUES(
           ?, ?, ?, ?, 
           ?, ?,
           ( 
              SELECT id
              FROM employee_role
              WHERE LOWER( employee_role.name ) LIKE ?
           )
  );

  INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
  VALUES ( 
          ( SELECT CURDATE() ),
          (
            SELECT id
            FROM employee_operation_type
            WHERE LOWER( employee_operation_type.name ) = 'принят'
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
END IF;

COMMIT;

