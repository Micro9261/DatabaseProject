CREATE TABLE IF NOT EXISTS error_codes
(
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    error_code    TEXT NOT NULL UNIQUE,
    error_message TEXT NOT NULL DEFAULT 'Not specified!' UNIQUE
);

CREATE TABLE IF NOT EXISTS tokens
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    token       TEXT NOT NULL DEFAULT 'Not specified',
    create_time TIMESTAMP     DEFAULT now(),
    expire_time BIGINT        DEFAULT 0
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
    token_id    BIGINT          DEFAULT NULL REFERENCES tokens (id),
    name        TEXT   NOT NULL DEFAULT 'Unknown',
    surname     TEXT   NOT NULL DEFAULT 'Unknown',
    gender_id   BIGINT NOT NULL REFERENCES genders (id),
    nickname    TEXT   NOT NULL DEFAULT 'No nickname' UNIQUE,
    email       TEXT   NOT NULL DEFAULT 'Unknown' UNIQUE,
    pass_hash   TEXT   NOT NULL DEFAULT 'Unknown',
    create_date TIMESTAMP       DEFAULT now()
);

CREATE TABLE IF NOT EXISTS projects
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id   BIGINT,
    title       TEXT NOT NULL DEFAULT 'Unknown',
    content     TEXT NOT NULL DEFAULT 'Empty',
    create_date TIMESTAMP     DEFAULT now(),
    views       INT           DEFAULT 0,

    CONSTRAINT fk_project_author
        FOREIGN KEY (author_id)
            REFERENCES users (id)
            ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS tags
(
    id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL DEFAULT 'Not specified' UNIQUE
);

CREATE TABLE IF NOT EXISTS project_comment
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id  BIGINT NOT NULL,
    parent_id   BIGINT          DEFAULT NULL,
    author_id   BIGINT,
    content     TEXT   NOT NULL DEFAULT 'Empty',
    create_date TIMESTAMP       DEFAULT now(),

    CONSTRAINT fk_project_comment_parent
        FOREIGN KEY (parent_id)
            REFERENCES project_comment (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_project_comment_project
        FOREIGN KEY (project_id)
            REFERENCES projects (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_project_comment_author
        FOREIGN KEY (author_id)
            REFERENCES users (id)
            ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS threads
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id   BIGINT,
    title       TEXT NOT NULL DEFAULT 'Unknown',
    content     TEXT NOT NULL DEFAULT 'Empty',
    create_date TIMESTAMP     DEFAULT now(),
    views       INT           DEFAULT 0,

    CONSTRAINT fk_thread_author
        FOREIGN KEY (author_id)
            REFERENCES users (id)
            ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS thread_comment
(
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    thread_id   BIGINT NOT NULL,
    parent_id   BIGINT          DEFAULT NULL,
    author_id   BIGINT,
    content     TEXT   NOT NULL DEFAULT 'Empty',
    create_date TIMESTAMP       DEFAULT now(),

    CONSTRAINT fk_thread_comment_parent
        FOREIGN KEY (parent_id)
            REFERENCES thread_comment (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_thread_comment_project
        FOREIGN KEY (thread_id)
            REFERENCES threads (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_thread_comment_author
        FOREIGN KEY (author_id)
            REFERENCES users (id)
            ON DELETE SET NULL
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
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id       BIGINT NOT NULL,
    subject_id      BIGINT NOT NULL,
    subject_type_id BIGINT NOT NULL REFERENCES report_subject (id),
    type_id         BIGINT NOT NULL REFERENCES report_type (id),
    content         TEXT   NOT NULL DEFAULT 'Empty',
    report_date     TIMESTAMP       DEFAULT now(),

    CONSTRAINT fk_report_notifications_author
        FOREIGN KEY (author_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS best_threads
(
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    thread_id BIGINT NOT NULL,
    year      INT CHECK ( year > 2022 ),

    CONSTRAINT fk_best_threads_thread
        FOREIGN KEY (thread_id)
            REFERENCES threads (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS best_projects
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id BIGINT NOT NULL,
    year       INT CHECK ( year > 2022 ),

    CONSTRAINT fk_best_projects_projects
        FOREIGN KEY (project_id)
            REFERENCES projects (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_tag_project
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id BIGINT NOT NULL,
    tag_id     BIGINT NOT NULL REFERENCES tags (id),

    CONSTRAINT fk_relation_tag_project_projects
        FOREIGN KEY (project_id)
            REFERENCES projects (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_tag_thread
(
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    thread_id BIGINT NOT NULL,
    tag_id    BIGINT NOT NULL REFERENCES tags (id),

    CONSTRAINT fk_relation_tag_thread_projects
        FOREIGN KEY (thread_id)
            REFERENCES threads (id)
            ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS relation_project_like
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    project_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_project_like_project
        FOREIGN KEY (project_id)
            REFERENCES projects (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_project_like_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_project_save
(
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    project_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_project_like_project
        FOREIGN KEY (project_id)
            REFERENCES projects (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_project_like_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_project_comment_like
(
    id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id            BIGINT NOT NULL,
    project_comment_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_project_comment_like_project
        FOREIGN KEY (project_comment_id)
            REFERENCES project_comment (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_project_comment_like_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_project_comment_interest
(
    id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id            BIGINT NOT NULL,
    project_comment_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_project_comment_like_project
        FOREIGN KEY (project_comment_id)
            REFERENCES project_comment (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_project_comment_like_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_thread_like
(
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id   BIGINT NOT NULL,
    thread_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_project_like_project
        FOREIGN KEY (thread_id)
            REFERENCES threads (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_thread_like_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_thread_save
(
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id   BIGINT NOT NULL,
    thread_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_thread_save_project
        FOREIGN KEY (thread_id)
            REFERENCES threads (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_thread_save_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_thread_comment_like
(
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id           BIGINT NOT NULL,
    thread_comment_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_thread_comment_like_project
        FOREIGN KEY (thread_comment_id)
            REFERENCES thread_comment (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_thread_comment_like_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation_thread_comment_interest
(
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id           BIGINT NOT NULL,
    thread_comment_id BIGINT NOT NULL,

    CONSTRAINT fk_relation_thread_comment_interest_project
        FOREIGN KEY (thread_comment_id)
            REFERENCES thread_comment (id)
            ON DELETE CASCADE,

    CONSTRAINT fk_relation_thread_comment_interest_user
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE
);