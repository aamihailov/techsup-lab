DROP PROCEDURE IF EXISTS change_equipment_owner;
CREATE PROCEDURE change_equipment_owner (
                                         IN serial_number VARCHAR(128), 
                                         IN login VARCHAR(128), 
                                         IN password VARCHAR(128)
                                        )
BEGIN

-- сменить пользователя оборудования

INSERT INTO equipment_owner( equipment_id, employee_id )
    VALUES(  
            (
                SELECT equipment.id
                FROM equipment
                WHERE equipment.serial_number = serial_number
            ), 
            (
                SELECT employee.id
                FROM employee
                WHERE employee.login    = login AND
                      employee.password = password
            ) 
        );
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS change_task_owner;
CREATE PROCEDURE change_task_owner(
                                   IN task_id  INT(11),
                                   IN login    VARCHAR(128), 
                                   IN password VARCHAR(128)
                                  ) 
BEGIN

-- изменить куратора заявки

UPDATE task
    SET owner_id = (
            SELECT employee.id
            FROM employee
            WHERE employee.login    = login AND
                  employee.password = password
        )
    WHERE task.id = task_id;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS delete_department;
CREATE PROCEDURE delete_department( 
                                    IN name VARCHAR( 128 )
                                  )
BEGIN

-- удалить организацию

UPDATE department
        SET exists_now = FALSE
        WHERE department.name  = name;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_operation;
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
            WHERE equipment.serial_number LIKE serial_number
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
            WHERE equipment.serial_number LIKE serial_number
    )
    ORDER BY equipment_operation.datetime
) AS temp_eq_oper
ON temp_eq_oper.id = equipment_operation_id;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_owner;
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
            WHERE equipment.serial_number LIKE serial_number
        )
   )
) AS tmp2
ON employee.id = tmp2.employee_id
ORDER BY name;

END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_sum_detail_price;
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
    WHERE equipment.serial_number LIKE serial_number
);
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_equipment_sum_work_price;
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
            WHERE equipment.serial_number LIKE serial_number
        )
    ) AS tmp
    ON tmp.task_id = task_operation.task_id
) AS tmp1;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_group_id;
CREATE PROCEDURE get_group_id(
                              IN login    VARCHAR(128),
                              IN password VARCHAR(128)
                             )
BEGIN

-- получить номер группы доступа для пользователя

SELECT group_id
FROM employee
WHERE employee.login    LIKE login AND
      employee.password LIKE password;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_task_queue_user;
CREATE PROCEDURE get_task_queue_user( )
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
    ORDER BY tmp.datetime;     
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS put_new_task;
CREATE PROCEDURE put_new_task(
                              IN task_name     VARCHAR( 128 ),
                              IN priority_id   INT( 11 ),
                              IN serial_number VARCHAR( 128 ),
                              IN login         VARCHAR ( 64 ),
                              IN password      VARCHAR ( 128 )
                             )
BEGIN

-- добавить новую заявку

INSERT INTO task ( name, datetime, priority_id, client_id )
    VALUES( task_name, 
            ( SELECT NOW() ),
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
                WHERE datetime = ( 
                    SELECT MAX( datetime )
                    FROM task
                )  
           ),
           (
                SELECT id
                FROM equipment
                WHERE equipment.serial_number LIKE serial_number
           )
          );
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS put_equipment_repair;
CREATE PROCEDURE put_equipment_repair( 
                                      IN task_name     VARCHAR( 128 ),
                                      IN priority_id   INT( 11 ),
                                      IN serial_number VARCHAR( 128 ),
                                      IN login         VARCHAR ( 64 ),
                                      IN password      VARCHAR ( 128 )
                                    )
BEGIN

-- поместить оборудование на ремонт

INSERT INTO task ( name, datetime, priority_id, client_id )
    VALUES( task_name, 
            ( SELECT NOW() ),
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
            ( 
                SELECT MAX( datetime )
                FROM task 
            ),
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
                WHERE equipment.serial_number LIKE serial_number
            )
          );

INSERT INTO equipment_operation( datetime, equipment_id, eq_oper_type_id )
    VALUES(
            ( 
                SELECT MAX( datetime )
                FROM task 
            ),
            (
                SELECT id
                FROM equipment
                WHERE equipment.serial_number LIKE serial_number
            ),
            (
                SELECT id
                FROM equipment_operation_type
                WHERE equipment_operation_type.name = 'помещение на ремонт'
            )
          );
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_each_empl;
CREATE PROCEDURE get_work_each_empl( )
BEGIN

-- получить информацию об общем количестве выполненных заявок
-- для кажого работника

SELECT id, name, COUNT(*)
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
GROUP BY id, name;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_each_prior_empl;
CREATE PROCEDURE get_work_each_prior_empl( )
BEGIN

-- получить информацию околичестве выполненных заявок
-- для кажого работника по приоритетам заявок

SELECT id, name, priority, COUNT(*)
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
GROUP BY id, priority, name;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_rezult_all;
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
                WHERE task_state.name = 'закрыта'
            )
        )
    ) AS tmp
    ON employee.id = tmp.owner_id
    RIGHT JOIN task_priority
    ON priority_id = task_priority.id
) AS tmp1
WHERE priority_id > 0;
END$$

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS get_work_rezult_each_priority;
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

-----------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS add_employee;
CREATE PROCEDURE add_employee(
                               IN in_name       VARCHAR( 128 ),
                               IN in_phone      VARCHAR( 32 ),
                               IN in_email      VARCHAR( 75 ),
                               IN in_addr       VARCHAR( 256 ),
                               IN in_login      VARCHAR( 64 ),
                               IN in_password   VARCHAR( 128 ),
                               IN in_role_name  VARCHAR( 128 ),
                               IN in_group_name VARCHAR( 128 ),
                               IN in_department_name VARCHAR( 128 ),
                               IN in_serial_number   VARCHAR( 128 )
                             )
BEGIN

-- принять сотрудника на работу

INSERT INTO employee ( name, phone, email, addr, login, password, role_id, group_id )
    VALUES(
        in_name, in_phone, in_email, in_addr, in_login, 
        md5( in_password),
        (
            SELECT id
            FROM employee_role
            WHERE LOWER( employee_role.name ) LIKE in_role_name
        ),
        (
            SELECT id
            FROM rights_group
            WHERE LOWER( rights_group.name ) LIKE in_group_name
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
            WHERE LOWER( employee.name )  LIKE in_name AND
                  LOWER( employee.phone ) LIKE in_phone
        ),
        (
            SELECT id
            FROM department
            WHERE LOWER( department.name ) LIKE in_department_name
        )
    ); 

INSERT INTO equipment_owner ( equipment_id, employee_id )
    VALUES (
        (
            SELECT id
            FROM equipment
            WHERE equipment.serial_number LIKE in_serial_number
        ),
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.name )  LIKE in_name AND
                  LOWER( employee.phone ) LIKE in_phone
        )
    );

END$$

-----------------------------------------------------------------------------------------------

