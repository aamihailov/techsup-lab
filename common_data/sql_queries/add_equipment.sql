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
            WHERE LOWER( equipment_model.name ) LIKE ?
        )
    );

INSERT INTO equipment_operation ( datetime, equipment_id, eq_oper_type_id )
    VALUES (
            ( SELECT NOW() ),
            (
                SELECT id
                FROM equipment
                WHERE LOWER( equipment.serial_number ) LIKE ?
            ),
            (
                SELECT id
                FROM equipment_operation_type
                WHERE LOWER( equipment_operation_type.name ) = 'поступление'
            )
   );

COMMIT;

