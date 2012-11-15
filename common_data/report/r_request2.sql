-- ##########################################################################
-- #     # 2,016.557 ms                                                     #
-- #  1. #                                                                  #
-- #     #                                                                  #
-- ##########################################################################

-- students52
-- �������� ���������� ����������� ����������� ������
-- ��� ����������� ��������� �� ����������� ������

CREATE OR REPLACE FUNCTION _techsup_right2.get_sum_task_for_employee_priority(
                                     in_snils       CHARACTER VARYING(16),
                                     in_priority    CHARACTER VARYING(255)
                                     )
RETURNS INTEGER
AS $$

BEGIN

RETURN (
    SELECT COUNT( * ) 
    FROM (
        SELECT v_task.id
        FROM _techsup_right2.v_task
        WHERE id IN (
            SELECT task_id
            FROM _techsup_right2.task_operation
            WHERE task_operation.state_id = (
                SELECT id
                FROM _techsup_right2.task_state
                WHERE LOWER( task_state.name ) = '�������'
            )
        ) AND
        owner_id = (
            SELECT id
            FROM _techsup_right2.employee
            WHERE LOWER( employee.snils ) LIKE $1
        ) AND
        v_task.priority_id = ( 
            SELECT id
            FROM _techsup_right2.v_task_priority
            WHERE LOWER( v_task_priority.name ) = $2
        )    
    ) AS tmp
);

END;
$$ LANGUAGE plpgsql;

SELECT tmp.snils,
       tmp.name,
       (
        SELECT _techsup_right2.get_sum_task_for_employee_priority(tmp.snils, '����� ������' )
       ) AS "P1",
       (
        SELECT _techsup_right2.get_sum_task_for_employee_priority(tmp.snils, '������' )
       ) AS "P2",
       (
        SELECT _techsup_right2.get_sum_task_for_employee_priority(tmp.snils, '�������' )
       ) AS "P3",
       (
        SELECT _techsup_right2.get_sum_task_for_employee_priority(tmp.snils, '�������' )
       ) AS "P4",
       (
        SELECT _techsup_right2.get_sum_task_for_employee_priority(tmp.snils, '����� �������' )
       ) AS "P5"
FROM _techsup_right2.employee
RIGHT JOIN (
  SELECT id, name, snils
  FROM _techsup_right2.employee
  WHERE employee.role_id = (
            SELECT id
            FROM _techsup_right2.employee_role
            WHERE LOWER( employee_role.name ) = '������'
  ) 
--  LIMIT 10
  AND employee.snils = '071-630-281 12'
) AS tmp
ON employee.id = tmp.id;

-- ##########################################################################
-- #     # 1,219.065 ms                                                     #
-- #  2. #                                                                  #
-- #     #                                                                  #
-- ##########################################################################

-- students52
-- ����������� ������� ������ � ���������
-- ����Σ���� �������� ��� ������������

SELECT *
FROM (
    SELECT tmp.task_id, 
           v_task_priority.name AS priority,
           v_task.name AS task,
           tmp.name AS technic,
           tmp.state, tmp.datetime
    FROM (
        SELECT task_operation.task_id, 
               employee.name,
               task_state.name AS state, task_operation.datetime 
        FROM _techsup_right2.task_operation
        INNER JOIN (
            SELECT task_operation.task_id, MAX( task_operation.datetime ) AS date
            FROM _techsup_right2.task_operation
            GROUP BY task_operation.task_id
        ) AS temp
        ON task_operation.task_id = temp.task_id AND
           task_operation.datetime = temp.date
        LEFT JOIN _techsup_right2.employee
        ON technic_id = employee.id
        INNER JOIN _techsup_right2.task_state 
        ON state_id = task_state.id
    ) tmp
    INNER JOIN _techsup_right2.v_task
    ON tmp.task_id = v_task.id
    INNER JOIN _techsup_right2.v_task_priority
    ON priority_id = v_task_priority.id
) AS t
WHERE t.datetime >= '2012-10-01' AND datetime <= ( SELECT current_timestamp )
ORDER BY t.datetime DESC
LIMIT 50;

-- ################################################################
-- #     # 104.021 ms                                             #
-- #  3. # 104.915 ms 107.213 ms 105.275 ms 103.798 ms 104.029 ms #
-- #     # 106.566 ms 101.977 ms 101.548 ms 100.460 ms 104.430 ms #
-- ################################################################

SELECT *
FROM task
WHERE client_id = 2939

-- students51
-- �������� ����� ������

INSERT INTO _techsup_left2.task ( name, datetime, priority_id, client_id )
    VALUES( 'test', 
            (SELECT current_timestamp),
            1, 
            (
                SELECT id
                FROM _techsup_left2.v_employee
                WHERE v_employee.login    LIKE 'anastas.sanina' AND
                      v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
            )            
           );

INSERT INTO _techsup_left2.task_equipment ( task_id, equipment_id )
    VALUES( 
           (
                SELECT id
                FROM _techsup_left2.task
                WHERE task.datetime = ( 
                    SELECT MAX( datetime )
                    FROM _techsup_left2.task
                )  
           ),
           (
                SELECT id
                FROM _techsup_left2.equipment
                WHERE LOWER( equipment.serial_number ) LIKE 'adm-999-9999-99-pc'
           )
          );

-- ################################################################
-- #     # 10.650 ms                                              #
-- #  4. # 10.266 ms 10.891 ms 10.043 ms 10.951 ms 10.772 ms      #
-- #     # 10.772 ms 10.031 ms 11.182 ms 11.230 ms 10.357 ms      #
-- ################################################################

SELECT _techsup_right2.close_task ( 40391, 'anastas.sanina', 'e0fb2a62faafc09122d2e613b8a8118d', (SELECT current_timestamp) )

CREATE OR REPLACE FUNCTION _techsup_right2.close_task (
                              in_task_id   INTEGER,
                              in_login     CHARACTER VARYING(64),
                              in_password  CHARACTER VARYING(128),
                              in_datetime  TIMESTAMP WITH TIME ZONE  
                           )
RETURNS INTEGER
AS $$
BEGIN

-- students52
-- ������� ������

IF NOT EXISTS (
    SELECT *
    FROM (
        SELECT name
        FROM _techsup_right2.task_state
        INNER JOIN (
            SELECT state_id
            FROM _techsup_right2.task_operation
            WHERE task_id = $1 AND datetime = (
                SELECT max_date
                FROM (
                    SELECT task_id, MAX( datetime ) AS max_date
                    FROM _techsup_right2.task_operation
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
    FROM _techsup_right2.v_task
    WHERE v_task.id = $1
  )
  THEN
    INSERT INTO _techsup_right2.task_operation( datetime, task_id, technic_id, state_id )
      VALUES(
        $4,
        $1,
        (
          SELECT id
          FROM _techsup_right2.employee
          WHERE employee.login    LIKE $2 AND
                employee.password LIKE $3
        ),
        (
          SELECT id
          FROM _techsup_right2.task_state
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
-- #     # 89.661 ms                                              #
-- #  6. # 93.439 ms 88.970 ms 87.114 ms 89.203 ms 84.043 ms      #
-- #     # 88.028 ms 88.890 ms 95.585 ms 93.298 ms 88.041 ms      #
-- ################################################################

-- students51
-- �������� �������� ����� ������

UPDATE _techsup_left2.task
  SET owner_id = (
    SELECT id
    FROM _techsup_left2.v_employee
    WHERE v_employee.login    LIKE 'anastas.sanina' AND
          v_employee.password LIKE 'e0fb2a62faafc09122d2e613b8a8118d'
  )
  WHERE task.id = 40391;

SELECT *
FROM
public.dblink (
'dbname=students52 user=pmm8101 password=retodarn',
'
INSERT INTO _techsup_right2.task_operation( datetime, task_id, technic_id, state_id )
  VALUES(
    (SELECT current_timestamp),
    40391,
    (
      SELECT id
      FROM _techsup_right2.employee
      WHERE employee.login    LIKE \'anastas.sanina\' AND
            employee.password LIKE \'e0fb2a62faafc09122d2e613b8a8118d\'
    ),
    (
      SELECT id
      FROM _techsup_right2.task_state
      WHERE LOWER( task_state.name ) LIKE \'�����������\'
    )
  );
SELECT 0 AS rez;'
) AS tmp (rez INTEGER);

-- ################################################################
-- #     # 123.382 ms                                             #
-- #  8. # 121.989 ms 122.991 ms 126.008 ms 124.004 ms 125.612 ms #
-- #     # 123.424 ms 124.213 ms 121.873 ms 121.122 ms 122.579 ms #
-- ################################################################

CREATE OR REPLACE FUNCTION _techsup_left2.delete_equipment_owner(
                                        in_snils         CHARACTER VARYING( 16 ),
                                        in_serial_number CHARACTER VARYING( 128 ),
                                        in_datetime      TIMESTAMP WITH TIME ZONE                               
                                       )
RETURNS INTEGER
AS $$
BEGIN

-- student51
-- �������� ��������� �� ������������

IF EXISTS (
  SELECT *
  FROM _techsup_left2.equipment_owner
  WHERE equipment_owner.equipment_id = (
    SELECT id
    FROM _techsup_left2.equipment
    WHERE LOWER( equipment.serial_number ) LIKE $2
  ) AND
  equipment_owner.employee_id = (
    SELECT id
    FROM _techsup_left2.v_employee
    WHERE LOWER( v_employee.snils ) LIKE $1
  ) AND
  equipment_owner.finish_datetime IS NULL
)
THEN
  UPDATE _techsup_left2.equipment_owner
    SET finish_datetime = $3
    WHERE equipment_owner.equipment_id = (
      SELECT id
      FROM _techsup_left2.equipment
      WHERE LOWER( equipment.serial_number ) LIKE $2
    )  AND equipment_owner.employee_id = (
      SELECT id
      FROM _techsup_left2.v_employee
      WHERE LOWER( v_employee.snils ) LIKE $1
    );
  RETURN 0;
ELSE
  RETURN 1;
END IF;

END;
$$ LANGUAGE plpgsql;

-- ################################################################
-- #     # 126.820 ms                                             #
-- #  9. # 120.568 ms 132.879 ms 131.774 ms 122.204 ms 118.156 ms #
-- #     # 122.956 ms 135.949 ms 125.709 ms 130.593 ms 127.414 ms #
-- ################################################################

SELECT _techsup_left2.add_equipment_owner('999-999-999 99', 
                                          'comm-269-5195-31-proj',
                                          (SELECT current_timestamp) 
                                         );

SELECT _techsup_left2.delete_equipment_owner('999-999-999 99', 
                                             'comm-269-5195-31-proj',
                                             (SELECT current_timestamp) 
                                            );

CREATE OR REPLACE FUNCTION _techsup_left2.add_equipment_owner(
                                     in_snils         CHARACTER VARYING( 16 ),
                                     in_serial_number CHARACTER VARYING( 128 ),
                                     in_datetime      TIMESTAMP WITH TIME ZONE   
                                    )
RETURNS INTEGER
AS $$
BEGIN

-- student51
-- �������� ������������ �������������

IF NOT EXISTS (
  SELECT *
  FROM _techsup_left2.equipment_owner
  WHERE equipment_owner.equipment_id = (
    SELECT id
    FROM _techsup_left2.equipment
    WHERE LOWER( equipment.serial_number ) LIKE $2
  ) AND
  equipment_owner.employee_id = (
    SELECT id
    FROM _techsup_left2.v_employee
    WHERE LOWER( v_employee.snils ) LIKE $1
  ) AND
  equipment_owner.finish_datetime IS NULL
)
THEN
  INSERT INTO _techsup_left2.equipment_owner ( equipment_id, employee_id, start_datetime )
      VALUES (
          (
              SELECT id
              FROM _techsup_left2.equipment
              WHERE LOWER( equipment.serial_number ) LIKE $2
          ),
          (
              SELECT id
              FROM _techsup_left2.v_employee
              WHERE LOWER( v_employee.snils )  LIKE $1
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
-- #      # 19.601 ms                                             # 
-- #  10. # 20.247 ms 19.477 ms 19.557 ms 19.515 ms 19.583 ms     #
-- #      # 19.380 ms 19.775 ms 19.481 ms 19.521 ms 19.479 ms     #
-- ################################################################

-- students51
-- �������� ���������� � ���� ��������� 
-- � ���������� �������������

SELECT equipment_operation.id AS oper_id, 
       equipment_operation_type.name AS oper_name,
       tmp_repair.repair_id,
       datetime
FROM _techsup_left2.equipment_operation
INNER JOIN (
    SELECT id AS equipment_id
    FROM _techsup_left2.equipment
    WHERE LOWER( equipment.serial_number ) = 'issl-675-8635-84-pc' 
) AS t
ON equipment_operation.equipment_id = t.equipment_id
LEFT JOIN _techsup_left2.equipment_operation_type
ON eq_oper_type_id = equipment_operation_type.id
LEFT JOIN (
    SELECT repair.equipment_operation_id AS repair_id
    FROM _techsup_left2.repair
    WHERE repair.equipment_operation_id IN (
        SELECT id
        FROM _techsup_left2.equipment_operation
        WHERE equipment_operation.equipment_id = (
            SELECT equipment.id
            FROM _techsup_left2.equipment
            WHERE LOWER( equipment.serial_number ) LIKE 'issl-675-8635-84-pc'
        ) AND equipment_operation.eq_oper_type_id = ( 
            SELECT equipment_operation_type.id
            FROM _techsup_left2.equipment_operation_type
            WHERE LOWER( equipment_operation_type.name ) = '������' )
    )
) AS tmp_repair
ON equipment_operation.id = tmp_repair.repair_id;

-- #################################################################
-- #      # 581.764 ms                                             # 
-- #  11. # 549.368 ms 571.817 ms 617.670 ms 556.791 ms 566.423 ms #
-- #      # 603.653 ms 542.834 ms 600.904 ms 602.480 ms 605.695 ms #
-- #################################################################

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
FROM _techsup_left2.repair
RIGHT JOIN (
    SELECT id, detail_price
    FROM _techsup_left2.equipment_operation
    WHERE equipment_operation.equipment_id = (
        SELECT equipment.id
        FROM _techsup_left2.equipment
        WHERE LOWER( equipment.serial_number ) LIKE 'issl-675-8635-84-pc'
    ) AND equipment_operation.eq_oper_type_id = ( 
        SELECT equipment_operation_type.id
        FROM _techsup_left2.equipment_operation_type
        WHERE LOWER( equipment_operation_type.name ) = '������'
    )
) AS tmp_repair
ON equipment_operation_id = tmp_repair.id
LEFT JOIN _techsup_left2.detail_model
ON detail_model_id = detail_model.id
INNER JOIN _techsup_left2.v_task_operation
ON repair.task_id = v_task_operation.task_id
LEFT JOIN _techsup_left2.v_employee
ON technic_id = v_employee.id;

-- #################################################################
-- #      # 721.113 ms                                             #
-- #  12. # 740.374 ms 704.532 ms 733.430 ms 722.341 ms 703.663 ms #
-- #      # 731.382 ms 719.817 ms 712.845 ms 736.289 ms 706.456 ms #
-- #################################################################

-- student51
-- �������� ���� ���������� ����������� ������������
-- � ��������� ���������� ������� (������/������)

SELECT v_employee.id AS employee_id, v_employee.name,
       v_employee_role.name AS role,
       v_employee.phone, v_employee.login,
       tmp2.state, tmp2.date
FROM _techsup_left2.v_employee
LEFT JOIN _techsup_left2.v_employee_role
ON v_employee.role_id = v_employee_role.id
RIGHT JOIN (
    SELECT *
    FROM (
        -- id �����������  � ���������� ����Σ����� ���������
        SELECT v_employee_operation.employee_id, 
               v_employee_operation_type.name AS state,
               v_employee_operation.date
        FROM _techsup_left2.v_employee_operation
        INNER JOIN (
            SELECT v_employee_operation.employee_id, MAX( v_employee_operation.date ) AS date
            FROM _techsup_left2.v_employee_operation
            GROUP BY v_employee_operation.employee_id
        ) AS tmp1
        ON v_employee_operation.employee_id = tmp1.employee_id AND
           v_employee_operation.date = tmp1.date
        INNER JOIN _techsup_left2.v_employee_operation_type
        ON type_id = v_employee_operation_type.id
    ) AS tmp
    WHERE tmp.employee_id IN (
        SELECT employee_id
        FROM _techsup_left2.equipment_owner
        WHERE equipment_owner.equipment_id = (
            SELECT equipment.id
            FROM _techsup_left2.equipment
            WHERE LOWER( equipment.serial_number ) LIKE 'comm-269-5195-31-proj'
        )
   )
) AS tmp2
ON v_employee.id = tmp2.employee_id
ORDER BY date, name;

-- ###########################################################################
-- #      # 1,498.295 ms                                                     #
-- #  13. # 1,527.179 ms 1,538.198 ms 1,518.478 ms 1,508.554 ms 1,455.657 ms #
-- #      # 1,464.321 ms 1,497.542 ms 1,455.673 ms 1,576.688 ms 1,440.656 ms #
-- ###########################################################################

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
          FROM _techsup_left2.task_equipment
          LEFT JOIN _techsup_left2.task
          ON task_id = task.id
          LEFT JOIN (
              SELECT v_task_operation.task_id, work_price, v_task_operation.datetime
              FROM _techsup_left2.v_task_operation
              RIGHT JOIN (
                 SELECT task_id, MAX( datetime ) AS datetime
                 FROM _techsup_left2.v_task_operation
                 GROUP BY task_id, work_price
              ) t
              ON v_task_operation.datetime = t.datetime AND
                 v_task_operation.task_id = t.task_id
          ) AS tmp_task
          ON task_equipment.task_id = tmp_task.task_id
          LEFT JOIN _techsup_left2.repair
          ON task_equipment.task_id = repair.task_id
          LEFT JOIN _techsup_left2.equipment_operation
          ON repair.equipment_operation_id = equipment_operation.id
       ) AS tmp
      GROUP BY tmp.client_id
    ) AS tmp_summ
    LEFT JOIN _techsup_left2.v_employee
    ON client_id = v_employee.id
) AS t_summ
WHERE t_summ.summ > 0
ORDER BY summ DESC
LIMIT 10;
