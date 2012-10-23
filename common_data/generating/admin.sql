CALL add_employee( '999-999-999 99', 'Анастасия Алексеевна Санина',
                   '+7-923-233-39-95', 'Блюхера, 30/1',
                   'anastas.sanina', md5( 'anastas.sanina' ),
                   'администратор', 'Региональный Сервисный Центр',
                   ( SELECT NOW() )
                );


CALL add_equipment_owner(
                          '999-999-999 99',
                          'серийник рабочее место начальника'
                          ( SELECT NOW( ) )
                        );

CALL add_equipment_owner(
                          '999-999-999 99',
                          'серийник ноута'
                          ( SELECT NOW( ) )
                        );
