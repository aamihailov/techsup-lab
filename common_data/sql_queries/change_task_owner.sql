-- изменить куратора заявки

UPDATE task
  SET owner_id = (
    SELECT employee.id
    FROM employee
    WHERE LOWER( employee.login )    = ? AND
          LOWER( employee.password ) = ?
  )
  WHERE task.id = ?;
