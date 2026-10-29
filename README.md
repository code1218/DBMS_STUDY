# DBMS_STUDY — 한입배달로 배우는 MySQL

부산 지역 배달 플랫폼 **한입배달**의 데이터팀 신입이 되어, 실제 서비스 형태의 DB 하나로 조회부터 설계·운영까지 배우는 MySQL 입문 과정입니다.

- 대상: SQL 입문자 · 10챕터 × 3시간 (+ 선택 종합 프로젝트)
- 환경: MySQL 8.0 이상, MySQL Workbench 8.0
- 데이터: 한입배달 DB (챕터마다 `hanip_delivery01`, `02`, … 로 새로 생성) — 고객 30 · 가게 15 · 메뉴 70 · 기사 8 · 주문 563 · 주문상세 1,060 · 리뷰 260

## 시작하기

1. MySQL 8.0과 Workbench 설치
2. 매 수업 시작 시 그 챕터 폴더의 **`setup.sql`**을 Workbench에서 전체 실행 (`Ctrl+Shift+Enter`)
   - Ch01 → `hanip_delivery01`, Ch02 → `hanip_delivery02` … 챕터마다 새 DB가 생기고, 지난 DB는 수업 기록으로 남습니다.
   - 같은 챕터를 처음 상태로 되돌리려면 setup.sql 위쪽 `-- DROP DATABASE …` 줄의 주석을 풀고 다시 실행
3. [Ch01](chapters/ch01-first-database/README.md)부터 시작

## 커리큘럼

| Ch | 제목 | 상태 |
|---|---|---|
| 01 | [데이터베이스와 첫 만남](chapters/ch01-first-database/README.md) | ✅ |
| 02 | [SELECT 기본 — 원하는 행과 열만](chapters/ch02-select-basics/README.md) | ✅ |
| 03 | [함수로 데이터 가공하기](chapters/ch03-functions/README.md) | ✅ |
| 04 | 집계와 그룹 | 예정 |
| 05 | JOIN — 흩어진 데이터 잇기 | 예정 |
| 06 | 서브쿼리·집합·윈도우 함수 | 예정 |
| 07 | 테이블 설계와 제약조건 (DDL) | 예정 |
| 08 | 데이터 변경과 트랜잭션 | 예정 |
| 09 | 데이터 모델링과 정규화 | 예정 |
| 10 | 뷰·인덱스·사용자 관리 | 예정 |

전체 설계와 리뉴얼 배경: [docs/CURRICULUM.md](docs/CURRICULUM.md)

## 폴더 구조

```
├── database/              스키마·시드 원본 + ERD·컬럼 사전 (setup.sql 생성 재료)
├── chapters/
│   └── chNN-주제/
│       ├── setup.sql       이 챕터 DB(hanip_deliveryNN) 생성 — 수업 시작 시 실행
│       ├── README.md       교안
│       ├── lecture.sql     강사 시연 스크립트
│       ├── practice.md     실습 문제 + 기대 결과
│       ├── answers.md/.sql 정답과 해설
│       ├── quiz.md         다음 시간 복습 퀴즈 (강사용)
│       └── instructor.md   강사 노트 (강사용)
├── docs/                  커리큘럼 설계서, SQL 작성 규칙
├── src/                   교안 원본 (결과표 자동 생성 전)
└── tools/                 시드 생성기, 교안 빌더
```

## 교안 수정 방법 (관리자용)

교안의 모든 결과표는 실제 MySQL 실행 결과입니다. **`chapters/`의 README·practice·answers는 직접 고치지 말고 `src/`의 원본을 고친 뒤 빌드하세요.**

```bash
pip install pymysql
# 로컬 MySQL에 dev/dev 계정이 있어야 합니다 (tools/build.py 상단에서 변경 가능)
python3 tools/build.py     # 챕터별 setup.sql 생성 + src/*.md 의 ```sql run 블록을 그 챕터 DB에서 실행해 chapters/ 에 출력
```

- ```` ```sql run ```` — 실행하고 결과표 삽입 (`limit=N`으로 표시 행 수 조정)
- ```` ```sql error ```` — 에러가 나야 하는 예제. 실제 에러 메시지 삽입
- ```` ```sql answer ```` — 실습 정답. 문제지에는 결과표만, 해설지에는 SQL+결과
- 교안 원본에서 DB 이름은 `{{DB}}`로 씁니다 (빌드 시 `hanip_deliveryNN`으로 치환)
- 시드 데이터를 바꾸려면 `tools/gen_seed.py` 수정 → `python3 tools/gen_seed.py` → 빌드
