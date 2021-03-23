SELECT * FROM user_objects; -- 현재 오브젝트

DROP TABLE PHONE_BOOK;  -- 필요시 삭제 후 재생성

-- TABLE
CREATE TABLE PHONE_BOOK (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(10),
    hp VARCHAR2(20),
    tel VARCHAR2(20)
);

-- SEQUENCE
CREATE SEQUENCE seq_phone_book
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 1000000;
    
-- 넣어보기
INSERT INTO phone_book
VALUES(seq_phone_book.NEXTVAL,
    '박경리', '010-0000-0000', '02-000-0000');
SELECT * FROM phone_book;   -- 결과확인하기



COMMIT;