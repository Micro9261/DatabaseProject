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

CREATE OR REPLACE FUNCTION prepare_on_insert_tag()
    RETURNS TRIGGER AS
$prepare_on_insert_tag$
BEGIN
    IF NEW.name IS NOT NULL AND length(NEW.name) > 0 THEN
        NEW.name := upper(NEW.name);
    ELSE
        PERFORM raise_custom_error('A0032');
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, sqlerrm, 'prepare_on_insert_tag');
end;
$prepare_on_insert_tag$
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
    WHERE u.login = p_author;

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
                create_date TIMESTAMP
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
    WHERE u.login = p_author;

    IF d_author_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_content IS NULL OR length(p_content) = 0 THEN
        PERFORM raise_custom_error('A0030');
    end if;

    RETURN QUERY
        INSERT INTO project_comment (project_id, parent_id, author_id, content)
            VALUES (p_project_id, p_parent_id, d_author_id, p_content)
            RETURNING project_comment.id, project_comment.create_date;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_project_comment');
end;
$add_project_comment$
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
    WHERE u.login = p_author;

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
                create_date TIMESTAMP
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
    WHERE u.login = p_author;

    IF d_author_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_content IS NULL OR length(p_content) = 0 THEN
        PERFORM raise_custom_error('A0030');
    end if;

    RETURN QUERY
        INSERT INTO thread_comment (thread_id, parent_id, author_id, content)
            VALUES (p_thread_id, p_parent_id, d_author_id, p_content)
            RETURNING thread_comment.id, thread_comment.create_date;

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
                id          BIGINT,
                parent      BIGINT,
                author      TEXT,
                create_date TIMESTAMP,
                content     TEXT,
                likes       BIGINT,
                interest    BIGINT
            )
AS
$get_thread_comments$
BEGIN
    RETURN QUERY
        SELECT tci.thread_id      AS id,
               tci.parent_comm_id AS parent,
               tci.author,
               tci.create_date,
               tci.content,
               tci.likes,
               tci.interest
        FROM threads_comments_info tci
        WHERE tci.thread_id = p_thread_id
        ORDER BY tci.create_date;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'get_thread_comments');

end;
$get_thread_comments$
    LANGUAGE plpgsql;

--Score analysis

--User login


-- NEW FUNCTIONS

CREATE OR REPLACE FUNCTION add_view(
    p_project_id BIGINT,
    p_thread_id BIGINT
)
    RETURNS BOOLEAN AS
$add_view$
BEGIN
    IF p_project_id IS NOT NULL THEN
        UPDATE projects
        SET views = views + 1
        WHERE id = p_project_id;

        RETURN TRUE;
    end if;

    IF p_thread_id IS NOT NULL THEN
        UPDATE threads
        SET views = views + 1
        WHERE id = p_thread_id;

        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_view');
end;
$add_view$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_like(
    p_login TEXT,
    p_project_id BIGINT,
    p_thread_id BIGINT,
    p_comment_id BIGINT
)
    RETURNS BOOLEAN AS
$add_like$
DECLARE
    d_user_id BIGINT;
BEGIN
    SELECT u.id
    INTO d_user_id
    FROM users u
    WHERE u.login = p_login;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_project_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            INSERT INTO relation_project_like (user_id, project_id) VALUES (d_user_id, p_project_id);
        ELSE
            INSERT INTO relation_project_comment_like (user_id, project_comment_id) VALUES (d_user_id, p_comment_id);
        end if;
        RETURN TRUE;
    end if;

    IF p_thread_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            INSERT INTO relation_thread_like (user_id, thread_id) VALUES (d_user_id, p_thread_id);
        ELSE
            INSERT INTO relation_thread_comment_like (user_id, thread_comment_id) VALUES (d_user_id, p_comment_id);
        end if;
        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_like');
end;
$add_like$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_like(
    p_login TEXT,
    p_project_id BIGINT,
    p_thread_id BIGINT,
    p_comment_id BIGINT
)
    RETURNS BOOLEAN AS
$delete_like$
DECLARE
    d_user_id BIGINT;
BEGIN
    SELECT u.id
    INTO d_user_id
    FROM users u
    WHERE u.login = p_login;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_project_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            DELETE FROM relation_project_like rpl WHERE rpl.project_id = p_project_id AND rpl.user_id = d_user_id;
        ELSE
            DELETE
            FROM relation_project_comment_like rpcl
            WHERE rpcl.project_comment_id = p_comment_id
              AND rpcl.user_id = d_user_id;
        end if;
        RETURN TRUE;
    end if;

    IF p_thread_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            DELETE FROM relation_thread_like rtl WHERE rtl.thread_id = p_thread_id AND rtl.user_id = d_user_id;
        ELSE
            DELETE
            FROM relation_thread_comment_like rtcl
            WHERE rtcl.thread_comment_id = p_comment_id
              AND rtcl.user_id = d_user_id;
        end if;
        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_like');
end;
$delete_like$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_save(
    p_login TEXT,
    p_project_id BIGINT,
    p_thread_id BIGINT,
    p_comment_id BIGINT
)
    RETURNS BOOLEAN AS
$add_save$
DECLARE
    d_user_id BIGINT;
BEGIN
    SELECT u.id
    INTO d_user_id
    FROM users u
    WHERE u.login = p_login;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_project_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            INSERT INTO relation_project_save (user_id, project_id) VALUES (d_user_id, p_project_id);
        ELSE
            INSERT INTO relation_project_comment_interest (user_id, project_comment_id)
            VALUES (d_user_id, p_comment_id);
        end if;
        RETURN TRUE;
    end if;

    IF p_thread_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            INSERT INTO relation_thread_save (user_id, thread_id) VALUES (d_user_id, p_thread_id);
        ELSE
            INSERT INTO relation_thread_comment_interest (user_id, thread_comment_id) VALUES (d_user_id, p_comment_id);
        end if;
        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_save');
end;
$add_save$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_save(
    p_login TEXT,
    p_project_id BIGINT,
    p_thread_id BIGINT,
    p_comment_id BIGINT
)
    RETURNS BOOLEAN AS
$delete_save$
DECLARE
    d_user_id BIGINT;
BEGIN
    SELECT u.id
    INTO d_user_id
    FROM users u
    WHERE u.login = p_login;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_project_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            DELETE FROM relation_project_save rps WHERE rps.project_id = p_project_id AND rps.user_id = d_user_id;
        ELSE
            DELETE
            FROM relation_project_comment_interest rpci
            WHERE rpci.project_comment_id = p_comment_id
              AND rpci.user_id = d_user_id;
        end if;
        RETURN TRUE;
    end if;

    IF p_thread_id IS NOT NULL THEN
        IF p_comment_id IS NULL THEN
            DELETE FROM relation_thread_save rts WHERE rts.thread_id = p_thread_id AND rts.user_id = d_user_id;
        ELSE
            DELETE
            FROM relation_thread_comment_interest rtci
            WHERE rtci.thread_comment_id = p_comment_id
              AND rtci.user_id = d_user_id;
        end if;
        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_save');
end;
$delete_save$
    LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION delete_project(
    p_project_id BIGINT
)
    RETURNS BOOLEAN AS
$delete_project$
BEGIN
    IF p_project_id IS NOT NULL AND EXISTS(SELECT 1 FROM projects p WHERE p.id = p_project_id) THEN
        DELETE FROM projects p WHERE p.id = p_project_id;

        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_project');
end;
$delete_project$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_thread(
    p_thread_id BIGINT
)
    RETURNS BOOLEAN AS
$delete_project$
BEGIN
    IF p_thread_id IS NOT NULL AND EXISTS(SELECT 1 FROM threads t WHERE t.id = p_thread_id) THEN
        DELETE FROM threads t WHERE t.id = p_thread_id;

        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_thread');
end;
$delete_project$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_comment(
    p_in_projects BOOLEAN,
    p_comment_id BIGINT
)
    RETURNS BOOLEAN AS
$delete_comment$
BEGIN
    IF p_comment_id IS NOT NULL THEN
        IF p_in_projects IS TRUE AND EXISTS(SELECT 1 FROM project_comment pc WHERE pc.id = p_comment_id) THEN
            DELETE FROM project_comment pc WHERE pc.id = p_comment_id;

            RETURN TRUE;
        ELSE
            IF p_in_projects IS FALSE AND EXISTS(SELECT 1 FROM thread_comment tc WHERE tc.id = p_comment_id) THEN
                DELETE FROM thread_comment tc WHERE tc.id = p_comment_id;

                RETURN TRUE;
            end if;
        end if;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_comment');
end;
$delete_comment$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_report(
    p_project_id BIGINT,
    p_thread_id BIGINT,
    p_comment_id BIGINT,
    p_reporter TEXT,
    p_reason TEXT,
    p_content TEXT
)
    RETURNS BOOLEAN AS
$add_report$
DECLARE
    d_subject_id     BIGINT;
    d_user_id        BIGINT;
    d_subject_reason BIGINT;
    d_subject_type   BIGINT;
    d_comment        BOOLEAN;
BEGIN
    SELECT u.id
    INTO d_user_id
    FROM users u
    WHERE u.login = p_reporter;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_project_id IS NOT NULL THEN
        IF p_comment_id IS NOT NULL THEN
            SELECT rt.id
            INTO d_subject_type
            FROM report_type rt
            WHERE rt.name = 'project_comment';

            SELECT p_comment_id INTO d_subject_id;
            SELECT TRUE INTO d_comment;
        ELSE
            SELECT rt.id
            INTO d_subject_type
            FROM report_type rt
            WHERE rt.name = 'project';

            SELECT p_project_id INTO d_subject_id;
            SELECT FALSE INTO d_comment;
        end if;
        RETURN TRUE;
    end if;

    IF p_thread_id IS NOT NULL THEN
        IF p_comment_id IS NOT NULL THEN
            SELECT rt.id
            INTO d_subject_type
            FROM report_type rt
            WHERE rt.name = 'thread_comment';

            SELECT p_comment_id INTO d_subject_id;
            SELECT TRUE INTO d_comment;
        ELSE
            SELECT rt.id
            INTO d_subject_type
            FROM report_type rt
            WHERE rt.name = 'thread';

            SELECT p_thread_id INTO d_subject_id;
            SELECT FALSE INTO d_comment;
        end if;
    end if;

    IF d_subject_type IS NULL THEN
        PERFORM raise_custom_error('A0021');
    end if;

    SELECT rs.id
    INTO d_subject_reason
    FROM report_subject rs
    WHERE rs.name LIKE p_reason;

    IF d_subject_reason IS NULL THEN
        PERFORM raise_custom_error('A0020');
    end if;

    INSERT INTO report_notifications (author_id, subject_id, subject_type_id, type_id, content)
    VALUES (d_user_id, d_subject_id, d_subject_type, d_subject_reason, p_content);

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_report');
end;
$add_report$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_report(
    p_report_id BIGINT
)
    RETURNS BOOLEAN AS
$delete_report$
BEGIN
    IF p_report_id IS NOT NULL AND EXISTS(SELECT 1 FROM report_notifications rn WHERE rn.id = p_report_id) THEN
        DELETE FROM report_notifications rn WHERE rn.id = p_report_id;

        RETURN TRUE;
    end if;

    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_report');
end;
$delete_report$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_tag(
    p_subject_id BIGINT,
    p_is_project BOOLEAN,
    p_name TEXT
)
    RETURNS BOOLEAN AS
$add_tag$
DECLARE
    d_tag_id BIGINT;
BEGIN
    IF p_is_project IS NULL THEN
        RETURN FALSE;
    end if;

    SELECT t.id
    INTO d_tag_id
    FROM tags t
    WHERE t.name LIKE p_name;

    IF d_tag_id IS NULL THEN
        INSERT INTO tags (name) VALUES (p_name) RETURNING id INTO d_tag_id;
    end if;

    IF p_is_project IS TRUE AND EXISTS(SELECT 1 FROM projects p WHERE p.id = p_subject_id) THEN
        INSERT INTO relation_tag_project (project_id, tag_id) VALUES (p_subject_id, d_tag_id);
    ELSE
        PERFORM raise_custom_error('A0027');
    end if;

    IF p_is_project IS FALSE AND EXISTS(SELECT 1 FROM threads t WHERE t.id = p_subject_id) THEN
        INSERT INTO relation_tag_thread (thread_id, tag_id) VALUES (p_subject_id, d_tag_id);
    ELSE
        PERFORM raise_custom_error('A0028');
    end if;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'add_tag');
end;
$add_tag$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_tag(
    p_subject_id BIGINT,
    p_is_project BOOLEAN,
    p_name TEXT
)
    RETURNS BOOLEAN AS
$delete_tag$
DECLARE
    d_tag_id BIGINT;
BEGIN
    IF p_is_project IS NULL THEN
        RETURN FALSE;
    end if;

    SELECT t.id
    INTO d_tag_id
    FROM tags t
    WHERE t.name LIKE p_name;

    IF d_tag_id IS NULL THEN
        PERFORM raise_custom_error('A0031');
    end if;

    IF p_is_project IS TRUE AND EXISTS(SELECT 1 FROM projects p WHERE p.id = p_subject_id) THEN
        DELETE FROM relation_tag_project rtp WHERE rtp.project_id = p_subject_id AND rtp.tag_id = d_tag_id;
    ELSE
        PERFORM raise_custom_error('A0027');
    end if;

    IF p_is_project IS FALSE AND EXISTS(SELECT 1 FROM threads t WHERE t.id = p_subject_id) THEN
        DELETE FROM relation_tag_thread rtt WHERE rtt.thread_id = p_subject_id AND rtt.tag_id = d_tag_id;
    ELSE
        PERFORM raise_custom_error('A0028');
    end if;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_tag');
end;
$delete_tag$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_score(
    p_likes BIGINT,
    p_saves BIGINT
)
    RETURNS BIGINT AS
$get_score$
BEGIN
    RETURN p_likes + 10 * p_saves;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'get_score');
end;
$get_score$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION save_best(
    p_year INT
)
    RETURNS BOOLEAN AS
$save_best$
BEGIN
    IF p_year <= 2022 THEN
        PERFORM raise_custom_error('A0033');
    end if;

    INSERT INTO best_threads (thread_id, year)
    SELECT t.thread_id, p_year
    FROM top_3_threads t
    ON CONFLICT (thread_id, year) DO NOTHING;

    INSERT INTO best_threads (thread_id, year)
    SELECT p.project_id, p_year
    FROM top_3_projects p
    ON CONFLICT (thread_id, year) DO NOTHING;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'save_best');
end;
$save_best$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION modify_project(
    p_project_id BIGINT,
    p_content TEXT
)
    RETURNS BOOLEAN AS
$modify_project$
BEGIN
    IF p_content IS NULL THEN
        RETURN FALSE;
    end if;

    IF p_project_id IS NOT NULL AND EXISTS(SELECT 1 FROM projects p WHERE p.id = p_project_id) THEN
        UPDATE projects p
        SET content = p_content
        WHERE p.id = p_project_id;
    ELSE
        PERFORM raise_custom_error('A0027');
    end if;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'modify_project');

end;
$modify_project$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION modify_project_comment(
    p_project_comment_id BIGINT,
    p_content TEXT
)
    RETURNS BOOLEAN AS
$modify_project_comment$
BEGIN
    IF p_content IS NULL THEN
        RETURN FALSE;
    end if;

    IF p_project_comment_id IS NOT NULL AND
       EXISTS(SELECT 1 FROM project_comment pc WHERE pc.id = p_project_comment_id) THEN
        UPDATE project_comment pc
        SET content = p_content
        WHERE pc.id = p_project_comment_id;
    ELSE
        PERFORM raise_custom_error('A0029');
    end if;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'modify_project_comment');

end;
$modify_project_comment$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION modify_thread(
    p_thread_id BIGINT,
    p_content TEXT
)
    RETURNS BOOLEAN AS
$modify_thread$
BEGIN
    IF p_content IS NULL THEN
        RETURN FALSE;
    end if;

    IF p_thread_id IS NOT NULL AND EXISTS(SELECT 1 FROM threads t WHERE t.id = p_thread_id) THEN
        UPDATE threads t
        SET content = p_content
        WHERE t.id = p_thread_id;
    ELSE
        PERFORM raise_custom_error('A0028');
    end if;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'modify_thread');

end;
$modify_thread$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION modify_thread_comment(
    p_thread_comment_id BIGINT,
    p_content TEXT
)
    RETURNS BOOLEAN AS
$modify_thread_comment$
BEGIN
    IF p_content IS NULL THEN
        RETURN FALSE;
    end if;

    IF p_thread_comment_id IS NOT NULL AND
       EXISTS(SELECT 1 FROM thread_comment tc WHERE tc.id = p_thread_comment_id) THEN
        UPDATE thread_comment tc
        SET content = p_content
        WHERE tc.id = p_thread_comment_id;
    ELSE
        PERFORM raise_custom_error('A0029');
    end if;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'modify_thread_comment');

end;
$modify_thread_comment$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION user_create(
    p_name TEXT,
    p_surname TEXT,
    p_login TEXT,
    p_email TEXT,
    p_gender TEXT,
    p_role TEXT,
    p_pass_hash TEXT
)
    RETURNS TABLE
            (
                login TEXT,
                role  TEXT
            )
AS
$register_user$
DECLARE
    d_gender_id BIGINT;
    d_role_id   BIGINT;
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
               WHERE u.login LIKE p_login) THEN
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

    RETURN QUERY
        INSERT INTO "users" (role_id, name, surname, gender_id, login, email, pass_hash)
            VALUES (d_role_id, p_name, p_surname, d_gender_id,
                    p_login, p_email, p_pass_hash)
            RETURNING "users".login, p_role;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'register_user');
end;
$register_user$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_login_credentials(
    p_login TEXT,
    p_email TEXT
)
    RETURNS TABLE
            (
                login TEXT,
                passHash TEXT,
                role     TEXT
            )
AS
$check_login_credentials$
DECLARE
    d_user_id     BIGINT;
    d_email_empty BOOLEAN;
    d_login_empty BOOLEAN;
    d_pass_hash   TEXT;
    d_return_role TEXT;
    d_return_login TEXT;
BEGIN
    IF p_email IS NULL OR length(p_email) = 0 THEN
        d_email_empty := TRUE;
    ELSE
        d_email_empty := FALSE;
    end if;

    IF p_login IS NULL OR length(p_login) = 0 THEN
        d_login_empty := TRUE;
    ELSE
        d_login_empty := FALSE;
    end if;

    IF d_login_empty AND d_email_empty THEN
        PERFORM raise_custom_error('A0024');
    end if;

    IF d_login_empty IS FALSE THEN
        SELECT u.id, r.name, u.pass_hash, u.login
        INTO d_user_id, d_return_role, d_pass_hash, d_return_login
        FROM users u
                 INNER JOIN roles r ON u.role_id = r.id
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    ELSE
        SELECT u.id, r.name, u.pass_hash, u.login
        INTO d_user_id, d_return_role, d_pass_hash, d_return_login
        FROM users u
                 INNER JOIN roles r ON u.role_id = r.id
        WHERE u.email = p_email
          AND u.delete_date IS NULL;
    end if;


    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0026');
    end if;

    RETURN QUERY SELECT d_return_login, d_pass_hash, d_return_role;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'check_login_credentials');
end;
$check_login_credentials$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_user_token(
    p_login TEXT,
    p_token TEXT,
    p_expire_time TIMESTAMP
)
    RETURNS TEXT AS
$set_user_token$
DECLARE
    d_token_content TEXT;
    d_token_id      BIGINT;
BEGIN
    IF EXISTS(SELECT 1 FROM users u WHERE u.login = p_login AND u.delete_date IS NOT NULL) THEN
        PERFORM raise_custom_error('A0019');
    end if;

    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.login = p_login
      AND u.delete_date IS NULL;


    IF d_token_id IS NULL THEN
        INSERT INTO tokens (token, expire_time)
        VALUES (p_token, p_expire_time)
        RETURNING id INTO d_token_id;
    ELSE
        UPDATE tokens t
        SET token       = p_token,
            expire_time = p_expire_time
        WHERE t.id = d_token_id;
    end if;

    UPDATE users u
    SET token_id = d_token_id
    WHERE u.login = p_login
      AND u.delete_date IS NULL;


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
    p_login TEXT
)
    RETURNS TABLE
            (
                token       TEXT,
                expire_time TIMESTAMP,
                create_time TIMESTAMP
            )
AS
$set_user_token$
DECLARE
    d_token_content TEXT;
    d_expire_time   TIMESTAMP;
    d_create_time   TIMESTAMP;
    d_token_id      BIGINT;
BEGIN
    IF EXISTS(SELECT 1 FROM users u WHERE u.login = p_login AND u.delete_date IS NOT NULL) IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.login = p_login
      AND u.delete_date IS NULL;

    IF d_token_id IS NULL THEN
        RETURN QUERY SELECT NULL, NULL, NULL;
    end if;

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
    p_login TEXT
)
    RETURNS BOOLEAN AS
$set_user_token$
DECLARE
    d_token_id BIGINT;
BEGIN
    IF EXISTS(SELECT 1 FROM users u WHERE u.login = p_login AND u.delete_date IS NOT NULL) IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    SELECT u.token_id
    INTO d_token_id
    FROM users u
    WHERE u.login = p_login
      AND u.delete_date IS NULL;

    IF d_token_id IS NULL THEN
        RETURN TRUE;
    end if;

    UPDATE users u
    SET token_id = NULL
    WHERE u.login = p_login;

    DELETE
    FROM tokens t
    WHERE t.id = d_token_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_user_token');
end;
$set_user_token$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_user(
    p_login TEXT
)
    RETURNS BOOLEAN AS
$delete_user$
DECLARE
    d_user_id BIGINT;
BEGIN
    IF p_login IS NOT NULL THEN
        SELECT u.id
        INTO d_user_id
        FROM users u
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    end if;

    IF d_user_id IS NOT NULL THEN
        UPDATE users u
        SET delete_date = now()
        WHERE u.id = d_user_id;

        RETURN TRUE;
    end if;

    PERFORM raise_custom_error('A0019');
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'delete_user');
end;
$delete_user$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION modify_user(
    p_login TEXT,
    p_new_login TEXT,
    p_new_email TEXT,
    p_new_pass_hash TEXT,
    p_new_name TEXT,
    p_new_surname TEXT,
    p_new_gender TEXT,
    p_new_role TEXT
)
    RETURNS TABLE
            (
                login   TEXT,
                email   TEXT,
                name    TEXT,
                surname TEXT,
                gender  TEXT
            )
AS
$modify_user$
DECLARE
    d_user_id   BIGINT;
    d_gender_id SMALLINT;
    d_role_id   SMALLINT;
BEGIN
    IF p_login IS NOT NULL AND length(p_login) > 0 THEN
        SELECT u.id
        INTO d_user_id
        FROM users u
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    ELSE
        PERFORM raise_custom_error('A0019');
    end if;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    IF p_new_login IS NOT NULL AND length(p_new_login) > 0 THEN
        UPDATE users u
        SET login = p_new_login
        WHERE u.id = d_user_id;
    end if;

    IF p_new_email IS NOT NULL AND length(p_new_email) > 0 THEN
        IF p_new_email !~ '^[^@]+@[^@]+\.[^@]+$' THEN
            PERFORM raise_custom_error('A0001');
        end if;

        UPDATE users u
        SET email = p_new_email
        WHERE u.id = d_user_id;
    end if;

    IF p_new_pass_hash IS NOT NULL AND length(p_new_pass_hash) > 0 THEN
        UPDATE users u
        SET pass_hash = p_new_pass_hash
        WHERE u.id = d_user_id;
    end if;

    IF p_new_name IS NOT NULL AND length(p_new_name) > 0 THEN
        UPDATE users u
        SET name = p_new_name
        WHERE u.id = d_user_id;
    end if;

    IF p_new_surname IS NOT NULL AND length(p_new_surname) > 0 THEN
        UPDATE users u
        SET surname = p_new_surname
        WHERE u.id = d_user_id;
    end if;

    IF p_new_gender IS NOT NULL AND length(p_new_gender) > 0 THEN
        SELECT g.id
        INTO d_gender_id
        FROM genders g
        WHERE g.name = p_new_gender;

        IF d_gender_id IS NOT NULL THEN
            UPDATE users u
            SET gender_id = d_gender_id
            WHERE u.id = d_user_id;
        end if;
    end if;

    IF p_new_role IS NOT NULL AND length(p_new_role) > 0 THEN
        SELECT r.id
        INTO d_role_id
        FROM roles r
        WHERE r.name = p_new_role;

        IF d_role_id IS NOT NULL THEN
            UPDATE users u
            SET role_id = d_role_id
            WHERE u.id = d_user_id;
        end if;
    end if;

    RETURN QUERY
        SELECT ui.login, ui.email, ui.name, ui.surname, ui.gender
        FROM users_info ui
        WHERE ui.id = d_user_id;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'modify_user');

end;
$modify_user$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_data(
    p_login TEXT
)
    RETURNS TABLE
            (
                Login       TEXT,
                Email       TEXT,
                Role        TEXT,
                Name        TEXT,
                Surname     TEXT,
                Gender      TEXT,
                blocked     BOOLEAN,
                Join_date   TIMESTAMP,
                modify_date TIMESTAMP,
                delete_date TIMESTAMP
            )
AS
$get_user_data$
DECLARE
    d_user_id BIGINT;
BEGIN
    IF p_login IS NOT NULL AND length(p_login) > 0 THEN
        SELECT u.id
        INTO d_user_id
        FROM users u
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    ELSE
        PERFORM raise_custom_error('A0026');
    end if;

    IF d_user_id IS NULL THEN
        PERFORM raise_custom_error('A0019');
    end if;

    RETURN QUERY SELECT ui.Login,
                        ui.Email,
                        ui.Role,
                        ui.Name,
                        ui.Surname,
                        ui.Gender,
                        u.blocked,
                        ui.Join_date,
                        ui.modify_date,
                        u.delete_date
                 FROM users_info ui
                          INNER JOIN users u ON ui.login = u.login
                 WHERE u.id = d_user_id;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'get_user_data');
end;
$get_user_data$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION block_user(
    p_login TEXT
) RETURNS BOOLEAN AS
$block_user$
DECLARE
    d_user_id BIGINT;
BEGIN
    IF p_login IS NOT NULL AND length(p_login) > 0 THEN
        SELECT u.id
        INTO d_user_id
        FROM users u
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    ELSE
        PERFORM raise_custom_error('A0026');
    end if;

    IF d_user_id IS NOT NULL THEN
        UPDATE users u
        SET blocked = TRUE
        WHERE u.id = d_user_id;
    ELSE
        PERFORM raise_custom_error('A0019');
    end if;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'block_user');
end;
$block_user$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_if_user_blocked(
    p_login TEXT
) RETURNS BOOLEAN AS
$check_if_user_blocked$
DECLARE
    d_user_id BIGINT;
    d_result  BOOLEAN;
BEGIN
    IF p_login IS NOT NULL AND length(p_login) > 0 THEN
        SELECT u.id
        INTO d_user_id
        FROM users u
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    ELSE
        PERFORM raise_custom_error('A0026');
    end if;

    IF d_user_id IS NOT NULL THEN
        SELECT u.blocked
        INTO d_result
        FROM users u
        WHERE u.id = d_user_id;
    ELSE
        PERFORM raise_custom_error('A0019');
    end if;

    RETURN d_result;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'check_if_user_blocked');
end;
$check_if_user_blocked$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unblock_user(
    p_login TEXT
) RETURNS BOOLEAN AS
$unblock_user$
DECLARE
    d_user_id BIGINT;
BEGIN
    IF p_login IS NOT NULL AND length(p_login) > 0 THEN
        SELECT u.id
        INTO d_user_id
        FROM users u
        WHERE u.login = p_login
          AND u.delete_date IS NULL;
    ELSE
        PERFORM raise_custom_error('A0026');
    end if;

    IF d_user_id IS NOT NULL THEN
        UPDATE users u
        SET blocked = FALSE
        WHERE u.id = d_user_id;
    ELSE
        PERFORM raise_custom_error('A0019');
    end if;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'unblock_user');
end;
$unblock_user$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION user_score(
    p_project_num BIGINT,
    p_thread_num BIGINT,
    p_likes BIGINT,
    p_saves BIGINT,
    p_views BIGINT
) RETURNS BIGINT AS
$user_score$
BEGIN
    RETURN COALESCE(p_project_num, 0) * 20
        + COALESCE(p_thread_num, 0) * 20
        + COALESCE(p_likes, 0) * 4
        + COALESCE(p_saves, 0) * 8
        + COALESCE(p_views, 0);
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'user_score');
end;
$user_score$
    LANGUAGE plpgsql;
