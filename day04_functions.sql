-- =============================================================
-- 한입배달 DB 수업 — Day 4: 데이터 가공의 기술 (내장 함수)
-- =============================================================

USE hanip_delivery;

-- =============================================================
-- PART 1. 문자열 함수 (String Functions)
-- =============================================================

-- ── 1-1. CONCAT: 문자열 합치기 ──────────────────────────────
-- 가게명과 카테고리를 합쳐서 "가게명 (카테고리)" 형태로 출력
SELECT
    name,
    category,
    CONCAT(name, ' (', category, ')') AS 가게정보
FROM restaurants;

-- ── 1-2. SUBSTRING: 문자열 일부 추출 ────────────────────────
-- 가게명의 앞 3글자만 추출 (SUBSTR도 동일)
SELECT
    name,
    SUBSTRING(name, 1, 3) AS 가게명앞3글자
FROM restaurants;

-- 메뉴명의 3번째 글자부터 끝까지 추출
SELECT
    menu_name,
    SUBSTRING(menu_name, 3) AS 3번째부터
FROM menus
LIMIT 5;

-- ── 1-3. LENGTH vs CHAR_LENGTH: 바이트 vs 글자 수 ───────────
-- ⚠️ 매우 중요! 한글은 UTF-8에서 한 글자 = 3바이트
-- LENGTH     : 바이트(byte) 수를 반환
-- CHAR_LENGTH: 실제 글자(character) 수를 반환

SELECT
    name,
    LENGTH(name)      AS 바이트수,   -- 한글 1글자 = 3바이트
    CHAR_LENGTH(name) AS 글자수       -- 한글 1글자 = 1글자
FROM restaurants;

-- 직접 확인해보기
SELECT
    '안녕'               AS 문자열,
    LENGTH('안녕')       AS LENGTH결과,       -- 6 (2글자 × 3바이트)
    CHAR_LENGTH('안녕')  AS CHAR_LENGTH결과;  -- 2

-- 실무 활용: 글자 수 기준 필터는 반드시 CHAR_LENGTH 사용
SELECT menu_name
FROM menus
WHERE CHAR_LENGTH(menu_name) >= 5;  -- 5글자 이상 메뉴

-- ── 1-4. TRIM / LTRIM / RTRIM: 공백 제거 ───────────────────
-- TRIM  : 양쪽 공백 제거
-- LTRIM : 왼쪽 공백 제거
-- RTRIM : 오른쪽 공백 제거
SELECT
    '  한입배달  '              AS 원본,
    TRIM('  한입배달  ')        AS TRIM결과,
    LTRIM('  한입배달  ')       AS LTRIM결과,
    RTRIM('  한입배달  ')       AS RTRIM결과;

-- 실무 활용: 사용자 입력값의 공백 제거
SELECT * FROM customers
WHERE TRIM(name) = '김민준';

-- ── 1-5. REPLACE: 문자열 치환 ───────────────────────────────
-- 주소에서 '부산' → '🌊부산' 으로 치환
SELECT
    name,
    address,
    REPLACE(address, '부산', '🌊부산') AS 주소이모지
FROM restaurants;

-- 메뉴명에서 특정 단어 제거 (빈 문자열로 치환)
SELECT
    menu_name,
    REPLACE(menu_name, '구이', '') AS 구이제거
FROM menus
WHERE menu_name LIKE '%구이%';

-- ── 1-6. LPAD / RPAD: 자릿수 채우기 ────────────────────────
-- LPAD: 왼쪽에 지정 문자를 채워 총 N자리로 만들기
-- 주문번호 포맷팅: 1 → '00001', 2 → '00002'
SELECT
    id,
    LPAD(id, 5, '0') AS 주문번호
FROM menus;

-- RPAD: 오른쪽 채우기
SELECT
    menu_name,
    RPAD(menu_name, 15, ' ') AS 메뉴명고정폭
FROM menus
LIMIT 5;

-- ── 1-7. UPPER / LOWER: 대소문자 변환 ──────────────────────
SELECT
    category,
    UPPER(category) AS 대문자,
    LOWER(category) AS 소문자
FROM restaurants;

-- 실무 활용: 대소문자 무관한 비교
SELECT * FROM restaurants
WHERE LOWER(category) = 'chicken';


-- =============================================================
-- PART 2. 숫자 함수 (Numeric Functions)
-- =============================================================

-- ── 2-1. ROUND: 반올림 ──────────────────────────────────────
-- ROUND(값, 소수점자리)
SELECT
    name,
    rating,
    ROUND(rating, 0) AS 별점반올림,   -- 소수점 0자리 = 정수
    ROUND(rating, 1) AS 소수1자리
FROM restaurants;

-- 가격을 100원 단위로 반올림
SELECT
    menu_name,
    price,
    ROUND(price, -2) AS 100원단위반올림  -- 음수 = 정수 자리
FROM menus;

-- ── 2-2. CEIL: 올림 ─────────────────────────────────────────
-- 가격을 천 원 단위로 올림
SELECT
    menu_name,
    price,
    CEIL(price / 1000) AS 천원단위올림,
    CEIL(price / 1000) * 1000 AS 올림가격
FROM menus;

-- ── 2-3. FLOOR: 내림 ────────────────────────────────────────
-- 가격을 천 원 단위로 내림
SELECT
    menu_name,
    price,
    FLOOR(price / 1000) AS 천원단위내림,
    FLOOR(price / 1000) * 1000 AS 내림가격
FROM menus;

-- ROUND / CEIL / FLOOR 비교 (값: 4500)
SELECT
    4500         AS 원래값,
    ROUND(4500 / 1000, 0) AS ROUND결과,   -- 5 (반올림)
    CEIL(4500 / 1000)     AS CEIL결과,    -- 5 (올림)
    FLOOR(4500 / 1000)    AS FLOOR결과;   -- 4 (내림)

-- ── 2-4. MOD: 나머지 ────────────────────────────────────────
-- MOD(피제수, 제수) 또는 % 연산자
SELECT
    menu_name,
    price,
    MOD(price, 1000) AS 천원미만금액,     -- 1000 미만 나머지
    price - MOD(price, 1000) AS 절사가격  -- 100원 이하 절사
FROM menus;

-- 짝수/홀수 구분
SELECT
    id,
    menu_name,
    MOD(id, 2) AS 홀짝,                   -- 0이면 짝수, 1이면 홀수
    IF(MOD(id, 2) = 0, '짝수', '홀수') AS 구분
FROM menus;

-- ── 2-5. ABS: 절댓값 ────────────────────────────────────────
SELECT ABS(-500) AS 절댓값_예시;  -- 500

-- 두 가격의 차이 (어느 쪽이 크든 양수로)
SELECT
    a.menu_name AS 메뉴A,
    b.menu_name AS 메뉴B,
    ABS(a.price - b.price) AS 가격차이
FROM menus a, menus b
WHERE a.id = 1 AND b.id = 2;

-- ── 2-6. TRUNCATE: 소수점 버림 ──────────────────────────────
-- TRUNCATE(값, 소수점자리) — 반올림 없이 그냥 자름
SELECT
    name,
    rating,
    TRUNCATE(rating, 0) AS 버림별점,   -- 4.8 → 4
    FLOOR(rating)       AS FLOOR비교   -- FLOOR와 동일 (양수일 때)
FROM restaurants;

-- 부가세 포함 가격에서 부가세 제거 (반올림 없이)
SELECT
    menu_name,
    price,
    TRUNCATE(price / 1.1, 0) AS 부가세제외가격
FROM menus;


-- =============================================================
-- PART 3. 날짜 함수 (Date Functions)
-- =============================================================

-- ── 3-1. NOW / CURDATE / CURTIME ────────────────────────────
SELECT
    NOW()     AS 현재날짜시간,    -- 2026-04-17 14:30:00
    CURDATE() AS 오늘날짜,        -- 2026-04-17
    CURTIME() AS 현재시간;        -- 14:30:00

-- ── 3-2. DATE_FORMAT: 날짜 형식 변환 ───────────────────────
-- 주요 포맷 코드: %Y(4자리연도), %y(2자리연도),
--                %m(월), %d(일), %H(24시), %h(12시), %i(분), %s(초)
SELECT
    name,
    joined_at,
    DATE_FORMAT(joined_at, '%Y년 %m월 %d일')     AS 한국형식,
    DATE_FORMAT(joined_at, '%Y-%m-%d')            AS ISO형식,
    DATE_FORMAT(joined_at, '%m/%d/%Y')            AS 미국형식,
    DATE_FORMAT(joined_at, '%Y년 %m월')           AS 연월만
FROM customers;

-- 현재 날짜 포맷
SELECT DATE_FORMAT(NOW(), '%Y년 %m월 %d일 %H시 %i분 %s초') AS 현재;

-- ── 3-3. DATEDIFF: 날짜 차이 ────────────────────────────────
-- DATEDIFF(기준날짜, 빼는날짜) = 날짜 차이 (일 단위)
SELECT
    name,
    joined_at,
    DATEDIFF(NOW(), joined_at) AS 가입후일수,
    FLOOR(DATEDIFF(NOW(), joined_at) / 30) AS 가입후개월수
FROM customers
ORDER BY 가입후일수 DESC;

-- ── 3-4. DATE_ADD / DATE_SUB: 날짜 더하기/빼기 ──────────────
-- INTERVAL 단위: DAY, WEEK, MONTH, YEAR, HOUR, MINUTE, SECOND
SELECT
    NOW()                               AS 현재,
    DATE_ADD(NOW(), INTERVAL 7 DAY)     AS 7일후,
    DATE_ADD(NOW(), INTERVAL 1 MONTH)   AS 1달후,
    DATE_ADD(NOW(), INTERVAL 1 YEAR)    AS 1년후,
    DATE_SUB(NOW(), INTERVAL 7 DAY)     AS 7일전,
    DATE_SUB(NOW(), INTERVAL 1 MONTH)   AS 1달전;

-- 실무 활용: 최근 30일 안에 가입한 고객
SELECT name, joined_at
FROM customers
WHERE joined_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY joined_at DESC;

-- 만료일 계산: 가입일로부터 1년 후 멤버십 만료
SELECT
    name,
    joined_at,
    DATE_ADD(joined_at, INTERVAL 1 YEAR) AS 멤버십만료일
FROM customers;

-- ── 3-5. YEAR / MONTH / DAY: 날짜 구성요소 추출 ─────────────
SELECT
    name,
    joined_at,
    YEAR(joined_at)  AS 가입연도,
    MONTH(joined_at) AS 가입월,
    DAY(joined_at)   AS 가입일
FROM customers;

-- 월별 가입 고객 수 (Day 5 복선)
SELECT
    MONTH(joined_at) AS 가입월,
    COUNT(*) AS 고객수
FROM customers
GROUP BY MONTH(joined_at)
ORDER BY 가입월;


-- =============================================================
-- PART 4. 조건 함수 (Conditional Functions)
-- =============================================================

-- ── 4-1. IFNULL: NULL이면 대체값 사용 ───────────────────────
-- IFNULL(값, NULL일때_대체값)
SELECT
    menu_name,
    menu_description,
    IFNULL(menu_description, '설명 없음') AS 설명
FROM menus;

-- ── 4-2. IF: 단순 조건 분기 ─────────────────────────────────
-- IF(조건, 참일때_값, 거짓일때_값) — 엑셀 IF 함수와 동일!
SELECT
    menu_name,
    price,
    IF(price >= 10000, '고가', '저가') AS 가격분류
FROM menus;

-- 별점 4.5 이상이면 '추천', 미만이면 '보통'
SELECT
    name,
    rating,
    IF(rating >= 4.5, '추천', '보통') AS 추천여부
FROM restaurants;

-- ── 4-3. CASE WHEN: 다중 조건 분기 ─────────────────────────
-- 엑셀의 중첩 IF와 동일 — CASE WHEN은 위에서 아래로 첫 번째 참인 조건 적용

-- 메뉴 가격대 분류
SELECT
    menu_name,
    price,
    CASE
        WHEN price >= 15000 THEN '고가'
        WHEN price >= 8000  THEN '중가'
        ELSE                     '저가'
    END AS 가격대
FROM menus
ORDER BY price DESC;

-- 별점 등급 분류
SELECT
    name,
    rating,
    CASE
        WHEN rating >= 4.5 THEN '⭐⭐⭐'
        WHEN rating >= 4.0 THEN '⭐⭐'
        ELSE                    '⭐'
    END AS 별점등급
FROM restaurants
ORDER BY rating DESC;

-- CASE WHEN + 특정 값 비교 (단순형)
SELECT
    menu_name,
    CASE category
        WHEN '한식' THEN '🍚 한식'
        WHEN '치킨' THEN '🍗 치킨'
        WHEN '피자' THEN '🍕 피자'
        ELSE              '기타'
    END AS 카테고리아이콘
FROM menus
JOIN restaurants ON menus.restaurant_id = restaurants.id
LIMIT 10;


-- =============================================================
-- PART 5. DISTINCT & AS
-- =============================================================

-- ── 5-1. DISTINCT: 중복 제거 ────────────────────────────────
-- 카테고리 목록 조회 (중복 없이)
SELECT DISTINCT category
FROM restaurants
ORDER BY category;

-- 고객이 주문한 적 있는 가게 ID 목록 (Day 5 연계)
-- SELECT DISTINCT restaurant_id FROM orders;

-- DISTINCT + COUNT
SELECT COUNT(DISTINCT category) AS 카테고리수
FROM restaurants;

-- ── 5-2. AS: 별칭 (Alias) ────────────────────────────────────
-- 컬럼 별칭
SELECT
    name       AS 가게이름,
    category   AS 카테고리,
    rating     AS 평점
FROM restaurants;

-- 계산식 별칭
SELECT
    menu_name               AS 메뉴명,
    price                   AS 원가,
    ROUND(price * 1.1, 0)   AS VAT포함가격
FROM menus;

-- 함수 결과 별칭
SELECT
    CONCAT(name, ' (', category, ')') AS 가게정보,
    LPAD(id, 5, '0')                  AS 가게번호,
    rating                            AS 평점
FROM restaurants;

-- 한글 별칭 (따옴표 없어도 되지만 한글·공백 포함 시 백틱 권장)
SELECT
    name AS `가게 이름`,
    CONCAT(name, ' - ', category) AS `가게 및 카테고리`
FROM restaurants;

-- ── 5-3. SELECT 최종 문법 구조 정리 ─────────────────────────
-- ============================================================
-- SELECT 함수(컬럼) AS 별칭   ← 가공 + 이름표
-- FROM   테이블               ← 어디서
-- WHERE  조건                 ← 개별 행 필터
-- ORDER BY 기준               ← 정렬
-- LIMIT  개수;                ← 몇 건만
-- ============================================================

-- 종합 예시: 10,000원 이상 메뉴를 가격 내림차순으로 5건, 가격대 분류 포함
SELECT
    menu_name                                             AS 메뉴명,
    price                                                 AS 가격,
    CONCAT(LPAD(id, 5, '0'))                              AS 메뉴번호,
    CASE
        WHEN price >= 15000 THEN '고가'
        WHEN price >= 8000  THEN '중가'
        ELSE                     '저가'
    END                                                   AS 가격대
FROM menus
WHERE price >= 10000
ORDER BY price DESC
LIMIT 5;
