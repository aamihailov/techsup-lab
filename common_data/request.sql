-- students51
-- получить информацию околичестве выполненных заявок
-- для конкретного работника по приоритетам заявок

CREATE OR REPLACE FUNCTION _techsup_left.get_sum_task_for_employee_priority(
                                     in_snils       CHARACTER VARYING(16),
                                     in_priority    CHARACTER VARYING(255)
                                     )
RETURNS INTEGER
AS $$

BEGIN

RETURN (
    SELECT COUNT( * ) 
    FROM (
        SELECT task.id
        FROM _techsup_left.task
        WHERE id IN (
            SELECT task_id
            FROM _techsup_left.task_operation
            WHERE task_operation.state_id = (
                SELECT id
                FROM _techsup_left.task_state
                WHERE LOWER( task_state.name ) = 'закрыта'
            )
        ) AND
        owner_id = (
            SELECT id
            FROM _techsup_left.v_employee
            WHERE LOWER( v_employee.snils ) LIKE $1
        ) AND
        task.priority_id = ( 
            SELECT id
            FROM _techsup_left.task_priority
            WHERE LOWER( task_priority.name ) = $2
        )    
    ) AS tmp
);

END;
$$ LANGUAGE plpgsql;

-- '275-985-770 30'
-- '071-630-281 12'
-- SELECT _techsup_left.get_sum_task_for_employee_priority('275-985-770 30', 'самый низкий' );

SELECT snils,
       name,
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority('275-985-770 30', 'самый высокий' )
       ) AS very_hight,
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority('275-985-770 30', 'высокий' )
       ) AS hight,
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority('275-985-770 30', 'средний' )
       ) AS midle,
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority('275-985-770 30', 'низкий' )
       ) AS down,
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority('275-985-770 30', 'самый низкий' )
       ) AS short_down
FROM _techsup_left.v_employee
WHERE v_employee.snils = '275-985-770 30'

-- students51
-- просмотреть очередь заявок с последним
-- изменённым статусом для пользователя

SELECT *
FROM (
    SELECT tmp.task_id, 
           task_priority.name AS priority,
           task.name AS task,
           tmp.name AS technic,
           tmp.state, tmp.datetime
    FROM (
        SELECT task_operation.task_id, 
               v_employee.name,
               task_state.name AS state, task_operation.datetime 
        FROM _techsup_left.task_operation
        INNER JOIN (
            SELECT task_operation.task_id, MAX( task_operation.datetime ) AS date
            FROM _techsup_left.task_operation
            GROUP BY task_operation.task_id
        ) AS temp
        ON task_operation.task_id = temp.task_id AND
           task_operation.datetime = temp.date
        LEFT JOIN _techsup_left.v_employee
        ON technic_id = v_employee.id
        INNER JOIN _techsup_left.task_state 
        ON state_id = task_state.id
    ) tmp
    INNER JOIN _techsup_left.task
    ON tmp.task_id = task.id
    INNER JOIN _techsup_left.task_priority
    ON priority_id = task_priority.id
) AS t
WHERE t.datetime >= '2012-10-01' AND datetime <= ( SELECT current_timestamp )
ORDER BY t.datetime DESC
LIMIT 20;

-- students51
-- добавить новую заявку

INSERT INTO _techsup_left.task ( name, datetime, priority_id, client_id )
    VALUES( 'test', 
            (SELECT current_timestamp),
            1, 
            (
                SELECT id
                FROM _techsup_left.v_employee
                WHERE v_employee.login    LIKE 'anastas.sanina' AND
                      v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
            )            
           );

INSERT INTO _techsup_left.task_equipment ( task_id, equipment_id )
    VALUES( 
           (
                SELECT id
                FROM _techsup_left.task
                WHERE task.datetime = ( 
                    SELECT MAX( datetime )
                    FROM _techsup_left.task
                )  
           ),
           (
                SELECT id
                FROM _techsup_left.equipment
                WHERE LOWER( equipment.serial_number ) LIKE 'adm-999-9999-99-pc'
           )
          );


CREATE OR REPLACE FUNCTION _techsup_left.close_task (
                              in_task_id   INTEGER,
                              in_login     CHARACTER VARYING(64),
                              in_password  CHARACTER VARYING(128),
                              in_datetime  TIMESTAMP WITH TIME ZONE  
                           )
RETURNS INTEGER
AS $$
BEGIN

-- BEGIN TRANSACTION;

-- students51
-- закрыть заявку

IF NOT EXISTS (
    SELECT *
    FROM (
        SELECT name
        FROM _techsup_left.task_state
        INNER JOIN (
            SELECT state_id
            FROM _techsup_left.task_operation
            WHERE task_id = $1 AND datetime = (
                SELECT max_date
                FROM (
                    SELECT task_id, MAX( datetime ) AS max_date
                    FROM _techsup_left.task_operation
                    GROUP BY task_id
                ) AS tmp_date
                WHERE tmp_date.task_id = $1
            )
        ) AS tmp
        ON task_state.id = tmp.state_id 
    ) AS t
    WHERE LOWER( t.name ) = 'закрыта'
)
THEN
  INSERT INTO _techsup_left.task_operation( datetime, task_id, technic_id, state_id )
    VALUES(
      $4,
      in_task_id,
      (
        SELECT id
        FROM _techsup_left.v_employee
        WHERE v_employee.login    LIKE $2 AND
              v_employee.password LIKE $3
      ),
      (
        SELECT id
        FROM _techsup_left.task_state
        WHERE LOWER( task_state.name ) LIKE 'закрыта'
      )
    );
    RETURN 0;
ELSE
  RETURN 1;
END IF;

END;
$$ LANGUAGE plpgsql;

-- students51
-- изменить куратора заявки

UPDATE _techsup_left.task
    SET owner_id = (
            SELECT v_employee.id
            FROM _techsup_left.v_employee
            WHERE LOWER( v_employee.snils ) LIKE '275-985-770 30'
        )
    WHERE task.id = 40386;

-- students51
-- добавить куратора новой заявки

UPDATE _techsup_left.task
  SET owner_id = (
    SELECT id
    FROM _techsup_left.v_employee
    WHERE v_employee.login    LIKE 'anastas.sanina' AND
          v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
  )
  WHERE task.id = 40379;

INSERT INTO _techsup_left.task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
    (SELECT current_timestamp),
    40379,
    (
      SELECT id
      FROM _techsup_left.v_employee
      WHERE v_employee.login    LIKE 'anastas.sanina' AND
            v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
    ),
    (
      SELECT id
      FROM _techsup_left.task_state
      WHERE LOWER( task_state.name ) LIKE 'выполняется'
    )
  );

-- student52
-- удалить администратора

DELETE FROM _techsup_right.admins 
WHERE admins.employee_id =
    (
        SELECT id
        FROM _techsup_right.employee
        WHERE LOWER( employee.snils )  LIKE in_snils
    );

CREATE OR REPLACE FUNCTION _techsup_right.delete_equipment_owner(
                                        in_snils         CHARACTER VARYING( 16 ),
                                        in_serial_number CHARACTER VARYING( 128 ),
                                        in_datetime      TIMESTAMP WITH TIME ZONE                               
                                       )
RETURNS INTEGER
AS $$
BEGIN

-- START TRANSACTION;

-- student52
-- отписать владельца от оборудования

IF EXISTS (
  SELECT *
  FROM _techsup_right.equipment_owner
  WHERE equipment_owner.equipment_id = (
    SELECT id
    FROM _techsup_right.v_equipment
    WHERE LOWER( v_equipment.serial_number ) LIKE $2
  ) AND
  equipment_owner.employee_id = (
    SELECT id
    FROM _techsup_right.employee
    WHERE LOWER( employee.snils ) LIKE $1
  ) AND
  equipment_owner.finish_datetime IS NULL
)
THEN
  UPDATE _techsup_right.equipment_owner
    SET finish_datetime = $3
    WHERE equipment_owner.equipment_id = (
      SELECT id
      FROM _techsup_right.v_equipment
      WHERE LOWER( v_equipment.serial_number ) LIKE $2
    )  AND equipment_owner.employee_id = (
      SELECT id
      FROM _techsup_right.employee
      WHERE LOWER( employee.snils ) LIKE $1
    );
  RETURN 0;
ELSE
  RETURN 1;
END IF;

-- COMMIT;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _techsup_right.add_equipment_owner(
                                     in_snils         CHARACTER VARYING( 16 ),
                                     in_serial_number CHARACTER VARYING( 128 ),
                                     in_datetime      TIMESTAMP WITH TIME ZONE   
                                    )
RETURNS INTEGER
AS $$
BEGIN

-- START TRANSACTION;

-- добавить пользователя оборудованием

IF NOT EXISTS (
  SELECT *
  FROM _techsup_right.equipment_owner
  WHERE equipment_owner.equipment_id = (
    SELECT id
    FROM _techsup_right.v_equipment
    WHERE LOWER( v_equipment.serial_number ) LIKE $2
  ) AND
  equipment_owner.employee_id = (
    SELECT id
    FROM _techsup_right.employee
    WHERE LOWER( employee.snils ) LIKE $1
  ) AND
  equipment_owner.finish_datetime IS NULL
)
THEN
  INSERT INTO _techsup_right.equipment_owner ( equipment_id, employee_id, start_datetime )
      VALUES (
          (
              SELECT id
              FROM _techsup_right.v_equipment
              WHERE LOWER( v_equipment.serial_number ) LIKE $2
          ),
          (
              SELECT id
              FROM _techsup_right.employee
              WHERE LOWER( employee.snils )  LIKE $1
          ),
          $3
      );
  RETURN 0;
ELSE
  RETURN 1;
END IF;

--COMMIT;

END;
$$ LANGUAGE plpgsql;


-- students51
-- получить информацию о всех операциях 
-- с конкретным оборудованием

SELECT equipment_operation.id AS oper_id, 
       equipment_operation_type.name AS oper_name,
       tmp_repair.repair_id,
       datetime
FROM _techsup_left.equipment_operation
INNER JOIN (
    SELECT id AS equipment_id
    FROM _techsup_left.equipment
    WHERE LOWER( equipment.serial_number ) = 'issl-675-8635-84-pc' 
) AS t
ON equipment_operation.equipment_id = t.equipment_id
LEFT JOIN _techsup_left.equipment_operation_type
ON eq_oper_type_id = equipment_operation_type.id
LEFT JOIN (
    SELECT repair.equipment_operation_id AS repair_id
    FROM _techsup_left.repair
    WHERE repair.equipment_operation_id IN (
        SELECT id
        FROM _techsup_left.equipment_operation
        WHERE equipment_operation.equipment_id = (
            SELECT equipment.id
            FROM _techsup_left.equipment
            WHERE LOWER( equipment.serial_number ) LIKE 'issl-675-8635-84-pc'
        ) AND equipment_operation.eq_oper_type_id = ( 
            SELECT equipment_operation_type.id
            FROM _techsup_left.equipment_operation_type
            WHERE LOWER( equipment_operation_type.name ) = 'ремонт' )
    )
) AS tmp_repair
ON equipment_operation.id = tmp_repair.repair_id;

-- students51
-- получить информацию о всех ремонтах 
-- с конкретным оборудованием

SELECT repair.equipment_operation_id AS repair_id,
       detail_model.name AS detail_model,
       tmp_repair.detail_price,
       repair.comment,
       v_employee.name,
       v_employee.phone,
       repair.datetime
FROM _techsup_left.repair
RIGHT JOIN (
    SELECT id, detail_price
    FROM _techsup_left.equipment_operation
    WHERE equipment_operation.equipment_id = (
        SELECT equipment.id
        FROM _techsup_left.equipment
        WHERE LOWER( equipment.serial_number ) LIKE 'issl-675-8635-84-pc'
    ) AND equipment_operation.eq_oper_type_id = ( 
        SELECT equipment_operation_type.id
        FROM _techsup_left.equipment_operation_type
        WHERE LOWER( equipment_operation_type.name ) = 'ремонт'
    )
) AS tmp_repair
ON equipment_operation_id = tmp_repair.id
LEFT JOIN _techsup_left.detail_model
ON detail_model_id = detail_model.id
INNER JOIN _techsup_left.task_operation
ON repair.task_id = task_operation.task_id
LEFT JOIN _techsup_left.v_employee
ON technic_id = v_employee.id;

-- student51
-- получить всех владельцев конкретного оборудования
-- с последним изменением статуса (принят/уволен)

SELECT v_employee.id AS employee_id, v_employee.name,
       v_employee_role.name AS role,
       v_employee.phone, v_employee.login,
       tmp2.state, tmp2.date
FROM _techsup_left.v_employee
LEFT JOIN _techsup_left.v_employee_role
ON v_employee.role_id = v_employee_role.id
RIGHT JOIN (
    SELECT *
    FROM (
        -- id сотрудников  с последними изменёнными статусами
        SELECT v_employee_operation.employee_id, 
               v_employee_operation_type.name AS state,
               v_employee_operation.date
        FROM _techsup_left.v_employee_operation
        INNER JOIN (
            SELECT v_employee_operation.employee_id, MAX( v_employee_operation.date ) AS date
            FROM _techsup_left.v_employee_operation
            GROUP BY v_employee_operation.employee_id
        ) AS tmp1
        ON v_employee_operation.employee_id = tmp1.employee_id AND
           v_employee_operation.date = tmp1.date
        INNER JOIN _techsup_left.v_employee_operation_type
        ON type_id = v_employee_operation_type.id
    ) AS tmp
    WHERE tmp.employee_id IN (
        SELECT employee_id
        FROM _techsup_left.v_equipment_owner
        WHERE v_equipment_owner.equipment_id = (
            SELECT equipment.id
            FROM _techsup_left.equipment
            WHERE LOWER( equipment.serial_number ) LIKE 'comm-269-5195-31-proj'
        )
   )
) AS tmp2
ON v_employee.id = tmp2.employee_id
ORDER BY date, name;

-- students51
-- получить расходы по закупке деталей
-- для конкретного оборудования

SELECT tmp.sum_detail_price
FROM (
    SELECT equipment_id, SUM( detail_price ) AS sum_detail_price 
    FROM _techsup_left.equipment_operation
    GROUP BY equipment_id
) AS tmp
WHERE tmp.equipment_id = (
    SELECT id
    FROM _techsup_left.equipment
    WHERE LOWER( equipment.serial_number ) LIKE 'issl-675-8635-84-pc'
);

-- students51
-- выдать список топ-10 сотрудников, на ремонт
-- чьего оборудования потрачено больше всего денег :)

SELECT *
FROM (
    SELECT v_employee.snils,
           v_employee.name,
           tmp_summ.work_price,
           tmp_summ.detail_price,
           ( SELECT work_price + detail_price) AS summ
    FROM (
      SELECT tmp.client_id,
             SUM( tmp.work_price ) AS work_price,
             SUM( tmp.detail_price ) AS detail_price
      FROM (
          SELECT task_equipment.task_id, 
                 task_equipment.equipment_id,
                 task.client_id,       
                 tmp_task.work_price,
                 equipment_operation.detail_price
          FROM _techsup_left.task_equipment
          LEFT JOIN _techsup_left.task
          ON task_id = task.id
          LEFT JOIN (
              SELECT task_operation.task_id, work_price, task_operation.datetime
              FROM _techsup_left.task_operation
              RIGHT JOIN (
                 SELECT task_id, MAX( datetime ) AS datetime
                 FROM _techsup_left.task_operation
                 GROUP BY task_id, work_price
              ) t
              ON task_operation.datetime = t.datetime AND
                 task_operation.task_id = t.task_id
          ) AS tmp_task
          ON task_equipment.task_id = tmp_task.task_id
          LEFT JOIN _techsup_left.repair
          ON task_equipment.task_id = repair.task_id
          LEFT JOIN _techsup_left.equipment_operation
          ON repair.equipment_operation_id = equipment_operation.id
       ) AS tmp
      GROUP BY tmp.client_id
    ) AS tmp_summ
    LEFT JOIN _techsup_left.v_employee
    ON client_id = v_employee.id
) AS t_summ
WHERE t_summ.summ > 0
ORDER BY summ DESC
LIMIT 10;
