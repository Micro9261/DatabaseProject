DROP TRIGGER IF EXISTS trg_prepare_proj ON projects;
DROP TRIGGER IF EXISTS trg_prepare_thread ON threads;
DROP TRIGGER IF EXISTS trg_prepare_report_type ON report_type;
DROP TRIGGER IF EXISTS trg_prepare_report_subject ON report_subject;
DROP TRIGGER IF EXISTS trg_prepare_genders ON genders;
DROP TRIGGER IF EXISTS trg_prepare_roles ON roles;
DROP TRIGGER IF EXISTS trg_prepare_user ON users;

DROP TABLE IF EXISTS error_codes CASCADE;
DROP TABLE IF EXISTS tokens CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS genders CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS project_comment CASCADE;
DROP TABLE IF EXISTS threads_comment CASCADE;
DROP TABLE IF EXISTS report_subject CASCADE;
DROP TABLE IF EXISTS report_type CASCADE;
DROP TABLE IF EXISTS report_notifications CASCADE;
DROP TABLE IF EXISTS tokens CASCADE;
DROP TABLE IF EXISTS best_threads CASCADE;
DROP TABLE IF EXISTS best_projects CASCADE;

DROP TABLE IF EXISTS relation_tag_project CASCADE;

--Trigger functions
DROP FUNCTION IF EXISTS prepare_on_insert_projects;
DROP FUNCTION IF EXISTS prepare_on_insert_thread;
DROP FUNCTION IF EXISTS prepare_on_insert_report_type;
DROP FUNCTION IF EXISTS prepare_on_insert_report_subject;
DROP FUNCTION IF EXISTS prepare_on_insert_gender;
DROP FUNCTION IF EXISTS prepare_on_insert_roles;
DROP FUNCTION IF EXISTS prepare_on_insert_users;

--Error handling
DROP FUNCTION IF EXISTS raise_custom_error;
DROP FUNCTION IF EXISTS handle_error;
DROP FUNCTION IF EXISTS add_error_code;

--API functions
DROP FUNCTION IF EXISTS register_user(p_name text, p_surname text, p_nickname text, p_email text, p_gender text,
                                      p_role text, p_pass_hash text);
DROP FUNCTION IF EXISTS add_project(p_title text, p_author text, p_content text);
DROP FUNCTION IF EXISTS add_project_comment(p_project_id bigint, p_parent_id bigint, p_author text, p_content text);
DROP FUNCTION IF EXISTS get_project_comments(p_project_id bigint);
DROP FUNCTION IF EXISTS add_thread(p_title text, p_author text, p_content text);
DROP FUNCTION IF EXISTS add_thread_comment(p_thread_id bigint, p_parent_id bigint, p_author text, p_content text);
DROP FUNCTION IF EXISTS get_thread_comments(p_thread_id bigint);
DROP FUNCTION IF EXISTS set_user_token(p_nickname text, p_token text);
DROP FUNCTION IF EXISTS get_user_token(p_nickname text);
DROP FUNCTION IF EXISTS delete_user_token(p_nickname text);
DROP FUNCTION IF EXISTS check_login_credentials(p_nickname text, p_email text, p_pass_hash text);

--Views
DROP VIEW IF EXISTS users_info;
DROP VIEW IF EXISTS projects_info;
DROP VIEW IF EXISTS threads_info;