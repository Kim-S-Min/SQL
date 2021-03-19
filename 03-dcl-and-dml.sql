/*
사용자 생성
    CREATE USER C##KSMIN IDENTIFIED BY 1234;
    - ORACLE : 사용자 생성 -> 동일 이름의 SCHEMA도 같이 생성
사용자 삭제
    DROP USER C##KSMIN
    DROP USER C##KSMIN CASCADE - 
*/

-- system으로 진행
-- 사용자 정보 확인
-- USER_USERS : 현재 사용자 관련 정보
-- ALL_USERS : DB의 모든 사용자 정보
-- DBA_USERS : 모든 사용자의 상세 정보(DBA Only)


-- 현재 사용자 확인
SELECT * FROM USER_USERS;

-- 전체 사용자 확인
SELECT * FROM ALL_USERS;

-- 로그인 권한 부여
CREATE USER C##KSMIN IDENTIFIED BY 1234;   --  로그인 할 수 없는 상태
-- 적절한 권한을 부여해야 한다
GRANT create session TO C##KSMIN;   -- C##NAMSK

--일반 데이터베이스로 권한을 부여할 수 있다

/*
로그인 해서 다음의 쿼리를 수행해 봅니다.
- CREATE TABLE test(a NUMBER); -- 권한 불충분
- SELECT * FROM tab;
- DESC test;
- INSERT INTO test VALUES(10);
    -- 테이블 스페이스 'USERS'에 대한 권한이 없습니다
*/

/*
보충설명
Oracle 12이후
    - 일반 계정을 구분하기 위해 C## 접두어로 고쳐줘야 한다
    - 실제 데이터가 저장될 테이블 스페이스를 마련해 줘야 한다 - USERS 테이블 스페이스에 공간을 마련
*/


-- C## 없이 계정을 생성하는 방법
ALTER SESSION SET "ORACLE_SCRIPT" = true;
CREATE USER KSMIN IDENTIFIED BY 1234;
-- 사용자 데이터 저장 테이블 스페이스 부여
ALTER USER C##KSMIN DEFAULT TABLESPACE USERS    -- C##NAMSK 사용자의 저장 공간을 USERS에 마련
    QUOTA unlimited on USERS;   -- 저장 공간한도를 무한으로 부여 (언리미트를 지정해주면 지정된 공간을 사용할수 있다)
    
GRANT connect, resource TO C##KSMIN;

-- ROLE의 생성
DROP ROLE dbuser;
CREATE ROLE dbuser; -- dbuser역확을 만들어 여러개의 권한을 담아둔다
GRANT create session To dbuser;   -- dbuser 역활에 접속할 수 있는 권한을 부여
GRANT resource TO dbuser;   -- dbuser역활에 자원 생성 권한을 부여

-- ROLE을 GRANT하면 내부에 있는 개별 Privilege(권한)이 모두 부여
GRANT dbuser To namsk;  --  namsk 사용자에게 dbuser 역활을 부여한다 

-- 권한의 회수 REVOKE
REVOKE dbuser FROM namsk;   --namsk 사용자로부터 dbuser 역활을 회수한다

-- 계정 삭제
DROP USER namsk CASCADE;

-- 현재 사용자에게 부여된 ROLE 확인
-- 사용자 계정으로 로그인
show user;
SELECT * FROM user_role_privs;


-- CONNECT 역활에는 어떤 권한이 포함되어 있는가?
DESC role_sys_privs;
SELECT * FROM role_sys_privs WHERE role = 'CONNECT';    -- CONNECT롤이 포함하고 있는 권한
SELECT * FROM role_sys_privs WHERE role = 'RESOURCE';

SHOW user;
-- System 계정으로 진행
-- HR 계정의 employees 테이블의 조회 권한을 C##KSMIN에게 부여하고 싶다면
GRANT SELECT ON hr.employees TO C##KSMIN;   -- 권한부여
REVOKE SELECT ON hr.employees FROM C##KSMIN;    -- 권한회수
-- C##KSMIN로 진행
SHOW USER;
SELECT * FROM hr.employees; --  hr.employees의 select권한을 부여받았으므로 테이블 조회가 가능해진다


--------
-- DDL
--------

-- 내가 가진 table 확인
SELECT * FROM tab;
-- 테이블의 구조 확인
DESC test;

-- 테이블 삭제
DROP TABLE book;
SELECT * FROM tab;

-- 휴지통
PURGE RECYCLEBIN;

SELECT * FROM tab;

-- CREATE TABLE
CREATE TABLE book ( --컬럼 명시
    book_id NUMBER(5),  -- 5자리 숫자
    title VARCHAR2(50), -- 50글자 가변문자
    author VARCHAR2(10),    -- 10글자 가변문자열
    pub_date DATE DEFAULT SYSDATE   -- 기본값은 현재시간
);
DESC book;

-- 서브쿼리를 활용한 테이블 생성
-- hr.employees 테이블을 기반으로 일부 데이터를 추출
-- 새 테이블
SELECT * FROM hr.employees WHERE job_id like 'IT_%';
    CREATE TABLE it_emps AS (
        SELECT * FROM hr.employees WHERE job_id like 'IT_%'
);

SELECT * FROM it_emps;
CREATE TABLE emp_summary AS (
    SELECT employee_id,
        first_name || ' ' || last_name full_name,
        hire_date, salary
    FROM hr.employees
);
DESc emp_summary;
SELECT * FROM emp_summary;
    
    
-- author 테이블 
DESC book;
CREATE TABLE author (
    author_id NUMBER(10),
    author_name VARCHAR2(100) NOT NULL, -- NULL일 수 없다
    author_desc VARCHAR2(500),
    PRIMARY KEY (author_id) -- author_id 컬럼을 pk로
);
DESC author;

-- book 테이블에 author테이블 연결을 위해
-- book테이블의 author 컬럼을 삭제: DROP COLUMN
ALTER TABLE book
DROP COLUMN author;
DESC book;

-- author 테이블 참조를 위한 author_id컬럼을 book에 추가
ALTER TABLE book
ADD (author_id NUMBER(10));
DESC book;

-- book 테이블의 PK로 사용할 book_id도 NUMBER(10)으로 변경
ALTER TABLE book
MODIFY (book_id NUMBER(10));
DESC book;

-- 제약조건의 추가 : ADD CONSTRAINT
-- book 테이블의 book_id를 PRIMARY KEY 제약조건 부여
ALTER TABLE book
ADD CONSTRAINT pk_book_id PRIMARY KEY(book_id);
DESC book;

-- FOREIGN KEY 추가
-- book 테이블의 author_id 가 author의 author_id를 참조
ALTER TABLE book
ADD CONSTRAINT
    fk_author_id FOREIGN KEY (author_id)
        REFERENCES author(author_id);
DESC book;

-- COMMENT
COMMENT ON TABLE book IS 'Book Information';
COMMENT ON TABLE author IS 'Author Information';

-- 체이블 커멘트 확인
SELECT * FROM user_tab_comments;
SELECT comments FROM user_tab_comments
WHERE table_name = 'Book';

-- Date Dictionary
-- Oracle은 내부에서 발생하는 모든 정보를 Data Dictionary에 담아두고 있다
-- 계정별로 USER_(일반사용자), ALL_(전체 사용자), DBA_(관리자 전용) 접근범위를 제한한다
-- 모든 딕셔너리 확인
SHOW user;
SELECT * FROM dictionary;
SELECT COUNT(*) FROM dictionary;

-- DBA_Dictionary 확인
-- DBA로 로그인 필요 as sysdba

-- 사용자 DB객체 dictionary USER_OBJECTS
SELECT * FROM user_objects;
SELECT object_name, object_type FROM user_objects;
SELECT * FROM user_objects WHERE OBJECT_NAME = 'Book';


-- 제약조건확인 dictionary USER_CONSTRAINTS
SELECT * FROM user_constraints;
-- 제약조건이 걸린 컬럼 확인
SELECT * FROM user_cons_columns;