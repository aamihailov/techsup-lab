-- EmployeeRoleFill
INSERT INTO `employee_role` (`name`) VALUES ('Бухгалтер');
INSERT INTO `employee_role` (`name`) VALUES ('Инженер');
INSERT INTO `employee_role` (`name`) VALUES ('Старший лаборант');
INSERT INTO `employee_role` (`name`) VALUES ('Младший лаборант');
INSERT INTO `employee_role` (`name`) VALUES ('Старший научный сотрудник');
INSERT INTO `employee_role` (`name`) VALUES ('Младший научный сотрудник');
INSERT INTO `employee_role` (`name`) VALUES ('Техник');
INSERT INTO `employee_role` (`name`) VALUES ('Администратор');
-- EmployeeOperationTypeFill
INSERT INTO `employee_operation_type` (`name`) VALUES ('Принят');
INSERT INTO `employee_operation_type` (`name`) VALUES ('Уволен');
INSERT INTO `employee_operation_type` (`name`) VALUES ('Отправлен в отпуск');
INSERT INTO `employee_operation_type` (`name`) VALUES ('Отозван из отпуска');
-- DepartmentActivitySphereFill
INSERT INTO `department_activity_sphere` (`name`) VALUES ('Медицинский профиль');
INSERT INTO `department_activity_sphere` (`name`) VALUES ('Технический профиль');
-- EquipmentOperationTypeFill
INSERT INTO `equipment_operation_type` (`name`) VALUES ('Поступление');
INSERT INTO `equipment_operation_type` (`name`) VALUES ('Списание');
INSERT INTO `equipment_operation_type` (`name`) VALUES ('Ремонт');
INSERT INTO `equipment_operation_type` (`name`) VALUES ('Замена детали');
INSERT INTO `equipment_operation_type` (`name`) VALUES ('Перемещение на склад');
INSERT INTO `equipment_operation_type` (`name`) VALUES ('Помещение на ремонт');
-- TaskPriorityFill
INSERT INTO `task_priority` (`name`) VALUES ('Самый высокий');
INSERT INTO `task_priority` (`name`) VALUES ('Высокий');
INSERT INTO `task_priority` (`name`) VALUES ('Средний');
INSERT INTO `task_priority` (`name`) VALUES ('Низкий');
INSERT INTO `task_priority` (`name`) VALUES ('Cамый низкий');
-- TaskStateFill
INSERT INTO `task_state` (`name`) VALUES ('Новая');
INSERT INTO `task_state` (`name`) VALUES ('Выполняется');
INSERT INTO `task_state` (`name`) VALUES ('Активная');
INSERT INTO `task_state` (`name`) VALUES ('Разрешена');
INSERT INTO `task_state` (`name`) VALUES ('Закрыта');
