-- ############################################################
-- # представления для узла students51                           #
-- ############################################################

CREATE VIEW _techsup_left.v_equipment_owner AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.equipment_owner'
    ) as tmp (
        id              INTEGER,
        start_datetime  TIMESTAMP WITH TIME ZONE,
        finish_datetime TIMESTAMP WITH TIME ZONE,
        equipment_id    INTEGER,
        employee_id     INTEGER
    );

CREATE VIEW _techsup_left.v_technics AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.technics'
    ) as tmp (
        employee_id INTEGER
    );

CREATE VIEW _techsup_left.v_employee AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.employee'
    ) as tmp (
        id          INTEGER,
        snils       CHARACTER VARYING(16),
        name        CHARACTER VARYING(255),
        phone       CHARACTER VARYING(32),
        addr        CHARACTER VARYING(512),
        login       CHARACTER VARYING(64),
        password    CHARACTER VARYING(128), 
        role_id     INTEGER
    );

CREATE VIEW _techsup_left.v_employee_role AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.employee_role'
    ) as tmp (
        id      INTEGER,
        name    CHARACTER VARYING(255)
    );

CREATE VIEW _techsup_left.v_admins AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.admins'
    ) as tmp (
        employee_id     INTEGER
    );

CREATE VIEW _techsup_left.v_department AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.department'
    ) as tmp (
        id                  INTEGER,
        name                CHARACTER VARYING(255),
        phone               CHARACTER VARYING(32),
        email               CHARACTER VARYING(75),
        addr                CHARACTER VARYING(512),
        exist_now           BOOLEAN,
        activity_sphere_id  INTEGER
    );

CREATE VIEW _techsup_left.v_department_activity_sphere AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.department_activity_sphere'
    ) as tmp (
        id    INTEGER,
        name  CHARACTER VARYING(255)
    );

CREATE VIEW _techsup_left.v_employee_operation AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.employee_operation'
    ) as tmp (
        id              INTEGER,
        date            DATE,
        type_id         INTEGER,
        employee_id     INTEGER,
        department_id   INTEGER
    );

CREATE VIEW _techsup_left.v_employee_operation_type AS
SELECT *
FROM 
    public.dblink
    ('dbname=students52 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_right.employee_operation_type'
    ) as tmp (
        id    INTEGER,
        name  CHARACTER VARYING(255)
    );

-- ############################################################
-- # представления для узла students52                            #
-- ############################################################

CREATE VIEW _techsup_right.v_detail_model AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.detail_model'
    ) as tmp (
        id          INTEGER,
        name        CHARACTER VARYING(255),
        category_id INTEGER
    );

CREATE VIEW _techsup_right.v_detail_category AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.detail_category'
    ) as tmp (
        id    INTEGER,
        name  CHARACTER VARYING(255)
    );

CREATE VIEW _techsup_right.v_repair AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.repair'
    ) as tmp (
        id                      INTEGER,
        comment                 CHARACTER VARYING(512),
        datetime                TIMESTAMP WITH TIME ZONE,
        detail_model_id         INTEGER,
        equipment_operation_id  INTEGER,
        task_id                 INTEGER
    );

CREATE VIEW _techsup_right.v_equipment_operation AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.equipment_operation'
    ) as tmp (
        id              INTEGER,
        detail_price    DOUBLE PRECISION,    
        datetime        TIMESTAMP WITH TIME ZONE,
        equipment_id    INTEGER,
        eq_oper_type_id INTEGER
    );

CREATE VIEW _techsup_right.v_equipment_operation_type AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.equipment_operation_type'
    ) as tmp (
        id    INTEGER,
        name  CHARACTER VARYING(255) 
    );

CREATE VIEW _techsup_right.v_task AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.task'
    ) as tmp (
        id              INTEGER,
        name            CHARACTER VARYING(255),
        datetime        TIMESTAMP WITH TIME ZONE,
        priority_id     INTEGER,
        client_id       INTEGER,
        owner_id        INTEGER
    );

CREATE VIEW _techsup_right.v_task_priority AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.task_priority'
    ) as tmp (
        id    INTEGER,
        name  CHARACTER VARYING(255)
    );

CREATE VIEW _techsup_right.v_equipment AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.equipment'
    ) as tmp (
        id                  INTEGER,
        name                CHARACTER VARYING(255),
        serial_number       CHARACTER VARYING(255),
        addr                CHARACTER VARYING(512),
        equipment_model_id  INTEGER
    );

CREATE VIEW _techsup_right.v_equipment_model AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.equipment_model'
    ) as tmp (
        id              INTEGER,
        name            CHARACTER VARYING(255),
        category_id     INTEGER
    );

CREATE VIEW _techsup_right.v_equipment_category AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.equipment_category'
    ) as tmp (
        id      INTEGER,
        name    CHARACTER VARYING(255)
    );

CREATE VIEW _techsup_right.v_task_operation AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.task_operation'
    ) as tmp (
        id              INTEGER,
        work_price      DOUBLE PRECISION, 
        datetime        TIMESTAMP WITH TIME ZONE,
        task_id         INTEGER,
        technic_id      INTEGER,
        state_id        INTEGER
    );

CREATE VIEW _techsup_right.v_task_state AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.task_state'
    ) as tmp (
        id      INTEGER,
        name    CHARACTER VARYING(255)
    );

CREATE VIEW _techsup_right.v_task_equipment AS
SELECT *
FROM 
    public.dblink
    ('dbname=students51 user=pmm8101 password=retodarn',
    'SELECT * FROM _techsup_left.task_equipment'
    ) as tmp (
        id              INTEGER,
        task_id         INTEGER,
        equipment_id    INTEGER
    );
