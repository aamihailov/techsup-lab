-- получить расходы на работу мастеров
-- для конкретного оборудования

SELECT SUM( work_price ) AS sum_work_price
FROM (
  SELECT task_operation.work_price
  FROM task_operation
  INNER JOIN (
    SELECT task_equipment.task_id
    FROM task_equipment
    WHERE equipment_id = (
      SELECT id
      FROM equipment
      WHERE LOWER( equipment.serial_number ) LIKE ?
    )
  ) AS tmp
  ON tmp.task_id = task_operation.task_id
) AS tmp1;
