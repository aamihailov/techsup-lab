DELIMITER $$

DROP PROCEDURE IF EXISTS change_equipment_owner$$
CREATE PROCEDURE change_equipment_owner (
                                         IN serial_number VARCHAR(128), 
                                         IN in_snils      VARCHAR(16)
                                        )
BEGIN

START TRANSACTION;

-- сменить пользователя оборудования

INSERT INTO equipment_owner( equipment_id, employee_id )
    VALUES(  
            (
                SELECT equipment.id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE serial_number
            ), 
            (
                SELECT employee.id
                FROM employee
                WHERE LOWER(employee.snils) LIKE in_snils
            ) 
        );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS change_task_owner$$
CREATE PROCEDURE change_task_owner(
                                   IN task_id  INT(11),
                                   IN in_snils VARCHAR(128)
                                  ) 
BEGIN

START TRANSACTION;

-- изменить куратора заявки

UPDATE task
    SET owner_id = (
            SELECT employee.id
            FROM employee
            WHERE LOWER(employee.snils) LIKE in_snils
        )
    WHERE task.id = task_id;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS delete_department$$
CREATE PROCEDURE delete_department( 
                                    IN name VARCHAR( 128 )
                                  )
BEGIN

START TRANSACTION;

-- удалить организацию

UPDATE department
        SET exists_now = FALSE
        WHERE LOWER( department.name ) LIKE name;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_operation$$
CREATE PROCEDURE get_equipment_operation( 
                                         IN serial_number VARCHAR( 128 )
                                        )
BEGIN

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
            WHERE LOWER( equipment.serial_number ) LIKE serial_number
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
            WHERE LOWER( equipment.serial_number ) LIKE serial_number
    )
    ORDER BY equipment_operation.datetime
) AS temp_eq_oper
ON temp_eq_oper.id = equipment_operation_id;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_owner$$
CREATE PROCEDURE get_equipment_owner(
                                     IN serial_number VARCHAR( 128 )
                                    )
BEGIN

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
            WHERE LOWER( equipment.serial_number ) LIKE serial_number
        )
   )
) AS tmp2
ON employee.id = tmp2.employee_id
ORDER BY name;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_sum_detail_price$$
CREATE PROCEDURE get_equipment_sum_detail_price( 
                                                IN serial_number VARCHAR( 128 )
                                               )
BEGIN

-- получить расходы по закупке деталей
-- для конкретного оборудования

SELECT tmp.sum_detail_price
FROM (
    SELECT equipment_id, SUM( detail_price ) AS sum_detail_price 
    FROM equipment_operation
    GROUP BY equipment_id
) AS tmp
WHERE tmp.equipment_id = (
    SELECT id
    FROM equipment
    WHERE LOWER( equipment.serial_number ) LIKE serial_number
);

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_sum_work_price$$
CREATE PROCEDURE get_equipment_sum_work_price( 
                                              IN serial_number VARCHAR( 128 )
                                             )
BEGIN

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
            WHERE LOWER( equipment.serial_number ) LIKE serial_number
        )
    ) AS tmp
    ON tmp.task_id = task_operation.task_id
) AS tmp1;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_task_queue_user$$
CREATE PROCEDURE get_task_queue_user(
                                      IN in_begin_datetime DATETIME,
                                      IN in_end_datetime   DATETIME
                                    )
BEGIN

-- просмотреть очередь заявок с последним
-- изменённым статусом для пользователя

DROP TABLE IF EXISTS tmp_task;
CREATE TEMPORARY TABLE tmp_task AS
    SELECT task.id, task_priority.name AS priority, task.name AS task
    FROM task
    INNER JOIN task_priority
    ON task.priority_id = task_priority.id;

DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp AS
    SELECT task_operation.task_id, 
           employee.name,
           task_state.name AS state, task_operation.datetime 
    FROM task_operation
    INNER JOIN (
        SELECT task_operation.task_id, MAX( task_operation.datetime ) AS date
        FROM task_operation
        GROUP BY task_operation.task_id
    ) AS temp
    ON task_operation.task_id = temp.task_id AND
       task_operation.datetime = temp.date
    LEFT JOIN employee
    ON technic_id = employee.id
    INNER JOIN task_state 
    ON state_id = task_state.id;

SELECT *
FROM (
    SELECT tmp.task_id, 
           task_priority.name AS priority,
           task.name AS task,
           tmp.name AS technic,
           tmp.state, tmp.datetime
    FROM tmp
    INNER JOIN task
    ON tmp.task_id = task.id
    INNER JOIN task_priority
    ON priority_id = task_priority.id
) AS t
WHERE t.datetime > in_begin_datetime AND t.datetime < in_end_datetime
ORDER BY t.datetime;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS put_new_task$$
CREATE PROCEDURE put_new_task(
                              IN task_name     VARCHAR( 128 ),
                              IN priority_id   INT( 11 ),
                              IN login         VARCHAR ( 64 ),
                              IN password      VARCHAR ( 128 ),
                              IN in_datetime   DATETIME,
                              IN serial_number VARCHAR( 128 )
                             )
BEGIN

START TRANSACTION;

-- добавить новую заявку

INSERT INTO task ( name, datetime, priority_id, client_id )
    VALUES( task_name, 
            in_datetime,
            priority_id, 
            (
                SELECT id
                FROM employee
                WHERE employee.login    LIKE login AND
                      employee.password LIKE password
            )            
           );

INSERT INTO task_equipment ( task_id, equipment_id )
    VALUES( 
           (
                SELECT id
                FROM task
                WHERE task.datetime = ( 
                    SELECT MAX( datetime )
                    FROM task
                )  
           ),
           (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE serial_number
           )
          );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS gen_put_new_task$$
CREATE PROCEDURE gen_put_new_task(
                  IN in_id         INT( 11 ),
								  IN task_name     VARCHAR( 128 ),
								  IN priority_id   INT( 11 ),
								  IN in_snils      VARCHAR ( 16 ),
								  IN in_datetime   DATETIME,
								  IN serial_number VARCHAR( 128 )
								 )
BEGIN

START TRANSACTION;

-- добавить новую заявку

INSERT INTO task ( id, name, datetime, priority_id, client_id )
    VALUES( 
            in_id,
            task_name, 
            in_datetime,
            priority_id, 
            (
                SELECT id
                FROM employee
                WHERE LOWER( employee.snils ) LIKE in_snils
            )            
           );

INSERT INTO task_equipment ( task_id, equipment_id )
    VALUES( 
           in_id,
           (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE serial_number
           )
          );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_task_owner$$
CREATE PROCEDURE add_task_owner(
                                IN in_task_id   INT(11),
                                IN in_login     VARCHAR ( 64 ),
                                IN in_password  VARCHAR ( 128 ),
                                IN in_datetime  DATETIME
                              )
BEGIN

START TRANSACTION;

-- добавить куратора заявки

UPDATE task
  SET task.owner_id = (
    SELECT id
    FROM employee
    WHERE employee.login    LIKE in_login AND
          employee.password LIKE in_password
  )
  WHERE task.id = in_task_id;

INSERT INTO task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
    in_datetime,
    in_task_id,
    (
      SELECT id
      FROM employee
      WHERE employee.login    LIKE in_login AND
            employee.password LIKE in_password
    ),
    (
      SELECT id
      FROM task_state
      WHERE LOWER( task_state.name ) LIKE 'выполняется'
    )
  );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS gen_add_task_owner$$
CREATE PROCEDURE gen_add_task_owner(
									IN in_task_id   INT(11),
									IN in_snils     VARCHAR ( 16 ),
									IN in_datetime  DATETIME
								   )
BEGIN

START TRANSACTION;

-- добавить куратора заявки

UPDATE task
  SET task.owner_id = (
    SELECT id
    FROM employee
    WHERE LOWER( employee.snils ) LIKE in_snils
  )
  WHERE task.id = in_task_id;

INSERT INTO task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
    in_datetime,
    in_task_id,
    (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils ) LIKE in_snils
    ),
    (
      SELECT id
      FROM task_state
      WHERE LOWER( task_state.name ) LIKE 'выполняется'
    )
  );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS close_task$$
CREATE PROCEDURE close_task(
                              IN in_task_id   INT(11),
                              IN in_login     VARCHAR ( 64 ),
                              IN in_password  VARCHAR ( 128 ),
                              IN in_datetime  DATETIME
                           )
BEGIN

START TRANSACTION;

-- закрыть заявку

IF NOT EXISTS (
    SELECT *
    FROM (
        SELECT name
        FROM task_state
        INNER JOIN (
            SELECT state_id
            FROM task_operation
            WHERE task_id = in_task_id AND datetime = (
                SELECT max_date
                FROM (
                    SELECT task_id, MAX( datetime ) AS max_date
                    FROM task_operation
                    GROUP BY task_id
                ) AS tmp_date
                WHERE tmp_date.task_id = in_task_id
            )
        ) AS tmp
        ON task_state.id = tmp.state_id 
    ) AS t
    WHERE LOWER( t.name ) = 'закрыта'
)
THEN
  INSERT INTO task_operation( datetime, task_id, technic_id, state_id )
    VALUES(
      in_datetime,
      in_task_id,
      (
        SELECT id
        FROM employee
        WHERE employee.login    LIKE in_login AND
              employee.password LIKE in_password
      ),
      (
        SELECT id
        FROM task_state
        WHERE LOWER( task_state.name ) LIKE 'закрыта'
      )
    );
END IF;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS gen_close_task$$
CREATE PROCEDURE gen_close_task(
                                IN in_task_id   INT(11),
                                IN in_snils     VARCHAR( 16 ),
                                IN in_datetime  DATETIME
                               )
BEGIN

START TRANSACTION;

-- закрыть заявку

INSERT INTO task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
    in_datetime,
    in_task_id,
    (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils ) LIKE in_snils
    ),
    (
      SELECT id
      FROM task_state
      WHERE LOWER( task_state.name ) LIKE 'закрыта'
    )
  );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS put_equipment_repair$$
CREATE PROCEDURE put_equipment_repair( 
                                      IN task_name     VARCHAR( 128 ),
                                      IN priority_id   INT( 11 ),
                                      IN serial_number VARCHAR( 128 ),
                                      IN login         VARCHAR ( 64 ),
                                      IN password      VARCHAR ( 128 ),
                                      IN in_datetime   DATETIME
                                    )
BEGIN

START TRANSACTION;

-- поместить оборудование на ремонт

INSERT INTO task ( name, datetime, priority_id, client_id )
    VALUES( task_name, 
            in_datetime,
            priority_id, 
            (
                SELECT id
                FROM employee
                WHERE employee.login    LIKE login AND
                      employee.password LIKE password
            )
           );

INSERT INTO task_operation( datetime, task_id, technic_id, state_id )
    VALUES(
            in_datetime,
            (
                SELECT id
                FROM task
                WHERE datetime = ( 
                    SELECT MAX( datetime )
                    FROM task
                )  
            ),
            (
                SELECT id
                FROM employee
                WHERE employee.login    LIKE login AND
                      employee.password LIKE password
            ),
            (
                SELECT id
                FROM task_state
                WHERE task_state.name = 'новая'
            )   
        );

INSERT INTO task_equipment ( task_id, equipment_id )
    VALUES( 
            (
                SELECT id
                FROM task
                WHERE datetime = ( 
                    SELECT MAX( datetime )
                    FROM task
                )  
            ),
            (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE serial_number
            )
          );

INSERT INTO equipment_operation( datetime, equipment_id, eq_oper_type_id )
    VALUES(
            in_datetime,
            (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE serial_number
            ),
            (
                SELECT id
                FROM equipment_operation_type
                WHERE equipment_operation_type.name = 'помещение на ремонт'
            )
          );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS gen_equipment_repair$$
CREATE PROCEDURE gen_equipment_repair( 
                                      IN in_detail_price    DOUBLE,
                                      IN in_datetime        DATETIME,
                                      IN in_serial_number   VARCHAR( 128 ),
                                      IN in_comment         VARCHAR( 512 ),
                                      IN in_detail_model_id INT( 11 ),
                                      IN in_task_id         INT( 11 )
                                    )
BEGIN

START TRANSACTION;

-- ремонт оборудования

INSERT INTO equipment_operation( detail_price, datetime, equipment_id, eq_oper_type_id )
    VALUES(
            in_detail_price,
            in_datetime,
            (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
            ),
            (
                SELECT id
                FROM equipment_operation_type
                WHERE equipment_operation_type.name = 'ремонт'
            )
          );

INSERT INTO repair( comment, datetime, detail_model_id, equipment_operation_id, task_id )
  VALUES(
          in_comment,
          in_datetime,
          in_detail_model_id,
          (
            SELECT id
            FROM equipment_operation
            WHERE equipment_operation.datetime = in_datetime AND equipment_operation.equipment_id = (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
            ) AND equipment_operation.eq_oper_type_id = (
              SELECT id
              FROM equipment_operation_type
              WHERE LOWER( equipment_operation_type.name ) = 'ремонт'
            )
          ),
          in_task_id
        );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS get_work_each_empl$$
CREATE PROCEDURE get_work_each_empl(
                                    IN in_snils VARCHAR( 16 ) 
                                   )
BEGIN

-- получить информацию об общем количестве выполненных заявок
-- для кажого работника

SELECT id, name, COUNT(*)
FROM (
    SELECT employee.id, employee.snils, employee.name,
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
                WHERE LOWER( task_state.name ) = 'закрыта'
            )
        )
    ) AS tmp
    ON employee.id = tmp.owner_id
    RIGHT JOIN task_priority
    ON priority_id = task_priority.id
) AS tmp1
WHERE priority_id > 0 AND snils LIKE in_snils
GROUP BY id, name;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_each_prior_empl$$
CREATE PROCEDURE get_work_each_prior_empl( 
                                          IN in_snils VARCHAR( 16 ) 
                                         )
BEGIN

-- получить информацию околичестве выполненных заявок
-- для кажого работника по приоритетам заявок

SELECT id, name, priority, COUNT(*)
FROM (
    SELECT employee.id, employee.snils, employee.name,
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
                WHERE LOWER( task_state.name ) = 'закрыта'
            )
        )
    ) AS tmp
    ON employee.id = tmp.owner_id
    RIGHT JOIN task_priority
    ON priority_id = task_priority.id
) AS tmp1
WHERE priority_id > 0  AND snils LIKE in_snils
GROUP BY id, priority, name;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_rezult_all$$
CREATE PROCEDURE get_work_rezult_all( )
BEGIN

-- получить информацию об общем количестве
-- выполненных заявок

SELECT COUNT(*) AS summ
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
                WHERE LOWER( task_state.name ) = 'закрыта'
            )
        )
    ) AS tmp
    ON employee.id = tmp.owner_id
    RIGHT JOIN task_priority
    ON priority_id = task_priority.id
) AS tmp1
WHERE priority_id > 0;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_rezult_each_priority$$
CREATE PROCEDURE get_work_rezult_each_priority( )
BEGIN

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

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_admin$$
CREATE PROCEDURE add_admin(
                            IN in_snils VARCHAR( 16 )
                          )
BEGIN

-- добавить администратора

INSERT INTO admins 
    VALUES (
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.snils )  LIKE in_snils
        )
   );

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_technic$$
CREATE PROCEDURE add_technic(
                              IN in_snils VARCHAR( 16 )
                            )
BEGIN

-- добавить техника

INSERT INTO technics
    VALUES (
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.snils )  LIKE in_snils
        )
   );

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_new_employee$$
CREATE PROCEDURE add_new_employee(
                                  IN in_snils      VARCHAR( 16 ),
                                  IN in_name       VARCHAR( 128 ),
                                  IN in_phone      VARCHAR( 32 ),
                                  IN in_addr       VARCHAR( 256 ),
                                  IN in_login      VARCHAR( 64 ),
                                  IN in_password   VARCHAR( 128 ),
                                  IN in_role_name  VARCHAR( 128 ),
                                  IN in_department_name VARCHAR( 128 ),
                                  IN in_date DATE
                                 )
BEGIN

START TRANSACTION;

-- принять нового сотрудника на работу

INSERT INTO employee ( snils, name, phone, addr, login, password, role_id )
  VALUES(
         in_snils, in_name, in_phone, in_addr, 
         in_login, in_password,
         ( 
            SELECT id
            FROM employee_role
            WHERE LOWER( employee_role.name ) LIKE in_role_name
         )
);

INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
  VALUES ( 
          in_date,
          (
            SELECT id
            FROM employee_operation_type
            WHERE LOWER( employee_operation_type.name ) = 'принят'
          ),
          (
            SELECT id
            FROM employee
            WHERE LOWER( employee.snils )  LIKE in_snils
          ),
          (
            SELECT id
            FROM department
            WHERE LOWER( department.name ) LIKE in_department_name
          )
  );
COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_existing_employee$$
CREATE PROCEDURE add_existing_employee(
                                        IN in_snils      VARCHAR( 16 ),
                                        IN in_login      VARCHAR( 64 ),
                                        IN in_password   VARCHAR( 128 ),
                                        IN in_role_name  VARCHAR( 128 ),
                                        IN in_department_name VARCHAR( 128 ),
                                        IN in_date DATE
                                      )
BEGIN

START TRANSACTION;

-- принять существующего сотрудника на работу

UPDATE employee
  SET employee.login    = in_login,
      employee.password = in_password,
      employee.role_id  = ( 
        SELECT id
        FROM employee_role
        WHERE LOWER( employee_role.name ) LIKE in_role_name
      )
  WHERE employee.id = (
    SELECT id
    FROM employee
    WHERE LOWER( employee.snils )  LIKE in_snils
  );  

INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
  VALUES ( 
          in_date,
          (
            SELECT id
            FROM employee_operation_type
            WHERE LOWER( employee_operation_type.name ) = 'принят'
          ),
          (
            SELECT id
            FROM employee
            WHERE LOWER( employee.snils )  LIKE in_snils
          ),
          (
            SELECT id
            FROM department
            WHERE LOWER( department.name ) LIKE in_department_name
          )
  ); 

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

-- CALL add_employee( '999-999-999 99', 'Анастасия Алексеевна Санина',
--                    '+7-923-233-39-95', 'Блюхера, 30/1',
--                    'anastas.sanina', md5( 'anastas.sanina' ),
--                    'администратор', 'Региональный Сервисный Центр',
--                    ( SELECT NOW() )
--                  );

DROP PROCEDURE IF EXISTS add_employee$$
CREATE PROCEDURE add_employee(
                               IN in_snils      VARCHAR( 16 ),
                               IN in_name       VARCHAR( 128 ),
                               IN in_phone      VARCHAR( 32 ),
                               IN in_addr       VARCHAR( 256 ),
                               IN in_login      VARCHAR( 64 ),
                               IN in_password   VARCHAR( 128 ),
                               IN in_role_name  VARCHAR( 128 ),
                               IN in_department_name VARCHAR( 128 ),
                               IN in_date       DATE
                             )
BEGIN

START TRANSACTION;

-- принять сотрудника на работу

IF EXISTS
(
  SELECT *
  FROM employee
  WHERE LOWER( employee.snils )  LIKE in_snils
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
        WHERE LOWER( employee.snils )  LIKE in_snils
        ) AND type_id = employee_operation_type.id
    ) AS tmp 
    WHERE tmp.employee_operation_name = 'уволен'
  ) 
  THEN
    CALL add_existing_employee( in_snils, 
                                in_login, in_password, 
                                in_role_name, in_department_name,
                                in_date
                              );     
  END IF;  
ELSE 
  CALL add_new_employee( in_snils, in_name, in_phone, in_addr, 
                         in_login, in_password, 
                         in_role_name, in_department_name,
                         in_date
                       );
END IF;

CASE in_role_name
  WHEN 'администратор' THEN CALL add_admin( in_snils );
  WHEN 'техник' THEN CALL add_technic( in_snils );
  ELSE 
    BEGIN
    END;
END CASE;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS delete_admin$$
CREATE PROCEDURE delete_admin(
                              IN in_snils VARCHAR( 16 )
                             )
BEGIN

-- удалить администратора

DELETE FROM admins 
WHERE admins.employee_id =
    (
        SELECT id
        FROM employee
        WHERE LOWER( employee.snils )  LIKE in_snils
    );

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS delete_technic$$
CREATE PROCEDURE delete_technic(
                                IN in_snils VARCHAR( 16 )
                               )
BEGIN

-- удалить техника

DELETE FROM technics 
WHERE technics.employee_id =
    (
        SELECT id
        FROM employee
        WHERE LOWER( employee.snils )  LIKE in_snils
    );

END$$

-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS get_employee_role$$
CREATE FUNCTION get_employee_role(
                                  in_snils VARCHAR( 16 )
                                 )
RETURNS CHAR( 128 )
BEGIN

-- получить должность сотрудника

RETURN(
  SELECT name
  FROM employee_role
  INNER JOIN (
    SELECT role_id
    FROM employee
    WHERE LOWER( employee.snils ) = in_snils
  ) AS tmp
  ON employee_role.id = tmp.role_id 
);

END$$

-- ---------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS delete_employee$$
CREATE PROCEDURE delete_employee(
                                           IN in_snils VARCHAR( 16 ),
                                           IN in_date DATE
                                          )
BEGIN

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
      WHERE LOWER( employee.snils )  LIKE in_snils
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
            in_date,
            (
                SELECT id
                FROM employee_operation_type
                WHERE LOWER( employee_operation_type.name ) = 'уволен'
            ),
            (
                SELECT id
                FROM employee
                WHERE LOWER( employee.snils )  LIKE in_snils
            ),
            ( 
              SELECT department_id
              FROM temp
            )
        ); 

    UPDATE employee
        SET employee.login    = NULL,
            employee.password = NULL
        WHERE LOWER( employee.snils )  LIKE in_snils;
END IF;

IF ( 
  ( SELECT get_employee_role( in_snils ) ) = 'администратор'
)
THEN CALL delete_admin( in_snils );
ELSEIF (
  ( SELECT get_employee_role( in_snils ) ) = 'техник'
)
THEN CALL delete_technic( in_snils );
END IF;

DROP TABLE IF EXISTS temp;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

-- CALL add_equipment_owner(
--                          '999-999-999 99',
--                          'серийник рабочее место начальника'
--                          ( SELECT NOW( ) )
--                         );

-- CALL add_equipment_owner(
--                          '999-999-999 99',
--                          'серийник ноута'
--                          ( SELECT NOW( ) )
--                         );

DROP PROCEDURE IF EXISTS add_equipment_owner$$
CREATE PROCEDURE add_equipment_owner(
                                     IN in_snils          VARCHAR( 16 ),
                                     IN in_serial_number  VARCHAR( 128 ),
                                     IN in_start_datetime DATETIME
                                    )
BEGIN

START TRANSACTION;

-- добавить пользователя оборудованием

IF NOT EXISTS (
  SELECT *
  FROM equipment_owner
  WHERE equipment_owner.equipment_id = (
    SELECT id
    FROM equipment
    WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
  ) AND
  equipment_owner.employee_id = (
    SELECT id
    FROM employee
    WHERE LOWER( employee.snils ) LIKE in_snils
  ) AND
  equipment_owner.finish_datetime = NULL
)
THEN
  INSERT INTO equipment_owner ( equipment_id, employee_id, start_datetime )
      VALUES (
          (
              SELECT id
              FROM equipment
              WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
          ),
          (
              SELECT id
              FROM employee
              WHERE LOWER( employee.snils )  LIKE in_snils
          ),
          in_start_datetime
      );
END IF;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_equipment$$
CREATE PROCEDURE add_equipment(
                               IN in_name            VARCHAR( 128 ),
                               IN in_serial_number   VARCHAR( 128 ),
                               IN in_addr            VARCHAR( 256 ),
                               IN in_equipment_model VARCHAR( 255 ),
                               IN in_datetime DATETIME                               
                              )
BEGIN

START TRANSACTION;

-- добавление оборудования

INSERT INTO equipment ( name, serial_number, addr, equipment_model_id )
    VALUES (
        in_name,
        in_serial_number,
        in_addr,
        (
            SELECT id
            FROM equipment_model
            WHERE LOWER( equipment_model.name ) LIKE in_equipment_model
            UNION SELECT 154 LIMIT 1
        )
    );

INSERT INTO equipment_operation ( datetime, equipment_id, eq_oper_type_id )
    VALUES (
            in_datetime,
            (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
            ),
            (
                SELECT id
                FROM equipment_operation_type
                WHERE LOWER( equipment_operation_type.name ) = 'поступление'
            )
   );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_equipment_and_owner$$
CREATE PROCEDURE add_equipment_and_owner(
                                         IN in_snils           VARCHAR( 16 ),
                                         IN in_name            VARCHAR( 128 ),
                                         IN in_serial_number   VARCHAR( 128 ),
                                         IN in_addr            VARCHAR( 256 ),
                                         IN in_equipment_model VARCHAR( 255 ),
                                         IN in_datetime        DATETIME                               
                                        )
BEGIN

START TRANSACTION;

-- добавление оборудования и владельца оборудования

CALL add_equipment( in_name, in_serial_number, in_addr, in_equipment_model, in_datetime );
CALL add_equipment_owner( in_snils, in_serial_number, in_datetime );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

-- call delete_equipment( 'issl-714-3299-54-lt', (SELECT NOW()) );

DROP PROCEDURE IF EXISTS delete_equipment$$
CREATE PROCEDURE delete_equipment(
                                  IN in_serial_number VARCHAR( 128 ),
                                  IN in_datetime      DATETIME                               
                                 )
BEGIN

START TRANSACTION;

-- списание оборудования

IF NOT EXISTS (
  SELECT *
  FROM (
    SELECT equipment_operation_type.name
    FROM equipment_operation_type
    INNER JOIN (
      SELECT equipment_id, eq_oper_type_id, datetime
      FROM (
        SELECT equipment_id, eq_oper_type_id, datetime                                        
        FROM equipment_operation
        WHERE equipment_id = (
          SELECT id
          FROM equipment
          WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
        )
      ) AS tmp
      WHERE datetime = (
        SELECT MAX( datetime )
        FROM equipment_operation
        WHERE equipment_operation.equipment_id = (
          SELECT id
          FROM equipment
          WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
        )
      )
    ) AS temp
    ON equipment_operation_type.id = temp.eq_oper_type_id
  ) AS tmp_operation
  WHERE tmp_operation.name = 'списание'
)
THEN
  INSERT INTO equipment_operation( datetime, equipment_id, eq_oper_type_id )
    VALUES(
            in_datetime,
            (
              SELECT id
              FROM equipment
              WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
            ),
            (
              SELECT id
              FROM equipment_operation_type
              WHERE LOWER( equipment_operation_type.name ) = 'списание'
            ) 
    );

  UPDATE equipment_owner
    SET equipment_owner.finish_datetime = in_datetime
    WHERE equipment_owner.equipment_id = (
      SELECT id
      FROM equipment
      WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
    );
END IF;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS delete_equipment_owner$$
CREATE PROCEDURE delete_equipment_owner(
                                        IN in_snils         VARCHAR( 16 ),
                                        IN in_serial_number VARCHAR( 128 ),
                                        IN in_datetime      DATETIME                               
                                       )
BEGIN

START TRANSACTION;

-- отписать владельца от оборудования

IF EXISTS (
  SELECT *
  FROM equipment_owner
  WHERE equipment_owner.equipment_id = (
    SELECT id
    FROM equipment
    WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
  ) AND
  equipment_owner.employee_id = (
    SELECT id
    FROM employee
    WHERE LOWER( employee.snils ) LIKE in_snils
  ) AND
  equipment_owner.finish_datetime = NULL
)
THEN
  UPDATE equipment_owner
    SET equipment_owner.finish_datetime = in_datetime
    WHERE equipment_owner.equipment_id = (
      SELECT id
      FROM equipment
      WHERE LOWER( equipment.serial_number ) LIKE in_serial_number
    ) AND equipment_owner.employee_id = (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils ) LIKE in_snils
    );
END IF;

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS get_department_id_for_employee$$
CREATE FUNCTION get_department_id_for_employee(
                                                in_snils   VARCHAR( 16 )
                                              )
RETURNS INT
BEGIN

-- получить id-подразделения для сотрудника

RETURN(
  SELECT department_id
  FROM (
    SELECT department_id, MAX( employee_operation.date )
    FROM employee_operation
    WHERE employee_operation.employee_id = (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils ) = in_snils
    )
  ) AS temp
);

END$$

-- ---------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_vacation$$
CREATE PROCEDURE add_vacation(
                              IN in_snils   VARCHAR( 16 ),
                              IN date_start DATE,
                              IN date_end   DATE
                             )
BEGIN

START TRANSACTION;

-- установить даты отпусков

INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
  VALUES( 
    date_start,
    (
      SELECT id
      FROM employee_operation_type
      WHERE LOWER( employee_operation_type.name ) = 'отправлен в отпуск'
    ),
    (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils ) = in_snils 
    ),
    ( SELECT get_department_id_for_employee( in_snils ) )
  );

INSERT INTO employee_operation ( date, type_id, employee_id, department_id )
  VALUES( 
    date_end,
    (
      SELECT id
      FROM employee_operation_type
      WHERE LOWER( employee_operation_type.name ) = 'отозван из отпуска'
    ),
    (
      SELECT id
      FROM employee
      WHERE LOWER( employee.snils ) = in_snils 
    ),
    ( SELECT get_department_id_for_employee( in_snils ) )
  );

COMMIT;

END$$

-- ---------------------------------------------------------------------------------------------

DELIMITER ;
