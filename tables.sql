BEGIN;
CREATE TABLE "techsup_run_department" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "phone" varchar(32) NOT NULL,
    "email" varchar(75) NOT NULL,
    "addr" varchar(256) NOT NULL,
    "exists_now" bool NOT NULL,
    "activity_sphere_id" integer NOT NULL
)
;
CREATE TABLE "techsup_run_departmentactivitysphere" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_detailmodel" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "node_category_id" integer NOT NULL
)
;
CREATE TABLE "techsup_run_employee" (
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
CREATE TABLE "techsup_run_employeeequipmentcommunication" (
    "id" integer NOT NULL PRIMARY KEY,
    "employee_id" integer NOT NULL REFERENCES "techsup_run_employee" ("id"),
    "equipment_id" integer NOT NULL
)
;
CREATE TABLE "techsup_run_employeeoperation" (
    "id" integer NOT NULL PRIMARY KEY,
    "type_id" integer NOT NULL,
    "employee_id" integer NOT NULL REFERENCES "techsup_run_employee" ("id"),
    "department_id" integer NOT NULL REFERENCES "techsup_run_department" ("id")
)
;
CREATE TABLE "techsup_run_employeeoperationtype" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_employeerole" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_equipment" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "serial_number" varchar(128) NOT NULL,
    "addr" varchar(256) NOT NULL,
    "equipment_model_id" integer NOT NULL
)
;
CREATE TABLE "techsup_run_equipmentmodel" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_equipmentoperation" (
    "id" integer NOT NULL PRIMARY KEY,
    "equipment_id" integer NOT NULL REFERENCES "techsup_run_equipment" ("id"),
    "eq_oper_type_id" integer NOT NULL,
    "date" date NOT NULL
)
;
CREATE TABLE "techsup_run_equipmentoperationtype" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_nodecategory" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_repair" (
    "id" integer NOT NULL PRIMARY KEY,
    "equipment_assisment" varchar(512) NOT NULL,
    "work_price" real NOT NULL,
    "detail_price" real NOT NULL,
    "detail_model_id" integer NOT NULL REFERENCES "techsup_run_detailmodel" ("id"),
    "equpment_operation_id" integer NOT NULL REFERENCES "techsup_run_equipmentoperation" ("id")
)
;
CREATE TABLE "techsup_run_repairworkers" (
    "id" integer NOT NULL PRIMARY KEY,
    "repair_id" integer NOT NULL REFERENCES "techsup_run_repair" ("id"),
    "employee_id" integer NOT NULL REFERENCES "techsup_run_employee" ("id")
)
;
CREATE TABLE "techsup_run_rightsgroup" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "rigths" varchar(8) NOT NULL
)
;
CREATE TABLE "techsup_run_task" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL,
    "priority_id" integer NOT NULL
)
;
CREATE TABLE "techsup_run_taskoperation" (
    "id" integer NOT NULL PRIMARY KEY,
    "task_id" integer NOT NULL REFERENCES "techsup_run_task" ("id"),
    "employee_id" integer NOT NULL REFERENCES "techsup_run_employee" ("id"),
    "technic_id" integer NOT NULL REFERENCES "techsup_run_employee" ("id"),
    "state_id" integer NOT NULL,
    "date" date NOT NULL
)
;
CREATE TABLE "techsup_run_taskpriority" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE TABLE "techsup_run_taskstate" (
    "id" integer NOT NULL PRIMARY KEY,
    "name" varchar(128) NOT NULL
)
;
CREATE INDEX "techsup_run_department_5d8a0cda" ON "techsup_run_department" ("activity_sphere_id");
CREATE INDEX "techsup_run_detailmodel_6d3536b6" ON "techsup_run_detailmodel" ("node_category_id");
CREATE INDEX "techsup_run_employee_bf07f040" ON "techsup_run_employee" ("role_id");
CREATE INDEX "techsup_run_employee_bda51c3c" ON "techsup_run_employee" ("group_id");
CREATE INDEX "techsup_run_employeeequipmentcommunication_359f2ab4" ON "techsup_run_employeeequipmentcommunication" ("employee_id");
CREATE INDEX "techsup_run_employeeequipmentcommunication_57fa5429" ON "techsup_run_employeeequipmentcommunication" ("equipment_id");
CREATE INDEX "techsup_run_employeeoperation_777d41c8" ON "techsup_run_employeeoperation" ("type_id");
CREATE INDEX "techsup_run_employeeoperation_359f2ab4" ON "techsup_run_employeeoperation" ("employee_id");
CREATE INDEX "techsup_run_employeeoperation_2ae7390" ON "techsup_run_employeeoperation" ("department_id");
CREATE INDEX "techsup_run_equipment_57abcf91" ON "techsup_run_equipment" ("equipment_model_id");
CREATE INDEX "techsup_run_equipmentoperation_57fa5429" ON "techsup_run_equipmentoperation" ("equipment_id");
CREATE INDEX "techsup_run_equipmentoperation_75a10a68" ON "techsup_run_equipmentoperation" ("eq_oper_type_id");
CREATE INDEX "techsup_run_repair_6e891d2b" ON "techsup_run_repair" ("detail_model_id");
CREATE INDEX "techsup_run_repair_9a8b2091" ON "techsup_run_repair" ("equpment_operation_id");
CREATE INDEX "techsup_run_repairworkers_fca3e68b" ON "techsup_run_repairworkers" ("repair_id");
CREATE INDEX "techsup_run_repairworkers_359f2ab4" ON "techsup_run_repairworkers" ("employee_id");
CREATE INDEX "techsup_run_task_b62206ec" ON "techsup_run_task" ("priority_id");
CREATE INDEX "techsup_run_taskoperation_c00fe455" ON "techsup_run_taskoperation" ("task_id");
CREATE INDEX "techsup_run_taskoperation_359f2ab4" ON "techsup_run_taskoperation" ("employee_id");
CREATE INDEX "techsup_run_taskoperation_28293043" ON "techsup_run_taskoperation" ("technic_id");
CREATE INDEX "techsup_run_taskoperation_b9608dc2" ON "techsup_run_taskoperation" ("state_id");
COMMIT;