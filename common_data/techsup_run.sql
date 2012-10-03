BEGIN;
CREATE TABLE "department" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "phone" varchar(32),
    "email" varchar(75) NOT NULL,
    "addr" varchar(256) NOT NULL,
    "exists_now" bool NOT NULL,
    "activity_sphere_id" integer NOT NULL
)
;
CREATE TABLE "department_activity_sphere" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "detail_model" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "category_id" integer NOT NULL
)
;
CREATE TABLE "detail_category" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "employee" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "phone" varchar(32) NOT NULL,
    "email" varchar(75) NOT NULL,
    "addr" varchar(256) NOT NULL,
    "login" varchar(64) NOT NULL,
    "password" varchar(128) NOT NULL,
    "role_id" integer NOT NULL,
    "group_id" integer NOT NULL
)
;
CREATE TABLE "employee_operation" (
    "id" integer NOT NULL PRIMARY KEY,
    "date" date NOT NULL,
    "type_id" integer NOT NULL,
    "employee_id" integer NOT NULL REFERENCES "employee" ("id"),
    "department_id" integer NOT NULL REFERENCES "department" ("id")
)
;
CREATE TABLE "employee_operation_type" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "employee_role" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "equipment_owner" (
    "id" integer NOT NULL PRIMARY KEY,
    "equipment_id" integer NOT NULL,
    "employee_id" integer NOT NULL REFERENCES "employee" ("id"),
    UNIQUE ("equipment_id", "employee_id")
)
;
CREATE TABLE "equipment" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "serial_number" varchar(128) NOT NULL,
    "addr" varchar(256) NOT NULL,
    "equipment_model_id" integer NOT NULL
)
;
CREATE TABLE "equipment_model" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "equipment_operation" (
    "id" integer NOT NULL PRIMARY KEY,
    "detail_price" real NOT NULL,
    "date" date NOT NULL,
    "equipment_id" integer NOT NULL REFERENCES "equipment" ("id"),
    "eq_oper_type_id" integer NOT NULL
)
;
CREATE TABLE "equipment_operation_type" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "repair" (
    "id" integer NOT NULL PRIMARY KEY,
    "equipment_assisment" varchar(512) NOT NULL,
    "detail_model_id" integer NOT NULL REFERENCES "detail_model" ("id"),
    "equpment_operation_id" integer NOT NULL REFERENCES "equipment_operation" ("id"),
    "task_id" integer NOT NULL
)
;
CREATE TABLE "rights_group" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "rights" varchar(8) NOT NULL
)
;
CREATE TABLE "task_equipment" (
    "id" integer NOT NULL PRIMARY KEY,
    "task_id" integer NOT NULL,
    "equipment_id" integer NOT NULL REFERENCES "equipment" ("id"),
    UNIQUE ("task_id", "equipment_id")
)
;
CREATE TABLE "task" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "priority_id" integer NOT NULL,
    "client_id" integer NOT NULL REFERENCES "employee" ("id"),
    "owner_id" integer NOT NULL REFERENCES "employee" ("id")
)
;
CREATE TABLE "task_operation" (
    "id" integer NOT NULL PRIMARY KEY,
    "work_price" real NOT NULL,
    "date" date NOT NULL,
    "task_id" integer NOT NULL REFERENCES "task" ("id"),
    "technic_id" integer NOT NULL REFERENCES "employee" ("id"),
    "state_id" integer NOT NULL
)
;
CREATE TABLE "task_priority" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "task_state" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE INDEX "department_1dea4842" ON "department" ("activity_sphere_id");
CREATE INDEX "detail_model_b583a629" ON "detail_model" ("category_id");
CREATE INDEX "employee_84566833" ON "employee" ("role_id");
CREATE INDEX "employee_0e939a4f" ON "employee" ("group_id");
CREATE INDEX "employee_operation_94757cae" ON "employee_operation" ("type_id");
CREATE INDEX "employee_operation_dcc97e32" ON "employee_operation" ("employee_id");
CREATE INDEX "employee_operation_bf691be4" ON "employee_operation" ("department_id");
CREATE INDEX "equipment_83ff7b4a" ON "equipment" ("equipment_model_id");
CREATE INDEX "equipment_operation_997b9956" ON "equipment_operation" ("equipment_id");
CREATE INDEX "equipment_operation_7ba3dec2" ON "equipment_operation" ("eq_oper_type_id");
CREATE INDEX "repair_3c11de5c" ON "repair" ("detail_model_id");
CREATE INDEX "repair_2d280302" ON "repair" ("equpment_operation_id");
CREATE INDEX "repair_57746cc8" ON "repair" ("task_id");
CREATE INDEX "task_8fb0ef36" ON "task" ("priority_id");
CREATE INDEX "task_2bfe9d72" ON "task" ("client_id");
CREATE INDEX "task_5e7b1936" ON "task" ("owner_id");
CREATE INDEX "task_operation_57746cc8" ON "task_operation" ("task_id");
CREATE INDEX "task_operation_043f54d9" ON "task_operation" ("technic_id");
CREATE INDEX "task_operation_d5582625" ON "task_operation" ("state_id");

COMMIT;
