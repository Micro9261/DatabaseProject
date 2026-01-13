--errors

INSERT INTO error_codes (error_code, error_message)
VALUES ('A0001', 'Email not valid!'),
       ('A0002', 'Role does not exist!'),
       ('A0003', 'Gender not found in database!'),
       ('A0004', 'User already exist!'),
       ('A0005', 'Bad password!'),
       ('A0006', 'Bad token!'),
       ('A0007', 'Nickname required!'),
       ('A0008', 'Nickname already used!'),
       ('A0009', 'Name required!'),
       ('A0010', 'Surname required!'),
       ('A0011', 'Password required!'),
       ('A0012', 'Role required!'),
       ('A0013', 'Project needs title!'),
       ('A0014', 'Project needs author!'),
       ('A0015', 'Project needs content!'),
       ('A0016', 'Thread needs title!'),
       ('A0017', 'Thread needs author!'),
       ('A0018', 'Thread needs content!'),
       ('A0019', 'User not found!'),
       ('A0020', 'Report type needs to be specified!'),
       ('A0021', 'Report subject needs to be specified!'),
       ('A0022', 'Gender needs to be specified!'),
       ('A0023', 'Role needs to be specified!'),
       ('A0024', 'Nickname or email required!'),
       ('A0025', 'Bad email or nickname!'),
       ('A0026', 'Bad credentials!'),
       ('A0027', 'Project does not exist!'),
       ('A0028', 'Thread does not exist!'),
       ('A0029', 'Comment does not exist!'),
       ('A0030', 'Comment needs content!'),
       ('A0031', 'Bad tag!'),
       ('A0032', 'Tag name can not be empty!'),
       ('A0033', 'Bad year value!');

--Reports

INSERT INTO report_type (name)
VALUES ('Project'),
       ('Thread'),
       ('Project_comment'),
       ('Thread_comment');

INSERT INTO report_subject (name)
VALUES ('Verbal abuse'),
       ('Threat'),
       ('Content'),
       ('New tag');

--User info

INSERT INTO genders (name)
VALUES ('male'),
       ('female'),
       ('other');

--Authorization

INSERT INTO roles (name)
VALUES ('user'),
       ('admin'),
       ('moderator');