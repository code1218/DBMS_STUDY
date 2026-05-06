CREATE TABLE order_details_raw (
    order_id          INT,
    customer_id       INT,
    customer_name     VARCHAR(50),
    restaurant_id     INT,
    restaurant_name   VARCHAR(100),
    restaurant_category VARCHAR(50),
    menu_name         VARCHAR(100),
    quantity          INT
) COMMENT '비정규형 — 삽입/갱신/삭제 이상 현상 학습용';
 
INSERT INTO order_details_raw VALUES
(1, 1, '김민준', 1, '부산치킨',   '치킨', '후라이드',  2),
(2, 1, '김민준', 2, '해운대짜장', '중식', '짜장면',    1),
(3, 2, '이수진', 1, '부산치킨',   '치킨', '양념치킨',  1),
(4, 3, '박지호', 3, '광안리버거', '버거', '불고기버거', 1),
(5, 2, '이수진', 3, '광안리버거', '버거', '치즈버거',  2),
(6, 4, '최유나', 2, '해운대짜장', '중식', '탕수육',    1);
