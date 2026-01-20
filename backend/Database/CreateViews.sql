CREATE OR REPLACE VIEW users_info AS
SELECT u.id AS id,
    u.login    AS Login,
       u.email       AS Email,
       r.name        AS Role,
       u.name        AS Name,
       u.surname     AS Surname,
       g.name        AS Gender,
       COUNT(DISTINCT p.id) AS Projects,
       COUNT(DISTINCT t.id) AS Threads,
       COUNT(DISTINCT pc.id) + COUNT(DISTINCT tc.id) AS comments,
       u.create_date AS Join_date,
u.modify_date AS modify_date,
u.blocked AS blocked,
u.delete_date IS NULL AS active
FROM users u
         INNER JOIN roles r ON r.id = u.role_id
         INNER JOIN genders g ON g.id = u.gender_id
        LEFT JOIN projects p ON p.author_id = u.id
        LEFT JOIN threads t ON t.author_id = u.id
LEFT JOIN project_comment pc ON p.id = pc.project_id
LEFT JOIN thread_comment tc ON t.id = tc.thread_id
GROUP BY u.id, u.login, u.email, r.name, g.name;

-- CREATE OR REPLACE VIEW projects_info AS
-- SELECT p.id                   AS project_id,
--        p.title                AS title,
--        u.login             AS author,
--        p.create_date          AS create_date,
--        COUNT(DISTINCT rpl.id) AS likes,
--        COUNT(DISTINCT rps.id) AS saves,
--        p.views                AS views,
--        COUNT(DISTINCT pc.id) AS comments,
--        p.content              AS content,
--        p.delete_date IS NULL AS active
-- FROM projects p
--          LEFT JOIN users u ON u.id = p.author_id
--          LEFT JOIN relation_project_like rpl ON p.id = rpl.project_id
--          LEFT JOIN relation_project_save rps ON p.id = rps.project_id
--         LEFT JOIN project_comment pc ON pc.project_id = p.id
-- GROUP BY p.id,
--     p.title,
--     u.login,
--     p.create_date,
--     p.views,
--     p.content;
CREATE OR REPLACE VIEW projects_info AS
SELECT 
    p.id AS project_id,
    p.title AS title,
    u.login AS author,
    p.create_date AS create_date,
    p.views AS views,
    p.content AS content,
    (SELECT COUNT(*) FROM relation_project_like rpl WHERE rpl.project_id = p.id) AS likes,
    (SELECT COUNT(*) FROM relation_project_save rps WHERE rps.project_id = p.id) AS saves,
    (SELECT COUNT(*) FROM project_comment pc WHERE pc.project_id = p.id) AS comments
FROM projects p
LEFT JOIN users u ON u.id = p.author_id;

-- CREATE OR REPLACE VIEW projects_comments_info AS
-- SELECT pc.id                   AS project_comm_id,
--        pc.parent_id            AS parent_comm_id,
--        pc.project_id           AS project_id,
--        u.login              AS author,
--        pc.create_date          AS create_date,
--        COUNT(DISTINCT rpcl.id) AS likes,
--        count(DISTINCT rpci.id) AS interest,
--        pc.content              AS content,
--        pc.delete_date IS NULL AS active
-- FROM project_comment pc
--          LEFT JOIN users u ON u.id = pc.author_id
--          LEFT JOIN relation_project_comment_like rpcl ON pc.id = rpcl.project_comment_id
--          LEFT JOIN relation_project_comment_interest rpci ON pc.id = rpci.project_comment_id
-- GROUP BY pc.id, u.login, pc.content;

CREATE OR REPLACE VIEW projects_comments_info AS
SELECT 
    pc.id AS project_comm_id,
    pc.parent_id AS parent_comm_id,
    pc.project_id AS project_id,
    u.login AS author,
    pc.create_date AS create_date,
    pc.content AS content,
    (pc.delete_date IS NULL) AS active,
    -- Independent subqueries prevent the 'fan-out' effect
    (SELECT COUNT(*) 
     FROM relation_project_comment_like rpcl 
     WHERE rpcl.project_comment_id = pc.id) AS likes,
    (SELECT COUNT(*) 
     FROM relation_project_comment_interest rpci 
     WHERE rpci.project_comment_id = pc.id) AS interest
FROM project_comment pc
LEFT JOIN users u ON u.id = pc.author_id;


-- CREATE OR REPLACE VIEW threads_info AS
-- SELECT t.id                   AS thread_id,
--        t.title                AS title,
--        u.login             AS author,
--        t.create_date          AS create_date,
--        COUNT(DISTINCT rtl.id) AS likes,
--        COUNT(DISTINCT rts.id) AS saves,
--        t.views                AS views,
--        COUNT(DISTINCT tc.id) AS comments,
--        t.content              AS content,
--        t.delete_date IS NULL AS active
-- FROM threads t
--          LEFT JOIN users u ON u.id = t.author_id
--          LEFT JOIN relation_thread_like rtl ON t.id = rtl.thread_id
--          LEFT JOIN relation_thread_save rts ON t.id = rts.thread_id
-- LEFT JOIN thread_comment tc ON t.id = tc.thread_id
-- GROUP BY t.id, u.login, t.content;
CREATE OR REPLACE VIEW threads_info AS
SELECT 
    t.id AS thread_id,
    t.title AS title,
    u.login AS author,
    t.create_date AS create_date,
    t.views AS views,
    t.content AS content,
    (t.delete_date IS NULL) AS active,
    (SELECT COUNT(*) FROM relation_thread_like rtl WHERE rtl.thread_id = t.id) AS likes,
    (SELECT COUNT(*) FROM relation_thread_save rts WHERE rts.thread_id = t.id) AS saves,
    (SELECT COUNT(*) FROM thread_comment tc WHERE tc.thread_id = t.id) AS comments
FROM threads t
LEFT JOIN users u ON u.id = t.author_id;

-- CREATE OR REPLACE VIEW threads_comments_info AS
-- SELECT tc.id                   AS thread_comm_id,
--        tc.parent_id            AS parent_comm_id,
--        tc.thread_id            AS thread_id,
--        u.login              AS author,
--        tc.create_date          AS create_date,
--        COUNT(DISTINCT rtcl.id) AS likes,
--        count(DISTINCT rtci.id) AS interest,
--        tc.content              AS content,
--        tc.delete_date IS NULL AS active
-- FROM thread_comment tc
--          LEFT JOIN users u ON u.id = tc.author_id
--          LEFT JOIN relation_thread_comment_like rtcl ON tc.id = rtcl.thread_comment_id
--          LEFT JOIN relation_thread_comment_interest rtci ON tc.id = rtci.thread_comment_id
-- GROUP BY tc.id, u.login, tc.content;

CREATE OR REPLACE VIEW threads_comments_info AS
SELECT 
    tc.id AS thread_comm_id,
    tc.parent_id AS parent_comm_id,
    tc.thread_id AS thread_id,
    u.login AS author,
    tc.create_date AS create_date,
    tc.content AS content,
    (tc.delete_date IS NULL) AS active,
    -- Independent count for likes
    (SELECT COUNT(*) 
     FROM relation_thread_comment_like rtcl 
     WHERE rtcl.thread_comment_id = tc.id) AS likes,
    -- Independent count for interest
    (SELECT COUNT(*) 
     FROM relation_thread_comment_interest rtci 
     WHERE rtci.thread_comment_id = tc.id) AS interest
FROM thread_comment tc
LEFT JOIN users u ON u.id = tc.author_id;

CREATE OR REPLACE VIEW tags_info AS
SELECT t.id AS tag_id,
       t.name AS name,
       COALESCE(p.project_count, 0) AS project_count,
       COALESCE(th.thread_count, 0) AS thread_count
FROM tags t
    LEFT JOIN (SELECT  tag_id, COUNT(*) AS project_count
               FROM relation_tag_project GROUP BY tag_id) p ON p.tag_id = t.id
    LEFT JOIN (SELECT tag_id, COUNT(*) AS thread_count
               FROM relation_tag_thread GROUP BY tag_id) th On th.tag_id = t.id;

CREATE OR REPLACE VIEW reports_info AS
SELECT rn.id AS report_d,
       u.login AS author,
       rn.subject_id AS subject_id,
       rs.name AS subject,
       rt.name AS type,
       rn.content AS content,
       rn.report_date AS report_date
FROM report_notifications rn
    LEFT JOIN users u ON rn.author_id = u.id
    INNER JOIN report_type rt on rn.type_id = rt.id
    INNER JOIN report_subject rs on rn.subject_type_id = rs.id
ORDER BY rn.report_date;


CREATE OR REPLACE VIEW top_projects AS
SELECT *
FROM (SELECT *, get_score(likes, saves, views, comments) AS score FROM projects_info) t
ORDER BY score DESC, create_date DESC;

CREATE OR REPLACE VIEW top_project_comments AS
SELECT *
FROM (SELECT *, get_score(likes, interest, 0, 0) AS score FROM projects_comments_info) t
ORDER BY score DESC, create_date DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_threads AS
SELECT *
FROM (SELECT *, get_score(likes, saves, views, comments) AS score FROM threads_info) t
ORDER BY score DESC, create_date DESC;

CREATE OR REPLACE VIEW top_threads_comments AS
SELECT *
FROM (SELECT *, get_score(likes, interest, 0, 0) AS score FROM threads_comments_info) t
ORDER BY score DESC, create_date DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_tags AS
SELECT ti.tag_id AS id,
       ti.name AS name
FROM tags_info ti
ORDER BY ti.project_count + ti.thread_count DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_users AS
SELECT
    ui.id,
    ui.login,
    ui.email,
    ui.role,
    ui.name,
    ui.surname,
    ui.gender,
    ui.projects,
    ui.threads,

    -- aggregated activity
    COALESCE(SUM(pi.likes), 0)   AS likes,
    COALESCE(SUM(pi.saves), 0)   AS saves,
    COALESCE(SUM(pi.views), 0)   AS project_views,
    COALESCE(SUM(ti.likes), 0)   AS thread_likes,
    COALESCE(SUM(ti.saves), 0)   AS thread_saves,
    COALESCE(SUM(ti.views), 0)   AS thread_views,

    -- total views
    COALESCE(SUM(pi.views), 0) + COALESCE(SUM(ti.views), 0) AS total_views,

    -- score calculation
    user_score(
        ui.projects,
        ui.threads,
        CAST(COALESCE(SUM(pi.likes), 0) + COALESCE(SUM(ti.likes), 0) AS BIGINT),
        CAST(COALESCE(SUM(pi.saves), 0) + COALESCE(SUM(ti.saves), 0) AS BIGINT),
        CAST(COALESCE(SUM(pi.views), 0) + COALESCE(SUM(ti.views), 0) AS BIGINT)
    ) AS score,

    ui.join_date
FROM users_info ui
LEFT JOIN projects_info pi
       ON pi.author = ui.login
LEFT JOIN threads_info ti
       ON ti.author = ui.login
WHERE ui.active = TRUE
GROUP BY
    ui.id,
    ui.login,
    ui.email,
    ui.role,
    ui.name,
    ui.surname,
    ui.gender,
    ui.projects,
    ui.threads,
    ui.join_date
ORDER BY score DESC;