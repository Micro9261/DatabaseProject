CREATE OR REPLACE FUNCTION user_projects(
    p_login TEXT
)
    RETURNS TABLE
            (
                project_id  BIGINT,
                title       TEXT,
                author      TEXT,
                create_date TIMESTAMP,
                likes       BIGINT,
                saves       BIGINT,
                views       BIGINT,
                comments    BIGINT,
                content     TEXT
            )
AS
$user_projects$
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


    RETURN QUERY
        SELECT pi.project_id,
               pi.title,
               pi.author,
               pi.create_date,
               pi.likes,
               pi.saves,
               pi.views,
               pi.comments,
               pi.content
        FROM projects_info pi
        WHERE pi.author = p_login;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'user_projects');
end;
$user_projects$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION user_threads(
    p_login TEXT
)
    RETURNS TABLE
            (
                thread_id   BIGINT,
                title       TEXT,
                author      TEXT,
                create_date TIMESTAMP,
                likes       BIGINT,
                saves       BIGINT,
                views       BIGINT,
                comments    BIGINT,
                content     TEXT
            )
AS
$user_threads$
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


    RETURN QUERY
        SELECT ti.thread_id,
               ti.title,
               ti.author,
               ti.create_date,
               ti.likes,
               ti.saves,
               ti.views,
               ti.comments,
               ti.content
        FROM threads_info ti
        WHERE ti.author = p_login;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'user_projects');
end;
$user_threads$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION user_comments(
    p_login TEXT
)
    RETURNS TABLE
            (
                comment_id  BIGINT,
                title       TEXT,
                create_date TIMESTAMP,
                likes       BIGINT,
                interest    BIGINT,
                content     TEXT
            )
AS
$user_comments$
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


    RETURN QUERY
        SELECT pci.project_comm_id AS comment_id,
               p.title,
               pci.create_date,
               pci.likes,
               pci.interest,
               pci.content
        FROM projects_comments_info pci
                 INNER JOIN projects p ON p.id = pci.project_id
        WHERE pci.author = p_login;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM handle_error(SQLSTATE, SQLERRM, 'user_comments');
end;
$user_comments$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_project_comments_dfs(
    p_project_id BIGINT,
    p_login TEXT
)
    RETURNS TABLE
            (
                comment_id   BIGINT,
                project_id   BIGINT,
                author       TEXT,
                content      TEXT,
                create_date  TIMESTAMP,
                likes        BIGINT,
                interest     BIGINT,
                depth        INT,
                set_like     BOOLEAN,
                set_interest BOOLEAN
            )
    LANGUAGE sql
AS
$$
WITH RECURSIVE comment_dfs AS
                   (
                       -- 1️⃣ Root comments (stack initialization)
                       SELECT pc.project_comm_id         AS comment_id,
                              pc.project_id,
                              pc.author,
                              pc.content,
                              pc.create_date,
                              pc.likes,
                              pc.interest,
                              0                          AS depth,
                              ARRAY [pc.project_comm_id] AS path
                       FROM projects_comments_info pc
                       WHERE pc.project_id = p_project_id
                         AND pc.parent_comm_id IS NULL AND pc.active IS TRUE

                       UNION ALL

                       -- 2️⃣ Depth-first expansion (stack push)
                       SELECT c.project_comm_id,
                              c.project_id,
                              c.author,
                              c.content,
                              c.create_date,
                              c.likes,
                              c.interest,
                              p.depth + 1,
                              p.path || c.project_comm_id
                       FROM projects_comments_info c
                                JOIN comment_dfs p
                                     ON c.parent_comm_id = p.comment_id
                       WHERE NOT c.project_comm_id = ANY (p.path) -- cycle protection
                       AND c.active IS TRUE
                       AND c.project_id = p_project_id
                   )


SELECT d.comment_id,
       d.project_id,
       d.author,
       d.content,
       d.create_date,
       d.likes,
       d.interest,
       depth,
       CASE
           WHEN p_login IS NULL THEN FALSE
           ELSE EXISTS(SELECT 1
                       FROM relation_project_comment_like rpcl
                                JOIN users_info ui ON ui.id = rpcl.user_id
                       WHERE rpcl.project_comment_id = d.comment_id
                       AND ui.login = p_login
                         AND rpcl.delete_date IS NULL) END AS set_likes,
       CASE
           WHEN p_login IS NULL THEN FALSE
           ELSE EXISTS(SELECT 1
                       FROM relation_project_comment_interest rpci
                                INNER JOIN users_info ui ON ui.id = rpci.user_id
                       WHERE rpci.project_comment_id = d.comment_id
                       AND ui.login = p_login
                         AND rpci.delete_date IS NULL) END AS set_interest
FROM comment_dfs d
ORDER BY path, create_date;
$$;

CREATE OR REPLACE FUNCTION get_thread_comments_dfs(
    p_thread_id BIGINT,
    p_login TEXT
)
    RETURNS TABLE
            (
                comment_id   BIGINT,
                thread_id   BIGINT,
                author       TEXT,
                content      TEXT,
                create_date  TIMESTAMP,
                likes        BIGINT,
                interest     BIGINT,
                depth        INT,
                set_like     BOOLEAN,
                set_interest BOOLEAN
            )
    LANGUAGE sql
AS
$$
WITH RECURSIVE comment_dfss AS
                   (
                       -- 1️⃣ Root comments (stack initialization)
                       SELECT pc.thread_comm_id         AS comment_id,
                              pc.thread_id,
                              pc.author,
                              pc.content,
                              pc.create_date,
                              pc.likes,
                              pc.interest,
                              0                          AS depth,
                              ARRAY [pc.thread_comm_id] AS path
                       FROM threads_comments_info pc
                       WHERE pc.thread_id = p_thread_id
                         AND pc.parent_comm_id IS NULL AND pc.active IS TRUE

                       UNION ALL

                       -- 2️⃣ Depth-first expansion (stack push)
                       SELECT c.thread_comm_id,
                              c.thread_id,
                              c.author,
                              c.content,
                              c.create_date,
                              c.likes,
                              c.interest,
                              p.depth + 1,
                              p.path || c.thread_comm_id
                       FROM threads_comments_info c
                                JOIN comment_dfss p
                                     ON c.parent_comm_id = p.comment_id
                       WHERE NOT c.thread_comm_id = ANY (p.path) -- cycle protection
                       AND c.active IS TRUE
                       AND c.thread_id = p.thread_id
                   )


SELECT d.comment_id,
       d.thread_id,
       d.author,
       d.content,
       d.create_date,
       d.likes,
       d.interest,
       depth,
       CASE
           WHEN p_login IS NULL THEN FALSE
           ELSE EXISTS(SELECT 1
                       FROM relation_thread_comment_like rpcl
                                JOIN users_info ui ON ui.id = rpcl.user_id
                       WHERE rpcl.thread_comment_id = d.comment_id
                       AND ui.login = p_login
                         AND rpcl.delete_date IS NULL) END AS set_like,
       CASE
           WHEN p_login IS NULL THEN FALSE
           ELSE EXISTS(SELECT 1
                       FROM relation_thread_comment_interest rpci
                                INNER JOIN users_info ui ON ui.id = rpci.user_id
                       WHERE rpci.thread_comment_id = d.comment_id
                       AND ui.login = p_login
                         AND rpci.delete_date IS NULL) END AS set_interest
FROM comment_dfss d
ORDER BY path, create_date;
$$;