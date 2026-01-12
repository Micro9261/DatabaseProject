CREATE OR REPLACE VIEW users_info AS
SELECT u.nickname    AS Login,
       u.email       AS Email,
       r.name        AS Role,
       u.name        AS Name,
       u.surname     AS Surname,
       g.name        AS Gender,
       u.create_date AS Join_date
FROM users u
         INNER JOIN roles r on r.id = u.role_id
         INNER JOIN genders g ON g.id = u.gender_id;

CREATE OR REPLACE VIEW projects_info AS
SELECT p.id          AS project_id,
       p.title       AS title,
       u.nickname    AS author,
       p.create_date AS create_date,
       p.likes       AS likes,
       p.saves       AS saves,
       p.views       AS views,
       p.content     AS content
FROM projects p
         INNER JOIN users u on u.id = p.author_id;

CREATE OR REPLACE VIEW threads_info AS
SELECT t.id          AS thread_id,
       t.title       AS title,
       u.nickname    AS author,
       t.create_date AS create_date,
       t.likes       AS likes,
       t.saves       AS saves,
       t.views       AS views,
       t.content     AS content
FROM threads t
         INNER JOIN users u on u.id = t.author_id;