-- получить номер группы доступа для пользователя

SELECT group_id
FROM employee
WHERE LOWER( employee.login )    LIKE ? AND
      LOWER( employee.password ) LIKE ?;
