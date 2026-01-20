--Triggers
DROP TRIGGER IF EXISTS trg_prepare_proj ON projects;
DROP TRIGGER IF EXISTS trg_prepare_thread ON threads;
DROP TRIGGER IF EXISTS trg_prepare_report_type ON report_type;
DROP TRIGGER IF EXISTS trg_prepare_report_subject ON report_subject;
DROP TRIGGER IF EXISTS trg_prepare_genders ON genders;
DROP TRIGGER IF EXISTS trg_prepare_roles ON roles;
DROP TRIGGER IF EXISTS trg_prepare_user ON users;
DROP TRIGGER IF EXISTS trg_prepare_tag ON tags;

--Trigger functions
DROP FUNCTION IF EXISTS prepare_on_insert_projects();
DROP FUNCTION IF EXISTS prepare_on_insert_thread();
DROP FUNCTION IF EXISTS prepare_on_insert_report_type();
DROP FUNCTION IF EXISTS prepare_on_insert_report_subject();
DROP FUNCTION IF EXISTS prepare_on_insert_gender();
DROP FUNCTION IF EXISTS prepare_on_insert_roles();
DROP FUNCTION IF EXISTS prepare_on_insert_users();
DROP FUNCTION IF EXISTS prepare_on_insert_tag();

--Tables
DROP TABLE IF EXISTS error_codes CASCADE;
DROP TABLE IF EXISTS tokens CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS genders CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS project_comment CASCADE;
DROP TABLE IF EXISTS threads CASCADE;
DROP TABLE IF EXISTS threads_comment CASCADE;
DROP TABLE IF EXISTS report_subject CASCADE;
DROP TABLE IF EXISTS report_type CASCADE;
DROP TABLE IF EXISTS report_notifications CASCADE;
DROP TABLE IF EXISTS best_threads CASCADE;
DROP TABLE IF EXISTS best_projects CASCADE;
DROP TABLE IF EXISTS relation_tag_project CASCADE;
DROP TABLE IF EXISTS relation_tag_thread CASCADE;
DROP TABLE IF EXISTS relation_project_like CASCADE;
DROP TABLE IF EXISTS relation_project_save CASCADE;
DROP TABLE IF EXISTS relation_project_comment_like CASCADE;
DROP TABLE IF EXISTS relation_project_comment_interest CASCADE;
DROP TABLE IF EXISTS relation_thread_like CASCADE;
DROP TABLE IF EXISTS relation_thread_save CASCADE;
DROP TABLE IF EXISTS relation_thread_comment_like CASCADE;
DROP TABLE IF EXISTS relation_thread_comment_interest CASCADE;

--Error handling
DROP FUNCTION IF EXISTS raise_custom_error(p_error_code text);
DROP FUNCTION IF EXISTS handle_error(p_sqlstate text, p_sqlerrm text, p_function_name text);
DROP FUNCTION IF EXISTS add_error_code(p_error_code text, p_error_message text);

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
DROP FUNCTION IF EXISTS delete_user(p_nickname text, p_email text);
DROP FUNCTION IF EXISTS add_view(p_project_id bigint, p_thread_id bigint);
DROP FUNCTION IF EXISTS add_like(p_nickname text, p_project_id bigint, p_thread_id bigint, p_comment_id bigint);
DROP FUNCTION IF EXISTS delete_like(p_nickname text, p_project_id bigint, p_thread_id bigint, p_comment_id bigint);
DROP FUNCTION IF EXISTS add_save(p_nickname text, p_project_id bigint, p_thread_id bigint, p_comment_id bigint);
DROP FUNCTION IF EXISTS delete_save(p_nickname text, p_project_id bigint, p_thread_id bigint, p_comment_id bigint);
DROP FUNCTION IF EXISTS delete_project(p_project_id bigint);
DROP FUNCTION IF EXISTS delete_thread(p_thread_id bigint);
DROP FUNCTION IF EXISTS delete_comment(p_in_projects boolean, p_comment_id bigint);
DROP FUNCTION IF EXISTS add_report(p_project_id bigint, p_thread_id bigint, p_comment_id bigint, p_reporter text,
                                   p_reason text, p_content text);
DROP FUNCTION IF EXISTS delete_report(p_report_id bigint);
DROP FUNCTION IF EXISTS add_tag(p_subject_id bigint, p_is_project boolean, p_name text);
DROP FUNCTION IF EXISTS delete_tag(p_subject_id bigint, p_is_project boolean, p_name text);
DROP FUNCTION IF EXISTS get_score(p_likes bigint, p_saves bigint);
DROP FUNCTION IF EXISTS save_best(p_year integer);
DROP FUNCTION IF EXISTS modify_user(p_nickname text, p_email text, p_new_nickname text, p_new_email text,
                                    p_new_pass_hash text);
DROP FUNCTION IF EXISTS modify_project(p_project_id bigint, p_content text);
DROP FUNCTION IF EXISTS modify_project_comment(p_project_comment_id bigint, p_content text);
DROP FUNCTION IF EXISTS modify_thread(p_thread_id bigint, p_content text);
DROP FUNCTION IF EXISTS modify_thread_comment(p_thread_comment_id bigint, p_content text);
DROP FUNCTION IF EXISTS get_user_data(p_nickname text, p_email text);

--Views
DROP VIEW IF EXISTS users_info;
DROP VIEW IF EXISTS projects_info;
DROP VIEW IF EXISTS projects_comments_info;
DROP VIEW IF EXISTS threads_info;
DROP VIEW IF EXISTS threads_comments_info;
DROP VIEW IF EXISTS tags_info;
DROP VIEW IF EXISTS reports_info;
DROP VIEW IF EXISTS top_projects;
DROP VIEW IF EXISTS top_project_comments;
DROP VIEW IF EXISTS top_threads;
DROP VIEW IF EXISTS top_threads_comments;
DROP VIEW IF EXISTS top_tags;

DROP SCHEMA IF EXISTS project CASCADE;