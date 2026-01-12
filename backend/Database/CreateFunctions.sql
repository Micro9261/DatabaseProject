--Error handlers

CREATE OR REPLACE FUNCTION raise_custom_error(
    p_error_code TEXT
)
    RETURNS VOID AS
$raise_custom_error$
DECLARE
    d_error_message TEXT;
BEGIN
    SELECT error_message
    INTO d_error_message
    FROM error_codes
    WHERE error_codes.error_code = p_error_code;

    RAISE EXCEPTION USING
        ERRCODE = p_error_code,
        MESSAGE = d_error_message;
end;
$raise_custom_error$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_error(
    p_sqlstate TEXT,
    p_sqlerrm TEXT,
    p_function_name TEXT
)
    RETURNS VOID AS
$handle_error$
BEGIN

    RAISE EXCEPTION '% failed [%]: %',
        p_function_name,
        p_sqlstate,
        p_sqlerrm
        USING ERRCODE = p_sqlstate;
end;
$handle_error$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_error_code(
    p_error_code TEXT,
    p_error_message TEXT
)
    RETURNS TABLE
            (
                error_code    TEXT,
                error_message TEXT
            )
AS
$add_error_code$
BEGIN
    RETURN QUERY
        INSERT INTO error_codes (error_code, error_message)
            VALUES (p_error_code, p_error_message)
            RETURNING p_error_code, p_error_message;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'add_error_code');
end;
$add_error_code$
    LANGUAGE plpgsql;

--Prepare functions

CREATE OR REPLACE FUNCTION prepare_on_insert_projects()
    RETURNS TRIGGER AS
$prepare_on_insert_projects$
BEGIN
    IF NEW.title IS NOT NULL AND length(NEW.title) > 0 THEN
        NEW.title :=
                upper(left(NEW.title, 1)) || substr(NEW.title, 2);
    ELSE
        PERFORM raise_custom_error('A0013');
    end if;

    IF NEW.content IS NULL OR NEW.content = $$Empty$$ THEN
        PERFORM raise_custom_error('A0015');
    end if;

    IF NEW.author_id = 0 THEN
        PERFORM raise_custom_error('A0014');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_projects');
END;
$prepare_on_insert_projects$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prepare_on_insert_thread()
    RETURNS TRIGGER AS
$prepare_on_insert_thread$
BEGIN
    IF NEW.title IS NOT NULL AND length(NEW.title) > 0 THEN
        NEW.title :=
                upper(left(NEW.title, 1)) || substr(NEW.title, 2);
    ELSE
        PERFORM raise_custom_error('A0016');
    end if;

    IF NEW.content IS NULL OR NEW.content = $$Empty$$ THEN
        PERFORM raise_custom_error('A0018');
    end if;

    IF NEW.author_id = 0 THEN
        PERFORM raise_custom_error('A0017');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_thread');
end;
$prepare_on_insert_thread$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prepare_on_insert_report_type()
    RETURNS TRIGGER AS
$prepare_on_insert_report_type$
BEGIN
    IF NEW.name IS NOT NULL AND length(NEW.name) > 0 THEN
        NEW.name := lower(NEW.name);
    ELSE
        PERFORM raise_custom_error('A0020');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_report_type');
end;
$prepare_on_insert_report_type$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prepare_on_insert_report_subject()
    RETURNS TRIGGER AS
$prepare_on_insert_report_subject$
BEGIN
    IF NEW.name IS NOT NULL AND length(NEW.name) > 0 THEN
        NEW.name := lower(NEW.name);
    ELSE
        PERFORM raise_custom_error('A0021');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_report_subject');
end;
$prepare_on_insert_report_subject$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prepare_on_insert_gender()
    RETURNS TRIGGER AS
$prepare_on_insert_gender$
BEGIN
    IF NEW.name IS NOT NULL AND length(NEW.name) > 0 THEN
        NEW.name := lower(NEW.name);
    ELSE
        PERFORM raise_custom_error('A0022');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_gender');
end;
$prepare_on_insert_gender$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prepare_on_insert_roles()
    RETURNS TRIGGER AS
$prepare_on_insert_roles$
BEGIN
    IF NEW.name IS NOT NULL AND length(NEW.name) > 0 THEN
        NEW.name := lower(NEW.name);
    ELSE
        PERFORM raise_custom_error('A0023');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_roles');
end;
$prepare_on_insert_roles$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prepare_on_insert_users()
    RETURNS TRIGGER AS
$prepare_on_insert_users$
BEGIN
    IF NEW.name IS NOT NULL AND length(NEW.name) > 0 THEN
        NEW.name :=
                upper(left(NEW.name, 1)) || substr(NEW.name, 2);
    ELSE
        PERFORM raise_custom_error('A0009');
    end if;

    IF NEW.surname IS NOT NULL AND length(NEW.surname) > 0 THEN
        NEW.surname :=
                upper(left(NEW.surname, 1)) || substr(NEW.surname, 2);
    ELSE
        PERFORM raise_custom_error('A0010');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_users');
end;
$prepare_on_insert_users$
    LANGUAGE plpgsql;

--API functions

CREATE OR REPLACE FUNCTION add_project(
    p_title TEXT,
    p_author TEXT,
    p_content TEXT
)
    RETURNS TABLE
            (
                id   BIGINT,
                name TEXT,
                date TIMESTAMP
            )
AS
$add_project$
DECLARE
    d_author_id INT;
BEGIN
    IF p_title IS NULL OR length(p_title) = 0 THEN
        PERFORM raise_custom_error('A0013');
    end if;

    IF p_author IS NULL OR length(p_author) = 0 THEN
        PERFORM raise_custom_error('A0014');
    end if;

    SELECT u.id
    INTO d_author_id
    FROM users u
    WHERE u.nickname = p_author;

    IF d_author_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_content IS NULL OR length(p_content) = 0 THEN
        PERFORM raise_custom_error('A0015');
    end if;

    RETURN QUERY
        INSERT INTO projects (author_id, title, content)
            VALUES (d_author_id, p_title, p_content)
            RETURNING projects.id ,projects.title, projects.create_date;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_project');
end;
$add_project$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_project_comment(
    p_project_id BIGINT,
    p_parent_id BIGINT,
    p_author TEXT,
    p_content TEXT
)
    RETURNS TABLE
            (
                id          BIGINT,
                create_date TIMESTAMP,
                likes       INT,
                interest    INT
            )
AS
$add_project_comment$
DECLARE
    d_author_id BIGINT;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM projects p WHERE p.id = p_project_id) THEN
        PERFORM raise_custom_error('A0027');
    end if;

    IF p_parent_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM project_comment pc WHERE pc.id = p_parent_id) THEN
        PERFORM raise_custom_error('A0029');
    end if;

    SELECT u.id
    INTO d_author_id
    FROM users u
    WHERE u.nickname = p_author;

    IF d_author_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_content IS NULL OR length(p_content) = 0 THEN
        PERFORM raise_custom_error('A0030');
    end if;

    RETURN QUERY
        INSERT INTO project_comment (project_id, parent_id, author_id, content)
            VALUES (p_project_id, p_parent_id, d_author_id, p_content)
            RETURNING project_comment.id, project_comment.create_date, project_comment.likes, project_comment.interest_points;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_project_comment');
end;
$add_project_comment$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_project_comments(
    p_project_id BIGINT
)
    RETURNS TABLE
            (
                id              BIGINT,
                parent          BIGINT,
                author          TEXT,
                create_date     TIMESTAMP,
                content         TEXT,
                likes           INT,
                interest_points INT
            )
AS
$get_project_comments$
BEGIN
    RETURN QUERY
        SELECT pc.id,
               pc.parent_id AS parent,
               u.nickname   AS author,
               pc.create_date,
               pc.content,
               pc.likes,
               pc.interest_points
        FROM project_comment pc
                 INNER JOIN users u on u.id = pc.author_id
        WHERE pc.project_id = p_project_id
        ORDER BY pc.create_date;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'get_project_comments');

end;
$get_project_comments$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_thread(
    p_title TEXT,
    p_author TEXT,
    p_content TEXT
)
    RETURNS TABLE
            (
                id   BIGINT,
                name TEXT,
                date TIMESTAMP
            )
AS
$add_project$
DECLARE
    d_author_id INT;
BEGIN
    IF p_title IS NULL OR length(p_title) = 0 THEN
        PERFORM raise_custom_error('A0016');
    end if;

    IF p_author IS NULL OR length(p_author) = 0 THEN
        PERFORM raise_custom_error('A0017');
    end if;

    SELECT u.id
    INTO d_author_id
    FROM users u
    WHERE u.nickname = p_author;

    IF d_author_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_content IS NULL OR length(p_content) = 0 THEN
        PERFORM raise_custom_error('A0018');
    end if;

    RETURN QUERY
        INSERT INTO threads (author_id, title, content)
            VALUES (d_author_id, p_title, p_content)
            RETURNING threads.id ,threads.title, threads.create_date;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_thread');
end;
$add_project$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_thread_comment(
    p_thread_id BIGINT,
    p_parent_id BIGINT,
    p_author TEXT,
    p_content TEXT
)
    RETURNS TABLE
            (
                id          BIGINT,
                create_date TIMESTAMP,
                likes       INT,
                interest    INT
            )
AS
$add_thread_comment$
DECLARE
    d_author_id BIGINT;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM threads t WHERE t.id = p_thread_id) THEN
        PERFORM raise_custom_error('A0028');
    end if;

    IF p_parent_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM project_comment pc WHERE pc.id = p_parent_id) THEN
        PERFORM raise_custom_error('A0029');
    end if;

    SELECT u.id
    INTO d_author_id
    FROM users u
    WHERE u.nickname = p_author;

    IF d_author_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_content IS NULL OR length(p_content) = 0 THEN
        PERFORM raise_custom_error('A0030');
    end if;

    RETURN QUERY
        INSERT INTO thread_comment (thread_id, parent_id, author_id, content)
            VALUES (p_thread_id, p_parent_id, d_author_id, p_content)
            RETURNING thread_comment.id, thread_comment.create_date, thread_comment.likes, thread_comment.interest_points;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_thread_comment');
end;
$add_thread_comment$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_thread_comments(
    p_thread_id BIGINT
)
    RETURNS TABLE
            (
                id              BIGINT,
                parent          BIGINT,
                author          TEXT,
                create_date     TIMESTAMP,
                content         TEXT,
                likes           INT,
                interest_points INT
            )
AS
$get_thread_comments$
BEGIN
    RETURN QUERY
        SELECT tc.id,
               tc.parent_id AS parent,
               u.nickname   AS author,
               tc.create_date,
               tc.content,
               tc.likes,
               tc.interest_points
        FROM thread_comment tc
                 INNER JOIN users u on u.id = tc.author_id
        WHERE tc.thread_id = p_thread_id
        ORDER BY tc.create_date;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'get_thread_comments');

end;
$get_thread_comments$
    LANGUAGE plpgsql;

--Score analysis

--User login

CREATE OR REPLACE FUNCTION register_user(
    p_name TEXT,
    p_surname TEXT,
    p_nickname TEXT,
    p_email TEXT,
    p_gender TEXT,
    p_role TEXT,
    p_pass_hash TEXT
)
    RETURNS TABLE
            (
                nickname TEXT,
                role     TEXT
            )
AS
$register_user$
DECLARE
    d_gender_id BIGINT;
    d_role_id   BIGINT;
    d_token_id  BIGINT;
BEGIN
    --email
    IF p_email IS NULL OR p_email !~ '^[^@]+@[^@]+\.[^@]+$' THEN
        PERFORM raise_custom_error('A0001');
    end if;

    IF EXISTS (SELECT 1
               FROM users u
               WHERE u.email LIKE p_email) THEN
        PERFORM raise_custom_error('A0004');
    end if;

    IF EXISTS (SELECT 1
               FROM users u
               WHERE u.nickname LIKE p_nickname) THEN
        PERFORM raise_custom_error('A0008');
    end if;

    --role
    SELECT r.id
    INTO d_role_id
    FROM roles r
    WHERE r.name = p_role;

    IF d_role_id IS NULL THEN
        PERFORM raise_custom_error('A0002');
    end if;

    --gender
    SELECT g.id
    INTO d_gender_id
    FROM genders g
    WHERE g.name = p_gender;

    IF d_gender_id IS NULL THEN
        PERFORM raise_custom_error('A0003');
    end if;

    --prepare name
    IF p_name IS NULL OR length(p_name) = 0 THEN
        PERFORM raise_custom_error('A0009');
    end if;

    --prepare surname
    IF p_surname IS NULL OR length(p_surname) = 0 THEN
        PERFORM raise_custom_error('A0010');
    end if;

    SELECT t.id
    INTO d_token_id
    FROM tokens t
    WHERE t.token = 'Not specified';

    RETURN QUERY
        INSERT INTO "users" (role_id, name, surname, gender_id, nickname, email, pass_hash, token_id)
            VALUES (d_role_id, p_name, p_surname, d_gender_id,
                    p_nickname, p_email, p_pass_hash, d_token_id)
            RETURNING "users".nickname, p_role;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'register_user');
end;
$register_user$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_login_credentials(
    p_nickname TEXT,
    p_email TEXT,
    p_pass_hash TEXT
)
    RETURNS TABLE
            (
                nickname TEXT,
                email    TEXT,
                role     TEXT
            )
AS
$check_login_credentials$
DECLARE
    d_user_id         BIGINT;
    d_email_empty     BOOLEAN;
    d_nickname_empty  BOOLEAN;
    d_pass_hash       TEXT;
    d_return_nickname TEXT;
    d_return_email    TEXT;
    d_return_role     TEXT;
BEGIN
    IF p_email IS NULL OR length(p_email) = 0 THEN
        d_email_empty := TRUE;
    ELSE
        d_email_empty := FALSE;
    end if;

    IF p_nickname IS NULL OR length(p_nickname) = 0 THEN
        d_nickname_empty := TRUE;
    ELSE
        d_nickname_empty := FALSE;
    end if;

    IF p_pass_hash IS NULL OR length(p_pass_hash) = 0 THEN
        PERFORM raise_custom_error('A0011');
    end if;

    IF d_nickname_empty AND d_email_empty THEN
        PERFORM raise_custom_error('A0024');
    ELSE
        IF NOT d_nickname_empty THEN
            SELECT u.id
            INTO d_user_id
            FROM users u
            WHERE u.nickname = p_nickname;

            SELECT u.login, u.email, u.role
            INTO d_return_nickname, d_return_email, d_return_role
            FROM users_info u
            WHERE u.login = p_nickname;
        ELSE
            SELECT u.id
            INTO d_user_id
            FROM users u
            WHERE u.email = p_email;

            SELECT u.login, u.email, u.role
            INTO d_return_nickname, d_return_email, d_return_role
            FROM users_info u
            WHERE u.email = p_email;
        end if;
    end if;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0026');
    end if;

    SELECT u.pass_hash
    INTO d_pass_hash
    FROM users u
    WHERE u.id = d_user_id;

    IF d_pass_hash = p_pass_hash THEN
        RETURN QUERY SELECT d_return_nickname, d_return_email, d_return_role;
    ELSE
        PERFORM raise_custom_error('A0005');
    end if;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'check_login_credentials');
end;
$check_login_credentials$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_user_token(
    p_nickname TEXT,
    p_token TEXT,
    p_expire_time BIGINT
)
    RETURNS TEXT AS
$set_user_token$
DECLARE
    d_token_content TEXT;
    d_token_id      BIGINT;
BEGIN
    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.nickname = p_nickname;

    SELECT t.token
    INTO d_token_content
    FROM tokens t
    WHERE t.id = d_token_id;

    IF d_token_content = 'Not specified' THEN
        INSERT INTO tokens (token, expire_time)
        VALUES (p_token, p_expire_time);
    ELSE
        UPDATE tokens t
        SET token = p_token, expire_time = p_expire_time
        WHERE t.id = d_token_id;
    end if;

    SELECT t.token
    INTO d_token_content
    FROM tokens t
    WHERE t.id = d_token_id;

    RETURN d_token_content;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'set_user_token');
end;
$set_user_token$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_token(
    p_nickname TEXT
)
    RETURNS TABLE(token TEXT, expire_time BIGINT, create_time TIMESTAMP) AS
$set_user_token$
DECLARE
    d_token_content TEXT;
    d_expire_time BIGINT;
    d_create_time TIMESTAMP;
    d_token_id      BIGINT;
BEGIN
    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.nickname = p_nickname;

    SELECT t.token, t.expire_time, t.create_time
    INTO d_token_content, d_expire_time, d_create_time
    FROM tokens t
    WHERE t.id = d_token_id;

    RETURN QUERY SELECT d_token_content, d_expire_time, d_create_time;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'get_user_token');
end;
$set_user_token$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_user_token(
    p_nickname TEXT
)
    RETURNS TEXT AS
$set_user_token$
DECLARE
    d_token_content    TEXT;
    d_token_id         BIGINT;
    d_default_token_id BIGINT;
BEGIN
    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.nickname = p_nickname;

    SELECT t.token
    INTO d_token_content
    FROM tokens t
    WHERE t.id = d_token_id;

    IF d_token_content = 'Not specified' THEN
        RETURN d_token_content;
    end if;

    SELECT t.id
    INTO d_default_token_id
    FROM tokens t
    WHERE t.token = 'Not specified';

    UPDATE users u
    SET token_id = d_default_token_id
    WHERE u.nickname = p_nickname;

    DELETE
    FROM tokens t
    WHERE t.id = d_token_id;

    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.nickname = p_nickname;

    SELECT t.token
    INTO d_token_content
    FROM tokens t
    WHERE t.id = d_token_id;

    RETURN d_token_content;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_user_token');
end;
$set_user_token$
    LANGUAGE plpgsql;