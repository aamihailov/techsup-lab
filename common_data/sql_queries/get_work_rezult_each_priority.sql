-- получить информацию об общем количестве
-- выполненных заявок по приоритетам

SELECT priority, COUNT(*) AS summ
FROM (
  SELECT employee.id, employee.name,
         tmp.task_id, tmp.priority_id,
         task_priority.name AS priority
  FROM employee
  RIGHT JOIN (
    SELECT owner_id, task.id AS task_id, task.priority_id
    FROM task
    WHERE id IN (
      SELECT task_id
      FROM task_operation
      WHERE task_operation.state_id = (
        SELECT id
        FROM task_state
        WHERE task_state.name = 'закрыта'
      )
    )
  ) AS tmp
  ON employee.id = tmp.owner_id
  RIGHT JOIN task_priority
  ON priority_id = task_priority.id
) AS tmp1
WHERE priority_id > 0
GROUP BY priority_id, priority;
