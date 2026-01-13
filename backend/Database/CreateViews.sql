CREATE OR REPLACE VIEW users_info AS
SELECT u.nickname    AS Login,
       u.email       AS Email,
       r.name        AS Role,
       u.name        AS Name,
       u.surname     AS Surname,
       g.name        AS Gender,
       u.create_date AS Join_date
FROM users u
         INNER JOIN roles r ON r.id = u.role_id
         INNER JOIN genders g ON g.id = u.gender_id;

CREATE OR REPLACE VIEW projects_info AS
SELECT p.id                   AS project_id,
       p.title                AS title,
       u.nickname             AS author,
       p.create_date          AS create_date,
       COUNT(DISTINCT rpl.id) AS likes,
       COUNT(DISTINCT rps.id) AS saves,
       p.views                AS views,
       p.content              AS content
FROM projects p
         LEFT JOIN users u ON u.id = p.author_id
         LEFT JOIN relation_project_like rpl ON p.id = rpl.project_id
         LEFT JOIN relation_project_save rps ON p.id = rps.project_id
GROUP BY p.id, u.nickname, p.content;

CREATE OR REPLACE VIEW projects_comments_info AS
SELECT pc.id                   AS project_comm_id,
       pc.parent_id            AS parent_comm_id,
       pc.project_id           AS project_id,
       u.nickname              AS author,
       pc.create_date          AS create_date,
       COUNT(DISTINCT rpcl.id) AS likes,
       count(DISTINCT rpci.id) AS interest,
       pc.content              AS content
FROM project_comment pc
         LEFT JOIN users u ON u.id = pc.author_id
         LEFT JOIN relation_project_comment_like rpcl ON pc.id = rpcl.project_comment_id
         LEFT JOIN relation_project_comment_interest rpci ON pc.id = rpci.project_comment_id
GROUP BY pc.id, u.nickname, pc.content;

CREATE OR REPLACE VIEW threads_info AS
SELECT t.id                   AS thread_id,
       t.title                AS title,
       u.nickname             AS author,
       t.create_date          AS create_date,
       COUNT(DISTINCT rtl.id) AS likes,
       COUNT(DISTINCT rts.id) AS saves,
       t.views                AS views,
       t.content              AS content
FROM threads t
         LEFT JOIN users u ON u.id = t.author_id
         LEFT JOIN relation_thread_like rtl ON t.id = rtl.thread_id
         LEFT JOIN relation_thread_save rts ON t.id = rts.thread_id
GROUP BY t.id, u.nickname, t.content;

CREATE OR REPLACE VIEW threads_comments_info AS
SELECT tc.id                   AS thread_comm_id,
       tc.parent_id            AS parent_comm_id,
       tc.thread_id            AS thread_id,
       u.nickname              AS author,
       tc.create_date          AS create_date,
       COUNT(DISTINCT rtcl.id) AS likes,
       count(DISTINCT rtci.id) AS interest,
       tc.content              AS content
FROM thread_comment tc
         LEFT JOIN users u ON u.id = tc.author_id
         LEFT JOIN relation_thread_comment_like rtcl ON tc.id = rtcl.thread_comment_id
         LEFT JOIN relation_thread_comment_interest rtci ON tc.id = rtci.thread_comment_id
GROUP BY tc.id, u.nickname, tc.content;

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
       u.nickname AS author,
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

CREATE OR REPLACE VIEW top_3_projects AS
SELECT *
FROM (SELECT *, get_score(likes, saves) AS score FROM projects_info) t
ORDER BY score DESC, create_date DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_3_project_comments AS
SELECT *
FROM (SELECT *, get_score(likes, interest) AS score FROM projects_comments_info) t
ORDER BY score DESC, create_date DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_3_threads AS
SELECT *
FROM (SELECT *, get_score(likes, saves) AS score FROM threads_info) t
ORDER BY score DESC, create_date DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_3_threads_comments AS
SELECT *
FROM (SELECT *, get_score(likes, interest) AS score FROM threads_comments_info) t
ORDER BY score DESC, create_date DESC
LIMIT 3;

CREATE OR REPLACE VIEW top_3_tags AS
SELECT ti.tag_id AS id,
       ti.name AS name
FROM tags_info ti
ORDER BY ti.project_count + ti.thread_count DESC
LIMIT 3;