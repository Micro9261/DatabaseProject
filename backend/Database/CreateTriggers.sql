CREATE OR REPLACE TRIGGER trg_prepare_proj
    BEFORE INSERT
    ON projects
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_projects();

CREATE OR REPLACE TRIGGER trg_prepare_thread
    BEFORE INSERT
    ON threads
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_thread();

CREATE OR REPLACE TRIGGER trg_prepare_report_type
    BEFORE INSERT
    ON report_type
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_report_type();

CREATE OR REPLACE TRIGGER trg_prepare_report_subject
    BEFORE INSERT
    ON report_subject
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_report_subject();

CREATE OR REPLACE TRIGGER trg_prepare_genders
    BEFORE INSERT
    ON genders
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_gender();

CREATE OR REPLACE TRIGGER trg_prepare_roles
    BEFORE INSERT
    ON roles
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_roles();

CREATE OR REPLACE TRIGGER trg_prepare_user
    BEFORE INSERT
    ON users
    FOR EACH ROW
EXECUTE FUNCTION prepare_on_insert_users();