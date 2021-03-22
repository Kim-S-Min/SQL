--------------------
-- DB 객체
--------------------

-- VIEW : 한개 혹은 복수 개의 테이블을 기반으로 사용한다 ,실제 데이터는갖고 있지 않다
-- VIEW생성을 위해서는 CREATE VIEW 권한이 필요하다
-- SYSTEM으로 로그인
GRANT CREATE VIEW TO C##KSMIN;


-- simple VIEW
-- 단일 테이블 혹은 뷰를 기반으로 생성
-- 제약조건 위반이 없다면 INSERT, UPDATE, DELETE 가능
-- employees 테이블로 부터 department_id가 10인 사람들만 VIEW로 생성
CREATE TABLE emp_10
    AS SELECT employee_id, first_name, last_name, salary
        FROM hr.employees;
        
SELECT * FROM emp_10;
        
CREATE OR REPLACE VIEW view_emp_10
    AS SELECT * FROM emp_10;
    
DESC view_emp_10;
-- view는 테이블 처럼 조회할 수 있다
-- 실제 데이터는 기반 테이블에서 가지고 온다
SELECT * FROM view_emp_10;

-- SIMPLE VIEW는 제약 사항에 위배되지 않으면 내용 갱신 가능
-- view_emp_10의 급여를 두배로
UPDATE emp_10 SET salary = salary * 2;

-- 가급적이면 view조회용으로만 활용하도록 하자
-- view 생성시 변경 불가 객체로 만들 필요가 없다
-- READ ONLY 옵션을 부여
CREATE OR REPLACE VIEW view_emp_10
    AS SELECT * FROM emp_10 WITH READ ONLY;

UPDATE view_emp_10 SET salary = salary * 2;
-- 읽기 전용 뷰에서는 DML작업을 수행할 수 없습니다.

-- ComplexView
-- 복수개의 Table or View를 기반으로 한다
-- 함수,표현식을 포함할 수 있다
-- 기본적으로 INSERT,UPDATE, DELETE 불가
-- book테이블 JOIN author -> VIEW
SELECT * FROM author;
SELECT * FROM book;

INSERT INTO book
VALUES(1, '토끼', sysdate, 1);

INSERT INTO book (book_id, title, author_id)
VALUES(2, '를 잡은 거북이', 2);

SELECT * FROM book;
COMMIT;

CREATE OR REPLACE VIEW book_detail
    (book_id, title, author_name, pub_date)
    AS SELECT book_id, title, author_name, pub_date
        FROM book b, author a
        WHERE b.author_id = a.author_id;
    
DESC book_detail;

SELECT * FROM book_detail;

UPDATE book_detail SET author_name = '미상';  -- 복합 VIEW는 수정이 불가능하다(기본적으로)


------------------------
-- VIEW를 위한 딕셔너리
----------------------
SELECT * FROM user_views;
-- 특정 VIEW정보를 확인하려면 VIEW_NAME을 조건으로 조회하면 된다
SELECT * FROM user_views
WHERE view_name = 'BOOK_DETAIL';

SELECT * FROM user_objects
WHERE object_type = 'VIEW';

-- view 삭제
-- 실제 데이터는 VIEW가 아닌 기반 테이블에 위치
DROP VIEW book_detail;
SELECT * FROM user_views;


-- VIEW 삭제해도 데이터는 유지가 된다
SELECT * FROM book;
SELECt * FROM author;

---------------
-- INDEX
---------------

-- 레코드 검색 속도 향상을 위한 색인 작업
-- WHERE 절의 조건에서 사용되는 필드
-- JOIN의 조건으로 사용되는 필드에 적용하면
-- 검색 속도 향상 가능(꼭 필요한 필드에만 적용하자)

CREATE TABLE s_emp
    AS SELECT * FROM hr.employees;
    
-- 인덱스 확인
SELECT * FROM user_indexes;

-- s_emp테이블 employee_id컬럼에 UNIQUE인덱스 생성해봅시다
CREATE UNIQUE INDEX s_emp_id_pk -- 인덱스 이름
    ON s_emp(employee_id);
    
SELECT * FROM user_indexes;

-- 어떤 인덱스가 어느 컬럼에 걸려있는지 확인
SELECT * FROM user_ind_columns;

SELECT t.index_name, t.table_name, c.column_name, c.column_position
FROM user_indexes t, user_ind_columns c
WHERE t.index_name = c.index_name;

SELECT t.index_name, t.table_name, c.column_name, c.column_position
FROM user_indexes t, user_ind_columns c
WHERE t.index_name = c.index_name AND
    t.table_name = 'S_EMP';
    
-- 인덱스 삭제
DROP INDEX s_emp_id_pk;
SELECT * FROM user_indexes;

--------------
-- SEQUENCE
--------------

-- 만약 author 테이블에 새 레코드를 추가해야 한다
SELECT * FROM author;

-- 중복되지 않는 pk를 얻어와야 한다
INSERT INTO author(author_id, author_name)
    VALUES(
        (SELECT MAX(author_id) + 1 FROM author), '스티븐 킹');
        
SELECT * FROM author;

-- 이 방식은 안전하지 않다
--
ROLLBACK;

SELECT MAAX(author_id)

-- 시퀀스 생성
CREATE SEQUENCE seq_author_id
    START WITH 3
    INCREMENT BY 1
    MAXVALUE 100000;
    
-- 시퀀스를 이용한 INSERT(PK)
INSERT INTO author(author_id, author_name)
VALUES(seq_author.NEXTVAL,
    '스티븐 킹');
    
SELECT * FROM author;

-- 새 시퀀스를 생성해 봅시다
CREATE SEQUENCE my_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 10;
    
-- NEXTVAL, CURRVAL 가상 컬럼을 이용
SELECT my_seq.NEXTVAL FROM dual;    -- 새 값의 추출(증가)
SELECT my_seq.CURRVAL FROM dual;    -- 현재 시퀀스의 값 확인(증가안함)

-- 시퀀스 수정하기
ALTER SEQUENCE my_seq
    INCREMENT BY 2  -- 증가값을 2로 변경
    MAXVALUE 1000000;
    
SELECT my_seq.NEXTVAL FROM dual;    -- 2증가
SELECT my_seq.NEXTVAL FROM dual;    -- 2증가

-- 시퀀스를 위한 딕셔너리
SELECT * FROM user_sequences;
SELECT object_name FROM user_objects
WHERE object_type = 'SEQUENCE';

-- 시퀀스 삭제
DROP SEQUENCE my_seq;
SELECT * FROM user_sequences;