DROP PROCEDURE IF EXISTS add_employee_with_date;
CREATE PROCEDURE add_employee_with_date(
                               IN in_name       VARCHAR( 128 ),
                               IN in_phone      VARCHAR( 32 ),
                               IN in_email      VARCHAR( 75 ),
                               IN in_addr       VARCHAR( 256 ),
                               IN in_login      VARCHAR( 64 ),
                               IN in_password   VARCHAR( 128 ),
                               IN in_role_name  VARCHAR( 128 ),
                               IN in_group_name VARCHAR( 128 ),
                               IN in_department_name VARCHAR( 128 ),
                               IN in_date DATE
                             )
BEGIN

START TRANSACTION;

-- принять сотрудника на работу

INSERT INTO employee ( name, phone, email, addr, login, password, role_id, group_id )
    VALUES(
        in_name, in_phone, in_email, in_addr, in_login, 
        in_password,
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
        in_date,
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

COMMIT;

END$$
