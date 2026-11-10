-- @this-chapter-only  정규화 실습용 '엑셀 주문장' (Ch09 전용)
-- 한입배달 초창기, 정산팀이 DB 없이 엑셀 한 장으로 주문을 관리하던 시절의 모양을 재현합니다.
-- 6월 배달완료 주문으로 채웁니다. 정규형별 실습용 시트(rider_assign, ex_*)도 함께 만듭니다.

-- ① 한 주문 = 한 행, 메뉴는 한 칸에 몰아 쓰기 (1NF 위반)
CREATE TABLE order_sheet (
    order_id         INT           NOT NULL  COMMENT '주문 번호',
    ordered_at       DATETIME      NOT NULL  COMMENT '주문 일시',
    customer_name    VARCHAR(20)   NOT NULL  COMMENT '고객 이름',
    customer_phone   CHAR(13)      NOT NULL  COMMENT '고객 전화',
    customer_grade   VARCHAR(10)   NOT NULL  COMMENT '고객 등급',
    restaurant_name  VARCHAR(50)   NOT NULL  COMMENT '가게 이름',
    restaurant_phone VARCHAR(13)       NULL  COMMENT '가게 전화',
    menu_list        VARCHAR(300)  NOT NULL  COMMENT '메뉴 (이름 수량, …)',
    delivery_fee     INT           NOT NULL  COMMENT '배달팁',
    CONSTRAINT pk_order_sheet PRIMARY KEY (order_id)
) COMMENT '엑셀 주문장 — 비정규형';

INSERT INTO order_sheet
SELECT o.order_id, o.ordered_at, c.name, c.phone, c.grade, r.name, r.phone,
    GROUP_CONCAT(CONCAT(m.name, ' ', oi.quantity) ORDER BY oi.menu_id SEPARATOR ', '),
    o.delivery_fee
FROM orders o
JOIN customers   c  ON o.customer_id   = c.customer_id
JOIN restaurants r  ON o.restaurant_id = r.restaurant_id
JOIN order_items oi ON o.order_id      = oi.order_id
JOIN menus       m  ON oi.menu_id      = m.menu_id
WHERE o.status = '배달완료' AND o.ordered_at >= '2026-06-01'
GROUP BY o.order_id;

-- ② 메뉴 한 줄 = 한 행 (1NF는 만족, 2NF 위반)
CREATE TABLE order_flat (
    order_id         INT           NOT NULL  COMMENT '주문 번호',
    menu_name        VARCHAR(50)   NOT NULL  COMMENT '메뉴 이름',
    ordered_at       DATETIME      NOT NULL  COMMENT '주문 일시',
    customer_name    VARCHAR(20)   NOT NULL  COMMENT '고객 이름',
    customer_phone   CHAR(13)      NOT NULL  COMMENT '고객 전화',
    customer_grade   VARCHAR(10)   NOT NULL  COMMENT '고객 등급',
    restaurant_name  VARCHAR(50)   NOT NULL  COMMENT '가게 이름',
    restaurant_phone VARCHAR(13)       NULL  COMMENT '가게 전화',
    quantity         INT           NOT NULL  COMMENT '수량',
    unit_price       INT           NOT NULL  COMMENT '단가',
    delivery_fee     INT           NOT NULL  COMMENT '배달팁',
    CONSTRAINT pk_order_flat PRIMARY KEY (order_id, menu_name)
) COMMENT '엑셀 주문장 — 메뉴별 행';

INSERT INTO order_flat
SELECT o.order_id, m.name, o.ordered_at, c.name, c.phone, c.grade, r.name, r.phone,
    oi.quantity, oi.unit_price, o.delivery_fee
FROM orders o
JOIN customers   c  ON o.customer_id   = c.customer_id
JOIN restaurants r  ON o.restaurant_id = r.restaurant_id
JOIN order_items oi ON o.order_id      = oi.order_id
JOIN menus       m  ON oi.menu_id      = m.menu_id
WHERE o.status = '배달완료' AND o.ordered_at >= '2026-06-01';

-- ③ 초창기 전속 기사 배정표 (3NF는 만족, BCNF 위반) — 수업 5-6절
--    규칙: 기사는 한 가게에만 속한다 / 고객은 가게마다 담당 기사가 한 명이다
CREATE TABLE rider_assign (
    customer_name    VARCHAR(20)  NOT NULL  COMMENT '고객 이름',
    restaurant_name  VARCHAR(50)  NOT NULL  COMMENT '가게 이름',
    rider_name       VARCHAR(20)  NOT NULL  COMMENT '담당 기사',
    CONSTRAINT pk_rider_assign PRIMARY KEY (customer_name, restaurant_name)
) COMMENT '전속 기사 배정표 — BCNF 위반';

INSERT INTO rider_assign VALUES
    ('김민준', '서면옛날돼지국밥', '배성진'), ('이서연', '서면옛날돼지국밥', '배성진'),
    ('박지훈', '서면옛날돼지국밥', '노지환'), ('최수아', '서면옛날돼지국밥', '노지환'),
    ('김민준', '전포카츠',         '하민호'), ('이서연', '전포카츠',         '하민호'),
    ('정우진', '전포카츠',         '하민호'),
    ('김민준', '해운대명가밀면',   '전유나'), ('정우진', '해운대명가밀면',   '전유나'),
    ('박지훈', '해운대명가밀면',   '곽태호');

-- ====================================================================
-- 실습용 시트 (practice.md) — 이름이 ex_ 로 시작. 정규화한 결과는 p_ 로 만듭니다.
-- ====================================================================

-- 실습 1: 기사 담당 구역 (한 칸에 구역 여러 개)
CREATE TABLE ex_rider_sheet (
    rider_name  VARCHAR(20)   NOT NULL  COMMENT '기사 이름',
    phone       CHAR(13)      NOT NULL  COMMENT '전화',
    zones       VARCHAR(100)  NOT NULL  COMMENT '담당 구역 (쉼표로 구분)',
    CONSTRAINT pk_ex_rider_sheet PRIMARY KEY (rider_name)
) COMMENT '실습 1 — 기사 담당 구역';

INSERT INTO ex_rider_sheet VALUES
    ('배성진', '010-3101-2201', '서면, 전포, 범천'),
    ('노지환', '010-3102-2202', '서면, 부전'),
    ('하민호', '010-3103-2203', '전포, 문현, 범천, 부암'),
    ('전유나', '010-3104-2204', '해운대, 우동, 중동'),
    ('곽태호', '010-3105-2205', '해운대, 송정'),
    ('민경수', '010-3106-2206', '광안, 남천, 대연, 수영, 민락'),
    ('엄소희', '010-3107-2207', '대연, 용호'),
    ('천동현', '010-3108-2208', '동래, 온천, 사직');

-- 실습 2: 구 앱 리뷰 (사진을 photo1~3 열로)
CREATE TABLE ex_review_sheet (
    review_id      INT           NOT NULL  COMMENT '리뷰 번호',
    customer_name  VARCHAR(20)   NOT NULL  COMMENT '작성자',
    rating         TINYINT       NOT NULL  COMMENT '별점',
    photo1         VARCHAR(100)      NULL  COMMENT '사진 1',
    photo2         VARCHAR(100)      NULL  COMMENT '사진 2',
    photo3         VARCHAR(100)      NULL  COMMENT '사진 3',
    CONSTRAINT pk_ex_review_sheet PRIMARY KEY (review_id)
) COMMENT '실습 2 — 사진 반복 열';

INSERT INTO ex_review_sheet VALUES
    (801, '김민준', 5, 'r801_a.jpg', 'r801_b.jpg', 'r801_c.jpg'),
    (802, '이서연', 4, 'r802_a.jpg', NULL,         NULL),
    (803, '박지훈', 3, NULL,         NULL,         NULL),
    (804, '최수아', 5, 'r804_a.jpg', 'r804_b.jpg', NULL),
    (805, '정우진', 2, NULL,         'r805_b.jpg', NULL),
    (806, '강하은', 5, 'r806_a.jpg', 'r806_b.jpg', 'r806_c.jpg'),
    (807, '조현우', 4, NULL,         NULL,         NULL),
    (808, '윤지아', 1, 'r808_a.jpg', NULL,         'r808_c.jpg');

-- 실습 3~5: 쿠폰 사용 장부 (한 고객은 같은 쿠폰을 한 번만 쓴다)
CREATE TABLE ex_coupon_sheet (
    coupon_code      VARCHAR(10)  NOT NULL  COMMENT '쿠폰 코드',
    coupon_name      VARCHAR(30)  NOT NULL  COMMENT '쿠폰 이름',
    discount_amount  INT          NOT NULL  COMMENT '할인액',
    customer_phone   CHAR(13)     NOT NULL  COMMENT '고객 전화',
    customer_name    VARCHAR(20)  NOT NULL  COMMENT '고객 이름',
    used_at          DATETIME     NOT NULL  COMMENT '사용 일시'
) COMMENT '실습 3~5 — 쿠폰 사용 장부 (PK 없음)';

INSERT INTO ex_coupon_sheet VALUES
    ('HELLO3K', '첫 주문 할인', 3000,  '010-9936-4407', '윤지아', '2026-03-02 12:10:00'),
    ('HELLO3K', '첫 주문 할인', 3000,  '010-3158-2276', '한예린', '2026-03-05 18:40:00'),
    ('HELLO5K', '첫 주문 할인', 5000,  '010-4269-5534', '오승민', '2026-04-01 19:05:00'),
    ('HELLO5K', '첫 주문 할인', 5000,  '010-5527-3018', '최수아', '2026-04-03 12:30:00'),
    ('RAINY2K', '비 오는 날',   2000,  '010-2841-5523', '김민준', '2026-05-12 18:20:00'),
    ('RAINY2K', '비 오는 날',   2000,  '010-3392-1187', '이서연', '2026-05-12 19:02:00'),
    ('RAINY2K', '비 오는 날',   2000,  '010-5527-3018', '최수아', '2026-05-12 20:15:00'),
    ('RAINY2K', '비 오는 날',   2000,  '010-8825-6631', '조현우', '2026-06-18 12:45:00'),
    ('NIGHT4K', '야식 응원',    4000,  '010-2841-5523', '김민준', '2026-06-02 23:10:00'),
    ('NIGHT4K', '야식 응원',    4000,  '010-6631-9045', '정우진', '2026-06-05 22:40:00'),
    ('NIGHT4K', '야식 응원',    4000,  '010-7714-2290', '강하은', '2026-06-05 23:55:00'),
    ('NIGHT4K', '야식 응원',    4000,  '010-8825-6631', '조현우', '2026-06-10 00:20:00'),
    ('VIP10K',  'VIP 감사',     10000, '010-2841-5523', '김민준', '2026-06-20 18:00:00'),
    ('VIP10K',  'VIP 감사',     10000, '010-3392-1187', '이서연', '2026-06-21 19:30:00'),
    ('VIP10K',  'VIP 감사',     10000, '010-4410-7762', '박지훈', '2026-06-22 12:00:00');

-- 실습 6~7: 메뉴판 관리 시트 (메뉴 → 가게 → 분류로 이어지는 종속)
CREATE TABLE ex_menu_sheet (
    menu_code        CHAR(4)      NOT NULL  COMMENT '메뉴 코드',
    menu_name        VARCHAR(50)  NOT NULL  COMMENT '메뉴 이름',
    price            INT          NOT NULL  COMMENT '가격',
    restaurant_code  CHAR(3)      NOT NULL  COMMENT '가게 코드',
    restaurant_name  VARCHAR(50)  NOT NULL  COMMENT '가게 이름',
    owner_name       VARCHAR(20)  NOT NULL  COMMENT '사장님',
    category_code    CHAR(3)      NOT NULL  COMMENT '분류 코드',
    category_name    VARCHAR(20)  NOT NULL  COMMENT '분류 이름',
    CONSTRAINT pk_ex_menu_sheet PRIMARY KEY (menu_code)
) COMMENT '실습 6~7 — 메뉴판 관리 시트';

INSERT INTO ex_menu_sheet VALUES
    ('M001', '돼지국밥',      9000,  'R01', '서면옛날돼지국밥', '박영숙', 'C01', '한식'),
    ('M002', '순대국밥',      9000,  'R01', '서면옛날돼지국밥', '박영숙', 'C01', '한식'),
    ('M003', '수육 백반',     12000, 'R01', '서면옛날돼지국밥', '박영숙', 'C01', '한식'),
    ('M004', '로스카츠',      11000, 'R02', '전포카츠',         '이정훈', 'C02', '일식'),
    ('M005', '히레카츠',      12000, 'R02', '전포카츠',         '이정훈', 'C02', '일식'),
    ('M006', '카레 우동',     8000,  'R02', '전포카츠',         '이정훈', 'C02', '일식'),
    ('M007', '물밀면',        9000,  'R03', '해운대명가밀면',   '최말순', 'C01', '한식'),
    ('M008', '비빔밀면',      9500,  'R03', '해운대명가밀면',   '최말순', 'C01', '한식'),
    ('M009', '왕만두 (6개)',  6000,  'R03', '해운대명가밀면',   '최말순', 'C01', '한식'),
    ('M010', '마르게리타',    16000, 'R04', '광안리화덕피자',   '정다은', 'C03', '피자');

-- 실습 8~9: 위생 · 원산지 · 소방 점검 배정표
--    규칙: 가게마다 점검 종류별 담당 점검원은 한 명 / 점검원은 한 종류만 맡는다
CREATE TABLE ex_inspection_sheet (
    restaurant_name  VARCHAR(50)  NOT NULL  COMMENT '가게 이름',
    inspection_type  VARCHAR(10)  NOT NULL  COMMENT '점검 종류',
    inspector_name   VARCHAR(20)  NOT NULL  COMMENT '담당 점검원',
    CONSTRAINT pk_ex_inspection_sheet PRIMARY KEY (restaurant_name, inspection_type)
) COMMENT '실습 8~9 — 점검 배정표';

INSERT INTO ex_inspection_sheet VALUES
    ('서면옛날돼지국밥', '위생',   '송미라'), ('서면옛날돼지국밥', '원산지', '백승호'),
    ('서면옛날돼지국밥', '소방',   '유정민'),
    ('전포카츠',         '위생',   '송미라'), ('전포카츠',         '원산지', '백승호'),
    ('해운대명가밀면',   '위생',   '문재석'), ('해운대명가밀면',   '원산지', '백승호'),
    ('해운대명가밀면',   '소방',   '남궁현'),
    ('광안리화덕피자',   '위생',   '문재석'), ('광안리화덕피자',   '소방',   '유정민'),
    ('대연동크런치치킨', '위생',   '송미라'), ('대연동크런치치킨', '소방',   '남궁현'),
    ('동래파전골목집',   '원산지', '백승호');

-- 실습 11: 할인 이벤트 참여 시트 (종합)
CREATE TABLE ex_event_sheet (
    event_code       CHAR(3)       NOT NULL  COMMENT '이벤트 코드',
    event_name       VARCHAR(30)   NOT NULL  COMMENT '이벤트 이름',
    discount_rate    INT           NOT NULL  COMMENT '할인율(%)',
    restaurant_name  VARCHAR(50)   NOT NULL  COMMENT '가게 이름',
    restaurant_phone VARCHAR(13)   NOT NULL  COMMENT '가게 전화',
    joined_at        DATE          NOT NULL  COMMENT '참여 신청일',
    menu_list        VARCHAR(200)  NOT NULL  COMMENT '할인 메뉴 (쉼표로 구분)',
    CONSTRAINT pk_ex_event_sheet PRIMARY KEY (event_code, restaurant_name)
) COMMENT '실습 11 — 이벤트 참여 시트';

INSERT INTO ex_event_sheet VALUES
    ('E01', '여름 밀면 페스타',   10, '해운대명가밀면',   '051-742-5508', '2026-06-01', '물밀면, 비빔밀면'),
    ('E01', '여름 밀면 페스타',   10, '서면옛날돼지국밥', '051-805-1124', '2026-06-02', '돼지국밥'),
    ('E02', '야식 대전',          15, '대연동크런치치킨', '051-626-9981', '2026-06-03', '후라이드 치킨, 양념 치킨, 치즈볼 (5개)'),
    ('E02', '야식 대전',          15, '서면야식치킨',     '051-809-4477', '2026-06-03', '반반 치킨, 순살 간장 치킨'),
    ('E02', '야식 대전',          15, '연산동짬뽕반점',   '051-866-4420', '2026-06-05', '짬뽕, 탕수육 (소)'),
    ('E03', '비 오는 날 전 데이', 20, '동래파전골목집',   '051-552-7713', '2026-06-10', '해물파전, 동래 막걸리 750ml'),
    ('E03', '비 오는 날 전 데이', 20, '서면옛날돼지국밥', '051-805-1124', '2026-06-11', '수육 (중)');

SELECT 'order_sheet' AS table_name, COUNT(*) AS row_count FROM order_sheet
UNION ALL SELECT 'order_flat', COUNT(*) FROM order_flat
UNION ALL SELECT 'rider_assign', COUNT(*) FROM rider_assign
UNION ALL SELECT 'ex_rider_sheet', COUNT(*) FROM ex_rider_sheet
UNION ALL SELECT 'ex_review_sheet', COUNT(*) FROM ex_review_sheet
UNION ALL SELECT 'ex_coupon_sheet', COUNT(*) FROM ex_coupon_sheet
UNION ALL SELECT 'ex_menu_sheet', COUNT(*) FROM ex_menu_sheet
UNION ALL SELECT 'ex_inspection_sheet', COUNT(*) FROM ex_inspection_sheet
UNION ALL SELECT 'ex_event_sheet', COUNT(*) FROM ex_event_sheet;
