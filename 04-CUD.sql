--------------------
-- DML : 데이터 조작어
--------------------
-- author : 테이블에 데이터 입력
-- INSERT
DESC author;

-- 묵시적 방법: 데이터를 넣을 걸럼을 지정하지 않은 경우
-- 정의된 순서에 따라서 값을 입력
INSERT INTO author
VALUES(1, '두루미', '와 여우');

-- 명시적 방법
-- 데이터를 넣을 컬럼을 지정, 지정한 컬럼 순서대로 데이터를 제공하고 명시되지 않은 컬럼은 NULL로 입력된다 -> NOT NULL 제약조건일 경우 오류가 난다
INSERT INTO author (author_id, author_name) -- 입력 컬럼 제공
VALUES(2, '거북이');

SELECT * FROM author;

-- CMD에서 sqlplus

-- INSERT, UPDATE, DELETE 작업을 수행하면 Transaction을 수행
-- 작업이 완료되었을때
-- 원래대로 복원 : ROLLBACK
-- 영구저장 : COMMIT
COMMIT;

-- ROOK 테이블 데이터 입력
SELECT * FROM book;
INSERT INTO book
VALUES(1, '토끼', sysdate, 1);

INSERT INTO book
VALUES(2, '의 간을 가져간 거북이', sysdate, 2);
SELECT * FROM book;

INSERT INTO book
VALUES(3, '용왕이 범인', sysdate, 3);    -- author_id 는 author.author_id를 FK참조하고 있으므로
-- 제약 조건 위반

-- 트랜잭션 이전으로 복구하고 싶다면
ROLLBACK
SELECT * FROM book;

-- UPDATE table SET 컬럼명 = 값, 컬럼명 = 값;
UPDATE author SET author_desc = '토끼와 거북이 뒤에 용왕';
SELECT * FROM author;

-- UPDATE시 조건을 부여하지 않으면 모든 레코드 변경 -> 주의
ROLLBACK;
SELECT * FROM author;

UPDATE author SET author_desc = '토끼와 거북이 뒤에 용왕있어요'
WHERE author_id = '2';
SELECT * FROM author;

-- 임시 테이블 생성
-- hr.employees 테이블로 부터 department_id가 10, 20, 30인 사람들만 뽑아서
-- 새 테이블 생성
CREATE TABLE emp_123 AS
    (SELECT * FROM hr.employees
        WHERE department_id IN (10, 20, 30));
DESC emp_123;

-- 연습 : 부서가 30인 직원들의 급여를 10% 인상해 봅시다.
SELECT * FROM emp_123 WHERE department_id = 30;
UPDATE emp_123
SET salary = salary + salary * 0.1
WHERE department_id = 30;

COMMIT;


-- DELETE FROM 테이블명 WHERE 삭제조건
SELECT  * FROM emp_123;
-- job_id가 mk로 시작하는 직원을 삭제
DELETE FROM emp_123
WHERE job_id LIKE 'MK_%';
SELECT * FROM emp_123;

-- WHERE 절이 없는 DELETE는 모든 레코드를 삭제
DELETE FROM emp_123;
SELECT * FROM emp_123;

-- DELETE는 Transaction의 대상 -> ROLLBACK 가능
ROLLBACK;
SELECT * FROM emp_123;

-- TRUNCATE : 테이블 비우기
TRUNCATE emp_123;
-- 주의 : TRUNCATE는 TRANSCATION의 대상이 아니다 -> ROLLBACK 불가능
ROLLBACK;
SELECT * FROM emp_123;