-- изменить куратора заявки

UPDATE task
  SET owner_id = (
    SELECT employee.id
    FROM employee
    WHERE employee.login          = ? AND
          md5 ( employee.password = ?
  )
  WHERE task.id = ?;

