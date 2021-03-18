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
GRANT create session TO C##KSMIN;   -- C##NAMSK

--

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
-- HR 계정의 employees 테이블의 조회 권한을 C##NAMSK에게 부여하고 싶다면
GRANT SELECT ON hr.employees TO C##KSMIN;

-- C##KSMIN로 진행
SHOW USER;
SELECT * FROM hr.employees; --  hr.employees의 select권한을 부여받았으므로 테이블 조회가 가능해진다
