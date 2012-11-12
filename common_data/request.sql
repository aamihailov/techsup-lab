-- students51
-- получить информацию околичестве выполненных заявок
-- для конкретного работника по приоритетам заявок

SELECT id, name, priority, COUNT(*)
FROM (
    SELECT v_employee.id, v_employee.snils, v_employee.name,
           tmp.task_id, tmp.priority_id,
           task_priority.name AS priority
    FROM _techsup_left.v_employee
    RIGHT JOIN (
        SELECT owner_id, task.id AS task_id, task.priority_id
        FROM _techsup_left.task
        WHERE id IN (
            SELECT task_id
            FROM _techsup_left.task_operation
            WHERE task_operation.state_id = (
                SELECT id
                FROM _techsup_left.task_state
                WHERE LOWER( task_state.name ) = 'закрыта'
            )
        )
    ) AS tmp
    ON v_employee.id = tmp.owner_id
    RIGHT JOIN _techsup_left.task_priority
    ON priority_id = task_priority.id
) AS tmp1
WHERE priority_id > 0  AND snils LIKE '275-985-770 30'
GROUP BY id, priority, name;

-- students51
-- просмотреть очередь заявок с последним
-- изменённым статусом для пользователя

DROP TABLE IF EXISTS tmp_task;
CREATE TEMPORARY TABLE tmp_task AS
    SELECT task.id, task_priority.name AS priority, task.name AS task
    FROM _techsup_left.task
    INNER JOIN _techsup_left.task_priority
    ON task.priority_id = task_priority.id;

DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp AS
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
    ON state_id = task_state.id;

SELECT *
FROM (
    SELECT tmp.task_id, 
           task_priority.name AS priority,
           task.name AS task,
           tmp.name AS technic,
           tmp.state, tmp.datetime
    FROM tmp
    INNER JOIN _techsup_left.task
    ON tmp.task_id = task.id
    INNER JOIN _techsup_left.task_priority
    ON priority_id = task_priority.id
) AS t
WHERE t.datetime >= '2012-10-01' AND datetime <= ( SELECT current_timestamp )
ORDER BY t.datetime;

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
