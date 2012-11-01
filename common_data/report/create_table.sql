BEGIN;
CREATE TABLE `admins` (
    `employee_id` integer NOT NULL PRIMARY KEY
)
;
CREATE TABLE `department_activity_sphere` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `department` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE,
    `phone` varchar(32),
    `email` varchar(75) NOT NULL,
    `addr` varchar(512) NOT NULL,
    `exists_now` bool NOT NULL,
    `activity_sphere_id` integer NOT NULL
)
;
ALTER TABLE `department` ADD CONSTRAINT `activity_sphere_id_refs_id_cac38110` FOREIGN KEY (`activity_sphere_id`) REFERENCES `department_activity_sphere` (`id`);
CREATE TABLE `detail_category` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `detail_model` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE,
    `category_id` integer NOT NULL
)
;
ALTER TABLE `detail_model` ADD CONSTRAINT `category_id_refs_id_7151611f` FOREIGN KEY (`category_id`) REFERENCES `detail_category` (`id`);
CREATE TABLE `employee_role` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `employee` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `snils` varchar(16) NOT NULL UNIQUE,
    `name` varchar(255) NOT NULL,
    `phone` varchar(32) NOT NULL,
    `addr` varchar(512) NOT NULL,
    `login` varchar(64) UNIQUE,
    `password` varchar(128),
    `role_id` integer NOT NULL
)
;
ALTER TABLE `employee` ADD CONSTRAINT `role_id_refs_id_c1a88009` FOREIGN KEY (`role_id`) REFERENCES `employee_role` (`id`);
ALTER TABLE `admins` ADD CONSTRAINT `employee_id_refs_id_4e8e850e` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`id`);
CREATE TABLE `employee_operation_type` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `employee_operation` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `date` date NOT NULL,
    `type_id` integer NOT NULL,
    `employee_id` integer NOT NULL,
    `department_id` integer NOT NULL
)
;
ALTER TABLE `employee_operation` ADD CONSTRAINT `employee_id_refs_id_2bed7358` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`id`);
ALTER TABLE `employee_operation` ADD CONSTRAINT `type_id_refs_id_e2086d2c` FOREIGN KEY (`type_id`) REFERENCES `employee_operation_type` (`id`);
ALTER TABLE `employee_operation` ADD CONSTRAINT `department_id_refs_id_a61f5496` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`);
CREATE TABLE `equipment_category` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `equipment_model` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE,
    `category_id` integer NOT NULL
)
;
ALTER TABLE `equipment_model` ADD CONSTRAINT `category_id_refs_id_68b4f741` FOREIGN KEY (`category_id`) REFERENCES `equipment_category` (`id`);
CREATE TABLE `equipment` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL,
    `serial_number` varchar(255) NOT NULL UNIQUE,
    `addr` varchar(512),
    `equipment_model_id` integer NOT NULL
)
;
ALTER TABLE `equipment` ADD CONSTRAINT `equipment_model_id_refs_id_76bbc77d` FOREIGN KEY (`equipment_model_id`) REFERENCES `equipment_model` (`id`);
CREATE TABLE `equipment_operation_type` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `equipment_operation` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `detail_price` double precision,
    `datetime` datetime NOT NULL,
    `equipment_id` integer NOT NULL,
    `eq_oper_type_id` integer NOT NULL
)
;
ALTER TABLE `equipment_operation` ADD CONSTRAINT `equipment_id_refs_id_8da693a5` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`);
ALTER TABLE `equipment_operation` ADD CONSTRAINT `eq_oper_type_id_refs_id_50af72b9` FOREIGN KEY (`eq_oper_type_id`) REFERENCES `equipment_operation_type` (`id`);
CREATE TABLE `equipment_owner` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `start_datetime` datetime NOT NULL,
    `finish_datetime` datetime,
    `equipment_id` integer NOT NULL,
    `employee_id` integer NOT NULL
)
;
ALTER TABLE `equipment_owner` ADD CONSTRAINT `equipment_id_refs_id_ab3ab6a4` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`);
ALTER TABLE `equipment_owner` ADD CONSTRAINT `employee_id_refs_id_e8c12184` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`id`);
CREATE TABLE `task_priority` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `task_equipment` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `task_id` integer NOT NULL,
    `equipment_id` integer NOT NULL,
    UNIQUE (`task_id`, `equipment_id`)
)
;
ALTER TABLE `task_equipment` ADD CONSTRAINT `equipment_id_refs_id_28b1e439` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`);
CREATE TABLE `task` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL,
    `datetime` datetime NOT NULL,
    `priority_id` integer NOT NULL,
    `client_id` integer NOT NULL,
    `owner_id` integer
)
;
ALTER TABLE `task` ADD CONSTRAINT `priority_id_refs_id_6f001401` FOREIGN KEY (`priority_id`) REFERENCES `task_priority` (`id`);
ALTER TABLE `task` ADD CONSTRAINT `client_id_refs_id_138e7f27` FOREIGN KEY (`client_id`) REFERENCES `employee` (`id`);
ALTER TABLE `task` ADD CONSTRAINT `owner_id_refs_id_138e7f27` FOREIGN KEY (`owner_id`) REFERENCES `employee` (`id`);
ALTER TABLE `task_equipment` ADD CONSTRAINT `task_id_refs_id_eb7165db` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`);
CREATE TABLE `repair` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `comment` varchar(512) NOT NULL,
    `datetime` datetime NOT NULL,
    `detail_model_id` integer NOT NULL,
    `equipment_operation_id` integer NOT NULL,
    `task_id` integer NOT NULL
)
;
ALTER TABLE `repair` ADD CONSTRAINT `equipment_operation_id_refs_id_f486654f` FOREIGN KEY (`equipment_operation_id`) REFERENCES `equipment_operation` (`id`);
ALTER TABLE `repair` ADD CONSTRAINT `detail_model_id_refs_id_c5ba20e8` FOREIGN KEY (`detail_model_id`) REFERENCES `detail_model` (`id`);
ALTER TABLE `repair` ADD CONSTRAINT `task_id_refs_id_95a2d6c7` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`);
CREATE TABLE `task_state` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name` varchar(255) NOT NULL UNIQUE
)
;
CREATE TABLE `task_operation` (
    `id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `work_price` double precision,
    `datetime` datetime NOT NULL,
    `task_id` integer NOT NULL,
    `technic_id` integer NOT NULL,
    `state_id` integer NOT NULL
)
;
ALTER TABLE `task_operation` ADD CONSTRAINT `technic_id_refs_id_bf4be40c` FOREIGN KEY (`technic_id`) REFERENCES `employee` (`id`);
ALTER TABLE `task_operation` ADD CONSTRAINT `state_id_refs_id_1212148b` FOREIGN KEY (`state_id`) REFERENCES `task_state` (`id`);
ALTER TABLE `task_operation` ADD CONSTRAINT `task_id_refs_id_940884b5` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`);
CREATE TABLE `technics` (
    `employee_id` integer NOT NULL PRIMARY KEY
)
;
ALTER TABLE `technics` ADD CONSTRAINT `employee_id_refs_id_d7240997` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`id`);
CREATE INDEX `department_1dea4842` ON `department` (`activity_sphere_id`);
CREATE INDEX `detail_model_b583a629` ON `detail_model` (`category_id`);
CREATE INDEX `employee_84566833` ON `employee` (`role_id`);
CREATE INDEX `employee_operation_94757cae` ON `employee_operation` (`type_id`);
CREATE INDEX `employee_operation_dcc97e32` ON `employee_operation` (`employee_id`);
CREATE INDEX `employee_operation_bf691be4` ON `employee_operation` (`department_id`);
CREATE INDEX `equipment_model_b583a629` ON `equipment_model` (`category_id`);
CREATE INDEX `equipment_83ff7b4a` ON `equipment` (`equipment_model_id`);
CREATE INDEX `equipment_operation_997b9956` ON `equipment_operation` (`equipment_id`);
CREATE INDEX `equipment_operation_7ba3dec2` ON `equipment_operation` (`eq_oper_type_id`);
CREATE INDEX `equipment_owner_997b9956` ON `equipment_owner` (`equipment_id`);
CREATE INDEX `equipment_owner_dcc97e32` ON `equipment_owner` (`employee_id`);
CREATE INDEX `task_8fb0ef36` ON `task` (`priority_id`);
CREATE INDEX `task_2bfe9d72` ON `task` (`client_id`);
CREATE INDEX `task_5e7b1936` ON `task` (`owner_id`);
CREATE INDEX `repair_3c11de5c` ON `repair` (`detail_model_id`);
CREATE INDEX `repair_694a0d3b` ON `repair` (`equipment_operation_id`);
CREATE INDEX `repair_57746cc8` ON `repair` (`task_id`);
CREATE INDEX `task_operation_57746cc8` ON `task_operation` (`task_id`);
CREATE INDEX `task_operation_043f54d9` ON `task_operation` (`technic_id`);
CREATE INDEX `task_operation_d5582625` ON `task_operation` (`state_id`);

COMMIT;
