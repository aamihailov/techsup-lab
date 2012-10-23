CALL add_employee( '999-999-999 99', 'Анастасия Алексеевна Санина',
                   '+7-923-233-39-95', 'Блюхера, 30/1',
                   'anastas.sanina', md5( 'anastas.sanina' ),
                   'администратор', 'Региональный Сервисный Центр',
                   ( SELECT NOW() )
                );


CALL add_equipment_and_owner( '999-999-999 99',
                              'рабочее место шефа',
                              'adm-999-9999-99-pc',
                              'комн. 99',
                              'рабочее место начальника',
                              ( SELECT NOW( ) )
                            );

CALL add_equipment_and_owner( '999-999-999 99',
                              'ноут шефа',
                              'adm-999-9999-99-laptope',
                              NULL,
                              '10.1@ Ноутбук Acer Aspire One AO522-C68kk/Black (HD 1280x720) AMD C60(1.0)/2048/320/AMD HD6290/WiFi/BT/Cam/MS Win7 Starter',
                              ( SELECT NOW( ) )
                            );
