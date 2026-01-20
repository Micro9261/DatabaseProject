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

CREATE OR REPLACE VIEW projects_info AS
SELECT 
    p.id AS project_id,
    p.title AS title,
    u.login AS author,
    p.create_date AS create_date,
    p.modify_date As modify_date,
    p.views AS views,
    p.content AS content,
    (p.delete_date IS NULL) AS active,
    (SELECT COUNT(*) FROM relation_project_like rpl WHERE rpl.project_id = p.id) AS likes,
    (SELECT COUNT(*) FROM relation_project_save rps WHERE rps.project_id = p.id) AS saves,
    (SELECT COUNT(*) FROM project_comment pc WHERE pc.project_id = p.id) AS comments
FROM projects p
LEFT JOIN users u ON u.id = p.author_id;


CREATE OR REPLACE VIEW projects_comments_info AS
SELECT 
    pc.id AS project_comm_id,
    pc.parent_id AS parent_comm_id,
    pc.project_id AS project_id,
    u.login AS author,
    pc.create_date AS create_date,
    pc.content AS content,
    (pc.delete_date IS NULL) AS active,
    (SELECT COUNT(*) 
     FROM relation_project_comment_like rpcl 
     WHERE rpcl.project_comment_id = pc.id) AS likes,
    (SELECT COUNT(*) 
     FROM relation_project_comment_interest rpci 
     WHERE rpci.project_comment_id = pc.id) AS interest
FROM project_comment pc
LEFT JOIN users u ON u.id = pc.author_id;

CREATE OR REPLACE VIEW threads_info AS
SELECT 
    t.id AS thread_id,
    t.title AS title,
    u.login AS author,
    t.create_date AS create_date,
    t.modify_date AS modify_date,
    t.views AS views,
    t.content AS content,
    (t.delete_date IS NULL) AS active,
    (SELECT COUNT(*) FROM relation_thread_like rtl WHERE rtl.thread_id = t.id) AS likes,
    (SELECT COUNT(*) FROM relation_thread_save rts WHERE rts.thread_id = t.id) AS saves,
    (SELECT COUNT(*) FROM thread_comment tc WHERE tc.thread_id = t.id) AS comments
FROM threads t
LEFT JOIN users u ON u.id = t.author_id;

CREATE OR REPLACE VIEW threads_comments_info AS
SELECT 
    tc.id AS thread_comm_id,
    tc.parent_id AS parent_comm_id,
    tc.thread_id AS thread_id,
    u.login AS author,
    tc.create_date AS create_date,
    tc.content AS content,
    (tc.delete_date IS NULL) AS active,
    (SELECT COUNT(*) 
     FROM relation_thread_comment_like rtcl 
     WHERE rtcl.thread_comment_id = tc.id) AS likes,
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
ORDER BY score DESC, create_date DESC;

CREATE OR REPLACE VIEW top_threads AS
SELECT *
FROM (SELECT *, get_score(likes, saves, views, comments) AS score FROM threads_info) t
ORDER BY score DESC, create_date DESC;

CREATE OR REPLACE VIEW top_threads_comments AS
SELECT *
FROM (SELECT *, get_score(likes, interest, 0, 0) AS score FROM threads_comments_info) t
ORDER BY score DESC, create_date DESC;

CREATE OR REPLACE VIEW top_tags AS
SELECT ti.tag_id AS id,
       ti.name AS name
FROM tags_info ti
ORDER BY ti.project_count + ti.thread_count DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_users AS
WITH project_stats AS (
    SELECT 
        author,
        SUM(likes) AS p_likes,
        SUM(saves) AS p_saves,
        SUM(views) AS p_views
    FROM projects_info pi WHERE pi.active IS TRUE
    GROUP BY author
),
thread_stats AS (
    SELECT 
        author,
        SUM(likes) AS t_likes,
        SUM(saves) AS t_saves,
        SUM(views) AS t_views
    FROM threads_info ti WHERE ti.active IS TRUE
    GROUP BY author
)
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

    COALESCE(ps.p_likes, 0) AS likes,
    COALESCE(ps.p_saves, 0) AS saves,
    COALESCE(ps.p_views, 0) AS project_views,
    COALESCE(ts.t_likes, 0) AS thread_likes,
    COALESCE(ts.t_saves, 0) AS thread_saves,
    COALESCE(ts.t_views, 0) AS thread_views,

    (COALESCE(ps.p_views, 0) + COALESCE(ts.t_views, 0)) AS total_views,

    user_score(
        ui.projects,
        ui.threads,
        (COALESCE(ps.p_likes, 0) + COALESCE(ts.t_likes, 0))::BIGINT,
        (COALESCE(ps.p_saves, 0) + COALESCE(ts.t_saves, 0))::BIGINT,
        (COALESCE(ps.p_views, 0) + COALESCE(ts.t_views, 0))::BIGINT
    ) AS score,

    ui.join_date
FROM users_info ui
LEFT JOIN project_stats ps ON ui.login = ps.author
LEFT JOIN thread_stats ts  ON ui.login = ts.author
WHERE ui.active = TRUE;