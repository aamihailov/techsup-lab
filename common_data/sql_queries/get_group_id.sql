START TRANSACTION;

-- получить номер группы доступа для пользователя

SELECT group_id
FROM employee
WHERE employee.login           LIKE ? AND
      md5( employee.password ) LIKE ?;

COMMIT;

