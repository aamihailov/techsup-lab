-- ################################################################
-- #     # 404.948 ms                                             #
-- #  1. # 402.784 ms 402.573 ms 392.498 ms 392.498 ms 399.055 ms #
-- #     # 410.788 ms 408.153 ms 402.275 ms 423.184 ms 415.672 ms #
-- ################################################################

-- students51
-- �������� ���������� ����������� ����������� ������
-- ��� ����������� ��������� �� ����������� ������

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
                WHERE LOWER( task_state.name ) = '�������'
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

SELECT tmp.snils,
       tmp.name,
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority(tmp.snils, '����� ������' )
       ) AS "P1",
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority(tmp.snils, '������' )
       ) AS "P2",
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority(tmp.snils, '�������' )
       ) AS "P3",
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority(tmp.snils, '�������' )
       ) AS "P4",
       (
        SELECT _techsup_left.get_sum_task_for_employee_priority(tmp.snils, '����� �������' )
       ) AS "P5"
FROM _techsup_left.v_employee
RIGHT JOIN (
  SELECT id, name, snils
  FROM _techsup_left.v_employee
  WHERE v_employee.role_id = (
            SELECT id
            FROM _techsup_left.v_employee_role
            WHERE LOWER( v_employee_role.name ) = '������'
  ) 
--  LIMIT 10
  AND v_employee.snils = '071-630-281 12'
) AS tmp
ON v_employee.id = tmp.id;


-- ################################################################
-- #     # 166.575 ms                                             #
-- #  2. # 165.695 ms 162.633 ms 167.272 ms 172.171 ms 166.191 ms #
-- #     # 167.028 ms 165.708 ms 161.371 ms 173.329 ms 164.354 ms #
-- ################################################################

-- students51
-- ����������� ������� ������ � ���������
-- ����Σ���� �������� ��� ������������

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
LIMIT 50;

-- ################################################################
-- #     # 110.092                                                #
-- #  3. # 202.631 ms 108.437 ms 97.396 ms 99.868 ms 96.568 ms    #
-- #     # 97.911  ms 102.131 ms 97.440 ms 99.263 ms 99.279 ms    #
-- ################################################################

SELECT *
FROM task
WHERE client_id = 2939

-- students51
-- �������� ����� ������

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










-- ################################################################
-- #     # 61.205 ms                                              #
-- #  4. # 61.006 ms 63.443 ms 64.887 ms 59.663 ms 60.732 ms      #
-- #     # 58.010 ms 60.835 ms 62.247 ms 61.046 ms 60.181 ms      #
-- ################################################################

CREATE OR REPLACE FUNCTION _techsup_left.close_task (
                              in_task_id   INTEGER,
                              in_login     CHARACTER VARYING(64),
                              in_password  CHARACTER VARYING(128),
                              in_datetime  TIMESTAMP WITH TIME ZONE  
                           )
RETURNS INTEGER
AS $$
BEGIN

-- students51
-- ������� ������

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
    WHERE LOWER( t.name ) = '�������'
)
THEN
  IF EXISTS (
    SELECT *
    FROM _techsup_left.task
    WHERE task.id = $1
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
          WHERE LOWER( task_state.name ) LIKE '�������'
        )
      );
      RETURN 0;
  ELSE 
    RETURN 1;
  END IF;
ELSE
  RETURN 1;
END IF;

END;
$$ LANGUAGE plpgsql;

-- ################################################################
-- #     # 112.674 ms                                             #
-- #  6. # 115.815 ms 105.846 ms 111.816 ms 127.358 ms 108.690 ms #
-- #     # 105.425 ms 111.667 ms 121.037 ms 115.508 ms 103.582 ms #
-- ################################################################

-- students51
-- �������� �������� ����� ������

UPDATE _techsup_left.task
  SET owner_id = (
    SELECT id
    FROM _techsup_left.v_employee
    WHERE v_employee.login    LIKE 'anastas.sanina' AND
          v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
  )
  WHERE task.id = 40380;

INSERT INTO _techsup_left.task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
    (SELECT current_timestamp),
    40380,
    (
      SELECT id
      FROM _techsup_left.v_employee
      WHERE v_employee.login    LIKE 'anastas.sanina' AND
            v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
    ),
    (
      SELECT id
      FROM _techsup_left.task_state
      WHERE LOWER( task_state.name ) LIKE '�����������'
    )
  );

-- ################################################################
-- #     # 133.872 ms                                             #
-- #  8. # 130.312 ms 133.521 ms 127.746 ms 131.446 ms 133.772 ms #
-- #     # 137.049 ms 142.584 ms 130.204 ms 138.737 ms 133.349 ms #
-- ################################################################

CREATE OR REPLACE FUNCTION _techsup_right.delete_equipment_owner(
                                        in_snils         CHARACTER VARYING( 16 ),
                                        in_serial_number CHARACTER VARYING( 128 ),
                                        in_datetime      TIMESTAMP WITH TIME ZONE                               
                                       )
RETURNS INTEGER
AS $$
BEGIN

-- student52
-- �������� ��������� �� ������������

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

END;
$$ LANGUAGE plpgsql;


-- ################################################################
-- #     # 133.596 ms                                             #
-- #  9. # 136.873 ms 133.297 ms 130.528 ms 137.117 ms 131.556 ms #
-- #     # 135.043 ms 130.402 ms 133.006 ms 136.537 ms 131.600 ms #
-- ################################################################

SELECT _techsup_right.add_equipment_owner('999-999-999 99', 
                                          'comm-269-5195-31-proj',
                                          (SELECT current_timestamp) 
                                         );

SELECT _techsup_right.delete_equipment_owner('999-999-999 99', 
                                             'comm-269-5195-31-proj',
                                             (SELECT current_timestamp) 
                                            );

CREATE OR REPLACE FUNCTION _techsup_right.add_equipment_owner(
                                     in_snils         CHARACTER VARYING( 16 ),
                                     in_serial_number CHARACTER VARYING( 128 ),
                                     in_datetime      TIMESTAMP WITH TIME ZONE   
                                    )
RETURNS INTEGER
AS $$
BEGIN

-- student52
-- �������� ������������ �������������

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

END;
$$ LANGUAGE plpgsql;

-- ################################################################
-- #      # 20.714 ms                                             # 
-- #  10. # 34.612 ms 19.045 ms 19.300 ms 19.300 ms 19.365 ms     #
-- #      # 19.091 ms 19.339 ms 19.082 ms 19.045 ms 18.967 ms     #
-- ################################################################

-- students51
-- �������� ���������� � ���� ��������� 
-- � ���������� �������������

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
            WHERE LOWER( equipment_operation_type.name ) = '������' )
    )
) AS tmp_repair
ON equipment_operation.id = tmp_repair.repair_id;












-- ################################################################
-- #      # 71.110 ms                                             # 
-- #  11. # 100.678 ms 67.972 ms 71.795 ms 66.167 ms 69.590 ms    #
-- #      # 67.663 ms  68.183 ms 67.692 ms 66.716 ms 64.644 ms    #
-- ################################################################

-- students51
-- �������� ���������� � ���� �������� 
-- � ���������� �������������

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
        WHERE LOWER( equipment_operation_type.name ) = '������'
    )
) AS tmp_repair
ON equipment_operation_id = tmp_repair.id
LEFT JOIN _techsup_left.detail_model
ON detail_model_id = detail_model.id
INNER JOIN _techsup_left.task_operation
ON repair.task_id = task_operation.task_id
LEFT JOIN _techsup_left.v_employee
ON technic_id = v_employee.id;

-- #################################################################
-- #      # 812.315 ms                                             #
-- #  12. # 831.572 ms 802.932 ms 807.817 ms 857.147 ms 838.478 ms #
-- #      # 829.563 ms 846.976 ms 731.750 ms 848.961 ms 727.956 ms #
-- #################################################################

-- student51
-- �������� ���� ���������� ����������� ������������
-- � ��������� ���������� ������� (������/������)

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
        -- id �����������  � ���������� ����Σ����� ���������
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








-- #################################################################
-- #      # 533.084 ms                                             #
-- #  13. # 547.901 ms 499.029 ms 545.415 ms 554.838 ms 540.852 ms #
-- #      # 488.694 ms 550.282 ms 530.775 ms 535.901 ms 537.152 ms #
-- #################################################################

-- students51
-- ������ ������ ���-10 �����������, �� ������
-- ����� ������������ ��������� ������ ����� ����� :)

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
