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