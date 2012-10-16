-- получить информацию о всех операциях 
-- с конкретным оборудованием

SELECT temp_eq_oper.id, temp_eq_oper.detail_price,
       temp_eq_oper.datetime, temp_eq_oper.operation,
       tmp.repair_id, 
       detail_model.name AS detail_model,
       tmp.comment,    
       tmp.datetime AS repair_datetime,   
       employee.name, employee.phone
FROM (
  SELECT task_operation.task_id, technic_id, MAX( task_operation.datetime )
  FROM task_operation
  GROUP BY task_operation.task_id
) AS tmp1
INNER JOIN (
  SELECT repair.id AS repair_id,
         repair.equipment_operation_id,
         repair.detail_model_id,
         repair.comment,
         repair.datetime,
         repair.task_id
  FROM repair
  WHERE repair.equipment_operation_id IN (
    SELECT id
    FROM equipment_operation
    WHERE equipment_id = (
      SELECT equipment.id
      FROM equipment
      WHERE LOWER( equipment.serial_number ) LIKE ?
    ) AND eq_oper_type_id = ( 
        SELECT equipment_operation_type.id
        FROM equipment_operation_type
        WHERE equipment_operation_type.name = 'ремонт' )
    )
) AS tmp
ON tmp1.task_id = tmp.task_id
INNER JOIN employee 
ON technic_id = employee.id
INNER JOIN detail_model
ON detail_model_id = detail_model.id
RIGHT JOIN (
    -- получить все операции с оборудованием по коду    
    SELECT equipment_operation.id,
           equipment_operation.eq_oper_type_id, equipment_operation.detail_price,
           equipment_operation.datetime, equipment_operation_type.name AS operation
    FROM equipment_operation, equipment_operation_type
    WHERE equipment_operation_type.id = equipment_operation.eq_oper_type_id AND 
          equipment_operation.equipment_id = (
            SELECT equipment.id
            FROM equipment
            WHERE LOWER( equipment.serial_number ) LIKE ?
    )
    ORDER BY equipment_operation.datetime
) AS temp_eq_oper
ON temp_eq_oper.id = equipment_operation_id;
