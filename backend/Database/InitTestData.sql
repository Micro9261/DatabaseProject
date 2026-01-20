-- DO
-- $add_users$
--     BEGIN
--         PERFORM user_create('Pawel', 'Glowacki', 'AdminTest', 'test1@gmail.com', 'male', 'admin', '1234');
--         PERFORM user_create('Kacper', 'Marmaj', 'ModeratorTest', 'test2@gmail.com', 'male', 'moderator', '1234');
--         PERFORM user_create('Piotr', 'Nowak', 'UserTest', 'test3@gmail.com', 'male', 'user', '1234');
--         PERFORM user_create('Jacek', 'Pietruszka', 'Pietruszka1', 'test4@gmail.com', 'male', 'user', '1234');
--         PERFORM user_create('marek', 'staszyński', 'Staszeczek', 'test5@gmail.com', 'male', 'user', '1234');
--         PERFORM user_create('kuba', 'wrocek', 'wrocławskiRok', 'test6@gmail.com', 'male', 'user', '1234');
--         PERFORM user_create('Mikołaj', 'warta', 'mikoWart', 'test7@gmail.com', 'male', 'user', '1234');
--         PERFORM user_create('Justyna', 'bomba', 'Justice', 'test8@gmail.com', 'female', 'user', '1234');
--         PERFORM user_create('Anastazja', 'wieczorek', 'AnWek', 'test9@gmail.com', 'female', 'user', '1234');
--     end;
-- $add_users$;

DO
$add_projects$
    BEGIN
        PERFORM add_project('Mikrokontrolery w praktyce AVR', 'Pietruszka1', 'Lorem ipsum Lorem ipsum');
        PERFORM add_project('Mikroprocesory STM32MP2', 'Staszeczek', 'Lorem ipsum Lorem ipsum Lorem ipsum');
        PERFORM add_project('Przewaga STM32 nad AVR', 'wrocławskiRok',
                            'Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum');
        PERFORM add_project('Nowości od Microchip!', 'wrocławskiRok', 'Lorem testum Lotem testum');
    end;
$add_projects$;

DO
$add_threads$
    BEGIN
        PERFORM add_thread('Jaki mikrokontroler wybrać do sterowania silnikiem', 'mikoWart', 'Lotem threados');
        PERFORM add_thread('Problem z wyborem ADC', 'Justice', 'Lotem threados Lotem threados');
        PERFORM add_thread('Jak podłączyć czujnik H04 do Atmega8', 'AnWek', 'Lotem threados Lotem threados testos');
    end;
$add_threads$;

DO
$add_projects_comments$
    BEGIN
        PERFORM add_project_comment(1, NULL, 'mikoWart', 'Lorem content test');
        PERFORM add_project_comment(1, 1, 'Justice', 'Lorem content test respond');
        PERFORM add_project_comment(2, NULL, 'AnWek', 'Lorem content test next');
    end;
$add_projects_comments$;

DO
$add_thread_comments$
    BEGIN
        PERFORM add_thread_comment(1, NULL, 'Pietruszka1', 'Lorem thread content');
        PERFORM add_thread_comment(2, NULL, 'Staszeczek', 'Lorem thread content test');
        PERFORM add_thread_comment(2, NULL, 'wrocławskiRok', 'Lorem thread content test next');
    end;
$add_thread_comments$;