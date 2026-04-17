-- ============================================================
-- Day 3: CRUD (데이터 넣고 꺼내기)
-- 과정: MySQL 10일 완성 — 한입배달 DB
-- 작성일: 2026-04-17
-- ============================================================
-- 이 파일은 강사와 함께 순서대로 실행합니다.
-- 각 PART를 블록 선택 후 Ctrl+Shift+Enter (또는 번개 아이콘)로 실행하세요.
-- ============================================================


-- ============================================================
-- PART 1 — 준비: 이전 데이터 확인
-- ============================================================

USE hanip_delivery;

-- Day 2에서 만든 테이블과 데이터를 확인합니다.
SELECT * FROM restaurants;   -- 가게 10건
SELECT * FROM customers;     -- 고객 10건
SELECT * FROM menus;         -- 메뉴 30건 (가게당 3개)


-- ============================================================
-- PART 2 — INSERT: 데이터 입고
-- ============================================================

-- ----------------------------------------------------------------
-- 2-1. 단건 INSERT (컬럼명 명시 버전) — 권장 방식
-- ----------------------------------------------------------------
-- 컬럼명을 직접 써주면 순서가 달라도 안전하고, 나중에 읽기도 쉽습니다.
INSERT INTO menus (restaurant_id, menu_name, price, description, is_available)
VALUES (1, '양념반후라이드반', 22000, '반반 황금 조합', TRUE);

-- ----------------------------------------------------------------
-- 2-2. 단건 INSERT (컬럼명 생략 버전) — 비교용
-- ----------------------------------------------------------------
-- 테이블 컬럼 순서를 정확히 알아야 합니다. 실수 위험이 높아서 비추천!
-- id는 AUTO_INCREMENT이므로 직접 넣지 않아도 됩니다.
-- (단, 컬럼 생략 시 AUTO_INCREMENT 컬럼도 포함해야 하므로 NULL 또는 0으로 자리 채움)
INSERT INTO menus
VALUES (NULL, 2, '불고기피자', 18000, '달콤한 불고기 소스', TRUE);

-- ----------------------------------------------------------------
-- 2-3. AUTO_INCREMENT 컬럼 생략하는 법 (핵심!)
-- ----------------------------------------------------------------
-- 컬럼명을 명시할 때 id를 아예 빼면 됩니다. DB가 자동으로 채워줍니다.
INSERT INTO menus (restaurant_id, menu_name, price)
VALUES (3, '떡볶이 세트', 8000);
-- description과 is_available은 DEFAULT 값이 적용됩니다.

-- ----------------------------------------------------------------
-- 2-4. 다건 INSERT — VALUES 여러 개 (권장: 한 번에 넣기)
-- ----------------------------------------------------------------
-- 한 번의 쿼리로 여러 행을 넣습니다. 반복 INSERT보다 성능이 훨씬 좋습니다.
INSERT INTO menus (restaurant_id, menu_name, price, description, is_available)
VALUES
    (4, '비빔냉면',    9000,  '쫄깃한 면발, 매콤한 소스',  TRUE),
    (5, '탕수육 (소)', 15000, NULL,                        TRUE),   -- 설명이 없는 메뉴 (NULL 의도적 삽입)
    (6, '김치찌개 정식', 8500, '된장찌개 선택 가능',        TRUE),
    (7, '마라탕 (소)',  12000, '마라 향이 진한 정통 마라탕', TRUE),
    (8, '순대국밥',     7000,  NULL,                        FALSE),  -- 일시품절 (is_available = FALSE)
    (9, '스파게티 세트', 13000, '샐러드 + 음료 포함',       TRUE);

-- 확인
SELECT * FROM menus ORDER BY id DESC LIMIT 10;


-- ============================================================
-- PART 3 — SELECT 기본 + WHERE (쿠팡 검색 필터)
-- ============================================================

-- ----------------------------------------------------------------
-- 3-1. SELECT * vs SELECT 컬럼 지정
-- ----------------------------------------------------------------
-- 전체 컬럼 조회 (개발/확인용)
SELECT * FROM restaurants;

-- 필요한 컬럼만 조회 (실무 권장 — 네트워크 낭비 없음)
SELECT name, category, rating FROM restaurants;

-- ----------------------------------------------------------------
-- 3-2. WHERE 비교 연산자: =, !=, >, <, >=, <=
-- ----------------------------------------------------------------
-- 카테고리가 '치킨'인 가게만
SELECT * FROM restaurants WHERE category = '치킨';

-- 치킨이 아닌 가게
SELECT * FROM restaurants WHERE category != '치킨';

-- 평점 4.0 초과
SELECT name, rating FROM restaurants WHERE rating > 4.0;

-- 평점 3.5 이하
SELECT name, rating FROM restaurants WHERE rating <= 3.5;

-- 가격이 10000원 미만인 메뉴
SELECT menu_name, price FROM menus WHERE price < 10000;

-- ----------------------------------------------------------------
-- 3-3. WHERE BETWEEN — 범위 조건
-- ----------------------------------------------------------------
-- 가격이 8000원 이상 15000원 이하인 메뉴
-- BETWEEN a AND b  ↔  >= a AND <= b (경계값 포함!)
SELECT menu_name, price FROM menus
WHERE price BETWEEN 8000 AND 15000;

-- ----------------------------------------------------------------
-- 3-4. WHERE IN — 목록 중 하나와 일치
-- ----------------------------------------------------------------
-- 카테고리가 치킨, 피자, 분식 중 하나인 가게
SELECT name, category FROM restaurants
WHERE category IN ('치킨', '피자', '분식');

-- IN의 반대: NOT IN
SELECT name, category FROM restaurants
WHERE category NOT IN ('치킨', '피자');

-- ----------------------------------------------------------------
-- 3-5. WHERE LIKE — 패턴 검색 (부분 일치)
-- ----------------------------------------------------------------
-- % : 0개 이상의 임의 문자
-- _ : 정확히 1개의 임의 문자

-- 메뉴명에 '김치'가 포함된 것 (앞뒤 어디든)
SELECT menu_name FROM menus WHERE menu_name LIKE '%김치%';

-- 고객 이름이 '김'으로 시작하는 사람
SELECT name FROM customers WHERE name LIKE '김%';

-- 주소가 '동'으로 끝나는 가게
SELECT name, address FROM restaurants WHERE address LIKE '%동';

-- 이름이 3글자이고 가운데 글자가 '순'인 고객 (예: 이순신, 박순이)
SELECT name FROM customers WHERE name LIKE '_순_';

-- ----------------------------------------------------------------
-- 3-6. WHERE IS NULL / IS NOT NULL
-- ----------------------------------------------------------------
-- description이 없는(NULL인) 메뉴
SELECT menu_name, description FROM menus WHERE description IS NULL;

-- description이 있는 메뉴
SELECT menu_name, description FROM menus WHERE description IS NOT NULL;

-- ※ NULL은 = 로 비교하면 안 됩니다! (항상 IS NULL / IS NOT NULL 사용)
-- 잘못된 예: WHERE description = NULL  → 결과 없음 (동작 안 함)

-- ----------------------------------------------------------------
-- 3-7. AND / OR / NOT 복합 조건
-- ----------------------------------------------------------------
-- 치킨이면서 평점 4.0 이상인 가게
SELECT name, category, rating FROM restaurants
WHERE category = '치킨' AND rating >= 4.0;

-- 치킨이거나 피자인 가게
SELECT name, category FROM restaurants
WHERE category = '치킨' OR category = '피자';

-- 가격이 10000원 이상이고, 현재 판매 중인 메뉴
SELECT menu_name, price, is_available FROM menus
WHERE price >= 10000 AND is_available = TRUE;

-- 분식이 아니고 평점이 3.8 이상인 가게
SELECT name, category, rating FROM restaurants
WHERE NOT category = '분식' AND rating >= 3.8;

-- 괄호로 우선순위 명시 (AND가 OR보다 먼저 계산됨)
-- "치킨이거나, (피자이면서 평점 4점 이상)인 가게"
SELECT name, category, rating FROM restaurants
WHERE category = '치킨' OR (category = '피자' AND rating >= 4.0);


-- ============================================================
-- PART 4 — ORDER BY & LIMIT (정렬 + 개수 제한)
-- ============================================================

-- ----------------------------------------------------------------
-- 4-1. ORDER BY ASC / DESC
-- ----------------------------------------------------------------
-- 메뉴를 가격 오름차순 (기본값 = ASC)
SELECT menu_name, price FROM menus ORDER BY price ASC;

-- 가게를 평점 내림차순 (높은 평점부터)
SELECT name, rating FROM restaurants ORDER BY rating DESC;

-- ----------------------------------------------------------------
-- 4-2. 다중 정렬 — 1차 기준, 2차 기준
-- ----------------------------------------------------------------
-- 카테고리 오름차순 → 같은 카테고리 안에서 평점 내림차순
SELECT name, category, rating FROM restaurants
ORDER BY category ASC, rating DESC;

-- ----------------------------------------------------------------
-- 4-3. LIMIT — 상위 N개만 가져오기
-- ----------------------------------------------------------------
-- 평점 TOP 3 가게
SELECT name, rating FROM restaurants
ORDER BY rating DESC
LIMIT 3;

-- 가장 비싼 메뉴 5개
SELECT menu_name, price FROM menus
ORDER BY price DESC
LIMIT 5;

-- ----------------------------------------------------------------
-- 4-4. LIMIT + OFFSET — 페이지네이션 (쇼핑몰 2페이지)
-- ----------------------------------------------------------------
-- 한 페이지에 5개씩 보여준다고 할 때:
-- 1페이지: OFFSET 0  (0번째부터 5개)
SELECT menu_name, price FROM menus ORDER BY id LIMIT 5 OFFSET 0;

-- 2페이지: OFFSET 5  (5번째부터 5개)
SELECT menu_name, price FROM menus ORDER BY id LIMIT 5 OFFSET 5;

-- 3페이지: OFFSET 10 (10번째부터 5개)
SELECT menu_name, price FROM menus ORDER BY id LIMIT 5 OFFSET 10;

-- ※ 공식: OFFSET = (페이지 번호 - 1) × 페이지 크기


-- ============================================================
-- PART 5 — UPDATE & DELETE (핵버튼 주의!)
-- ============================================================

-- ----------------------------------------------------------------
-- 5-1. 안전한 UPDATE — WHERE로 대상을 특정하기
-- ----------------------------------------------------------------
-- id가 1인 가게의 평점을 4.5로 수정
UPDATE restaurants
SET rating = 4.5
WHERE id = 1;

-- 특정 메뉴의 가격과 설명을 동시에 수정
UPDATE menus
SET price = 23000, description = '2024 신메뉴 리뉴얼'
WHERE id = 1;

-- 확인
SELECT * FROM restaurants WHERE id = 1;
SELECT * FROM menus WHERE id = 1;

-- ----------------------------------------------------------------
-- 5-2. 위험한 UPDATE — WHERE 없음 = 전체 행 수정 (핵버튼!)
-- ----------------------------------------------------------------
-- ⚠️ 아래 쿼리는 절대 실행하지 마세요! 모든 가게 평점이 0이 됩니다.
-- UPDATE restaurants SET rating = 0;
--
-- WHERE는 핵버튼의 '안전핀'입니다. 안전핀 없이 버튼 누르면 전체 폭발!

-- ----------------------------------------------------------------
-- 5-3. SAFE UPDATE MODE — MySQL Workbench 안전장치
-- ----------------------------------------------------------------
-- MySQL Workbench는 기본적으로 WHERE 없는 UPDATE/DELETE를 막아줍니다.
-- 이 설정을 확인/변경하는 방법:
--   메뉴 → Edit → Preferences → SQL Editor
--   → "Safe Updates" 체크 여부 확인
--
-- 코드로도 제어 가능 (이 세션에서만 적용):
-- SET SQL_SAFE_UPDATES = 0;  -- 안전모드 끄기 (주의!)
-- SET SQL_SAFE_UPDATES = 1;  -- 안전모드 켜기 (권장)

-- ----------------------------------------------------------------
-- 5-4. 안전한 DELETE — WHERE로 대상을 특정하기
-- ----------------------------------------------------------------
-- 판매 중지된 메뉴(is_available = FALSE)를 삭제
DELETE FROM menus
WHERE is_available = FALSE;

-- 확인
SELECT * FROM menus WHERE is_available = FALSE;  -- 결과 없어야 함

-- ----------------------------------------------------------------
-- 5-5. 위험한 DELETE — WHERE 없음 = 전체 삭제 (핵버튼 최고 단계!)
-- ----------------------------------------------------------------
-- ⚠️ 절대 실행 금지! 테이블의 모든 데이터가 사라집니다.
-- DELETE FROM menus;

-- ----------------------------------------------------------------
-- 5-6. TRUNCATE vs DELETE 비교
-- ----------------------------------------------------------------
-- TRUNCATE TABLE menus;
--   - 테이블의 모든 데이터를 삭제
--   - WHERE 사용 불가 (전체 삭제만 가능)
--   - DELETE보다 훨씬 빠름 (로그를 남기지 않음)
--   - AUTO_INCREMENT 카운터가 1로 초기화됨
--   - 롤백(ROLLBACK) 불가 — 트랜잭션 밖에서는 복구 불가능!
--
-- DELETE FROM menus;
--   - WHERE로 조건 지정 가능
--   - 로그를 남기므로 ROLLBACK 가능 (트랜잭션 안에서)
--   - TRUNCATE보다 느림
--   - AUTO_INCREMENT 카운터 유지됨
--
-- 결론: 개발 중 테이블 초기화 → TRUNCATE
--       운영 중 특정 데이터 삭제 → DELETE + WHERE


-- ============================================================
-- PART 6 — 종합 실습 쿼리 모음 (실무 시나리오)
-- ============================================================

-- 시나리오 1: 사장님이 "우리 앱에 등록된 치킨 가게 목록이 필요해요"
SELECT id, name, address, rating
FROM restaurants
WHERE category = '치킨'
ORDER BY rating DESC;

-- 시나리오 2: 사장님이 "만 원짜리 이하 메뉴가 뭐가 있는지 보고 싶어요"
SELECT m.menu_name, m.price, r.name AS restaurant_name
FROM menus m
JOIN restaurants r ON m.restaurant_id = r.id
WHERE m.price <= 10000
ORDER BY m.price ASC;
-- (JOIN은 Day 6에서 배웁니다 — 지금은 구조만 눈에 익혀두세요)

-- 시나리오 3: 사장님이 "이름에 '돼지'가 들어가는 메뉴 있어요?"
SELECT menu_name, price FROM menus
WHERE menu_name LIKE '%돼지%';

-- 시나리오 4: 사장님이 "평점 4점 이상인 가게를 평점 높은 순으로, TOP 3만 보여줘"
SELECT name, category, rating
FROM restaurants
WHERE rating >= 4.0
ORDER BY rating DESC
LIMIT 3;

-- 시나리오 5: 사장님이 "1번 가게 메뉴 가격을 다 1000원씩 올려줘"
-- 반드시 WHERE로 가게를 특정해야 합니다!
UPDATE menus
SET price = price + 1000
WHERE restaurant_id = 1;

-- 확인
SELECT menu_name, price FROM menus WHERE restaurant_id = 1;
