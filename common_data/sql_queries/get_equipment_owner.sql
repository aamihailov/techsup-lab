START TRANSACTION;

-- получить всех владельцев конкретного оборудования
-- с последним изменением статуса (принят/уволен)

SELECT employee.id AS employee_id, employee.name,
       employee_role.name AS role,
       employee.phone, employee.email,
       tmp2.state, tmp2.date
FROM employee
LEFT JOIN employee_role
ON employee.role_id = employee_role.id
RIGHT JOIN (
  SELECT *
  FROM (
    -- id сотрудников  с последними изменёнными статусами
    SELECT employee_operation.employee_id, 
           employee_operation_type.name AS state,
           employee_operation.date
    FROM employee_operation
      INNER JOIN (
        SELECT employee_operation.employee_id, MAX( employee_operation.date ) AS date
        FROM employee_operation
        GROUP BY employee_operation.employee_id
      ) AS tmp1
      ON employee_operation.employee_id = tmp1.employee_id AND
         employee_operation.date = tmp1.date
      INNER JOIN employee_operation_type
      ON type_id = employee_operation_type.id
    ) AS tmp
    WHERE tmp.employee_id IN (
      SELECT employee_id
      FROM equipment_owner
      WHERE equipment_owner.equipment_id = (
        SELECT equipment.id
        FROM equipment
        WHERE LOWER( equipment.serial_number ) LIKE ?
      )
    )
) AS tmp2
ON employee.id = tmp2.employee_id
ORDER BY name;

COMMIT;

