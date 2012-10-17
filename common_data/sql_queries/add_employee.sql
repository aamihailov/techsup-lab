START TRANSACTION;

-- принять сотрудника на работу

INSERT INTO employee ( name, phone, email, addr, login, password, role_id, group_id )
    VALUES(
        in_name, in_phone, in_email, in_addr, in_login, 
        in_password,
        (
            SELECT id
            FROM employee_role
            WHERE LOWER( employee_role.name ) LIKE ?
        ),
        (
            SELECT id
            FROM rights_group
            WHERE LOWER( rights_group.name ) LIKE ?
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
            WHERE LOWER( employee.name )  LIKE ? AND
                  LOWER( employee.phone ) LIKE ?
        ),
        (
            SELECT id
            FROM department
            WHERE LOWER( department.name ) LIKE ?
        )
    ); 

INSERT INTO equipment_owner ( equipment_id, employee_id )
    VALUES (
        (
            SELECT id
            FROM equipment
            WHERE equipment.serial_number LIKE ?
        ),
        (
            SELECT id
            FROM employee
            WHERE LOWER( employee.name )  LIKE ? AND
                  LOWER( employee.phone ) LIKE ?
        )
    );

COMMIT;


