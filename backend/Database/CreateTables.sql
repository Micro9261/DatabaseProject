CREATE TABLE IF NOT EXISTS error_codes
(
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    error_code    TEXT NOT NULL UNIQUE,
    error_message TEXT NOT NULL DEFAULT 'Not specified!' UNIQUE
);

CREATE TABLE IF NOT EXISTS tokens
(
    id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    token TEXT NOT NULL DEFAULT 'Not specified',
    create_time TIMESTAMP DEFAULT now(),
    expire_time BIGINT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS roles
(
    id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Unknown' UNIQUE
);

CREATE TABLE IF NOT EXISTS role_permissions
(
    id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id BIGINT NOT NULL REFERENCES roles (id),
    name    TEXT   NOT NULL DEFAULT 'Not specified'
);

CREATE TABLE IF NOT EXISTS genders
(
    id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Not specified'
);

CREATE TABLE IF NOT EXISTS users
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id     BIGINT NOT NULL REFERENCES roles (id),
    token_id    BIGINT          DEFAULT 0 REFERENCES tokens (id),
    name        TEXT   NOT NULL DEFAULT 'Unknown',
    surname     TEXT   NOT NULL DEFAULT 'Unknown',
    gender_id   BIGINT NOT NULL REFERENCES genders (id),
    nickname    TEXT   NOT NULL DEFAULT 'No nickname' UNIQUE,
    email       TEXT   NOT NULL DEFAULT 'Unknown' UNIQUE,
    pass_hash   TEXT   NOT NULL DEFAULT 'Unknown',
    create_date TIMESTAMP            DEFAULT now()
);

CREATE TABLE IF NOT EXISTS projects
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id   BIGINT NOT NULL REFERENCES users (id),
    title       TEXT   NOT NULL DEFAULT 'Unknown',
    content     TEXT   NOT NULL DEFAULT 'Empty',
    create_date TIMESTAMP            DEFAULT now(),
    likes       INT             DEFAULT 0,
    saves       INT             DEFAULT 0,
    views       INT             DEFAULT 0
);

CREATE TABLE IF NOT EXISTS tags
(
    id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  TEXT NOT NULL DEFAULT 'Not specified' UNIQUE,
    count INT           DEFAULT 0
);

CREATE TABLE IF NOT EXISTS project_comment
(
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id      BIGINT NOT NULL REFERENCES projects (id),
    parent_id       BIGINT          DEFAULT NULL REFERENCES project_comment (id),
    author_id       BIGINT NOT NULL REFERENCES users (id),
    content         TEXT   NOT NULL DEFAULT 'Empty',
    create_date     TIMESTAMP            DEFAULT now(),
    interest_points INT             DEFAULT 0,
    likes           INT             DEFAULT 0
);

CREATE TABLE IF NOT EXISTS threads
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id   BIGINT NOT NULL REFERENCES users (id),
    title       TEXT   NOT NULL DEFAULT 'Unknown',
    content     TEXT   NOT NULL DEFAULT 'Empty',
    create_date TIMESTAMP            DEFAULT now(),
    saves       INT             DEFAULT 0,
    likes       INT             DEFAULT 0,
    views       INT             DEFAULT 0
);

CREATE TABLE IF NOT EXISTS thread_comment
(
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    thread_id       BIGINT NOT NULL REFERENCES threads (id),
    parent_id       BIGINT          DEFAULT NULL REFERENCES thread_comment (id),
    author_id       BIGINT NOT NULL REFERENCES users (id),
    content         TEXT   NOT NULL DEFAULT 'Empty',
    create_date     TIMESTAMP            DEFAULT now(),
    interest_points INT             DEFAULT 0,
    likes           INT             DEFAULT 0
);

CREATE TABLE IF NOT EXISTS report_subject
(
    id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Not specified' UNIQUE
);

CREATE TABLE IF NOT EXISTS report_type
(
    id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Not specified' UNIQUE
);

CREATE TABLE IF NOT EXISTS report_notifications
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subject_id BIGINT NOT NULL REFERENCES report_subject (id),
    type_id    BIGINT NOT NULL REFERENCES report_type (id),
    content    TEXT   NOT NULL DEFAULT 'Empty'
);

CREATE TABLE IF NOT EXISTS best_threads
(
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    thread_id BIGINT NOT NULL REFERENCES threads (id),
    year      INT CHECK ( year > 2022 )
);

CREATE TABLE IF NOT EXISTS best_projects
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects (id),
    year       INT CHECK ( year > 2022 )
);

CREATE TABLE IF NOT EXISTS relation_tag_project
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects (id),
    tag_id     BIGINT NOT NULL REFERENCES tags (id)
);

CREATE TABLE IF NOT EXISTS relation_tag_thread
(
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    thread_id BIGINT NOT NULL REFERENCES threads (id),
    tag_id    BIGINT NOT NULL REFERENCES tags (id)
);
