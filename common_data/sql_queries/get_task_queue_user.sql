-- просмотреть очередь заявок с последним
-- изменённым статусом для пользователя

DROP TABLE IF EXISTS tmp_task;
CREATE TEMPORARY TABLE tmp_task AS
    SELECT task.id, task_priority.name AS priority, task.name AS task
    FROM task
    INNER JOIN task_priority
    ON task.priority_id = task_priority.id;

DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp AS
    SELECT task_operation.task_id, 
           employee.name,
           task_state.name AS state, task_operation.datetime 
    FROM task_operation
    INNER JOIN (
        SELECT task_operation.task_id, MAX( task_operation.datetime ) AS date
        FROM task_operation
        GROUP BY task_operation.task_id
    ) AS temp
    ON task_operation.task_id = temp.task_id AND
       task_operation.datetime = temp.date
    LEFT JOIN employee
    ON technic_id = employee.id
    INNER JOIN task_state 
    ON state_id = task_state.id;

    SELECT tmp.task_id, 
           task_priority.name AS priority,
           task.name AS task,
           tmp.name AS technic,
           tmp.state, tmp.datetime
    FROM tmp
    INNER JOIN task
    ON tmp.task_id = task.id
    INNER JOIN task_priority
    ON priority_id = task_priority.id
    ORDER BY tmp.datetime; 
