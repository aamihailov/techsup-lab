BEGIN

-- удалить организацию

UPDATE department
  SET exists_now = FALSE
  WHERE LOWER( department.name ) = ?;
