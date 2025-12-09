# Memo Forge — Hub/Link/Satellite 기반 버전 추적형 데이터 아키텍처

## 1. 프로젝트 개요
일반적인 CRUD 구조는 `UPDATE`로 기존 데이터를 덮어쓰기 때문에  
과거 상태, 수정 내역, 누가 어떤 변경을 했는지 복원하기 어려움

본 프로젝트는 Notion / GitHub와 같은 문서·블록 기반 협업 도구에서 요구되는  
**버전 추적(History Tracking)·롤백·시간 여행(Time Travel) 기능**을 DB 레벨에서 보장하기 위해  
Data Vault 2.0 기반의 **Hub / Link / Satellite 구조**를 적용함.

---

## 2. 왜 이 구조인가?

| 문제 | 일반 CRUD | 본 프로젝트 |
|------|----------|-------------|
| 값 변경 시 | UPDATE (과거 유실) | INSERT only (과거 보존) |
| 이력 조회 | 별도 로깅 필요 | Satellite가 곧 히스토리 |
| 특정 시점 복구 | 매우 어려움 | SQL로 바로 복원 |
| 협업/버전/템플릿 | 구현 난이도 높음 | 자연스럽게 지원 |

즉, 본 프로젝트의 DB는 **현재 상태 저장이 아니라 시간 전체를 기록**함

---

## 3. 아키텍처 구성

###  Hub — 엔티티 고유 ID (정체성)
Hub 테이블은 해당 엔티티가 “존재한다”는 사실만 저장함. 
속성은 포함하지 않음. (값은 바뀔 수 있기 때문).

예: `hub_user`, `hub_workspace`, `hub_page`, `hub_block` 등

### * Link — 관계(Relationship)
Hub 간의 관계를 표현합니다. 속성을 포함하지 않음.

예:
- `link_page_workspace` (페이지 ↔ 워크스페이스)
- `link_block_page` (블록 ↔ 페이지)
- `link_page_tag` (페이지 ↔ 태그)

### * Satellite — 속성과 이력
Satellite는 Hub 또는 Link에 붙으며  
속성값이 바뀔 때마다 **UPDATE가 아니라 INSERT** 함.

필드 구성:
- `load_date` (이 버전의 시작 시점)
- `load_end_date` (이 버전의 종료 시점 — NULL이면 현재값)
- `hash_diff` (속성 변경 감지용)

---

## 4.  버전 관리 방식

페이지를 예시로 설명하면:

| 상황 | DB 동작 |
|------|--------|
| 페이지 제목 변경 | 기존 Row `load_end_date` 업데이트 → 새 Row INSERT |
| 내용 수정 | 새 Row INSERT (과거 내용 유지) |
| 롤백 | 특정 `load_date` 시점의 Row만 `current`로 갱신 |

## 5. 동시 편집 & 페이지 락 전략

버전 이력은 Satellite로 모두 남기지만,  
그렇다고 해서 여러 사용자가 동시에 같은 페이지를 편집하다가
서로 마지막 저장으로 덮어버리면 답이 없음.

그래서 **`page_edit_lock` 테이블**을 이용해  
Notion / Google Docs 스타일의 “편집 중” 상태를 관리.

### 6. 목표

- 한 페이지에 대해 **한 시점에 한 명만 “쓰기 권한”**을 갖도록 제어
- 브라우저 꺼먹거나 네트워크 끊겨도 **시간 지나면 락이 자동으로 풀리도록** 설계
- 락 자체는 “세션 상태”이기 때문에,  
  Data Vault와 달리 **이력 관리 대상이 아님 (UPDATE/DELETE 허용)**

### 7. 테이블 개요

`page_edit_lock`:

- `page_hk` : 대상 페이지
- `user_hk` : 락을 잡은 사용자
- `lock_token` : 프론트/백엔드 간 편집 세션 식별용 토큰
- `acquired_at` / `expires_at` : 락 시작/만료 시점
- `is_active` : 현재 활성 락 여부
- `UNIQUE (page_hk, is_active)` : 한 페이지에 active 락은 1개만 허용

### 8. 락 라이프사이클

1. **편집 시작 (락 획득)**
    - 클라이언트가 `/locks` API 호출
    - 서버에서 `INSERT` 시도 → 성공 시 그 사용자가 편집 락 확보
    - 이미 다른 사용자가 `is_active = TRUE` 상태로 잡고 있으면  
      `UNIQUE` 제약에 걸려 실패 → “누가 편집 중” 알림 가능

2. **편집 중 (연장)**
    - 사용자가 계속 편집 중이라면  
      일정 주기로 `expires_at`을 갱신해서 세션 유지
    - 클라이언트가 죽거나 브라우저 꺼져도  
      `expires_at` 지나면 락은 무효로 판단

3. **저장/취소 (락 해제)**
    - 저장 완료 시:
        - Data Vault Satellite에 새 버전 INSERT
        - 그 후 `page_edit_lock.is_active = FALSE`
    - 취소 시에도 동일하게 `is_active = FALSE` 처리

4. **만료 처리**
    - 조회 시 “현재 락 있음?”은
      ```sql
      SELECT ...
        FROM page_edit_lock
       WHERE page_hk = :page
         AND is_active = TRUE
         AND expires_at > NOW();
      ```
    - 배치/스케줄러에서 `expires_at <= NOW()` 인 것들은  
      `is_active = FALSE`로 정리하거나 삭제해도 됨.

### 9. Data Vault와의 역할 분리

- **Data Vault (Hub / Link / Satellite)**  
  → “과거까지 포함한 모든 데이터 이력”  
  → INSERT-only, UPDATE 금지, Time Travel 지원

- **page_edit_lock**  
  → “지금 누가 이 페이지를 잡고 편집 중인가?”  
  → 세션/상태 관리용, UPDATE/DELETE 허용  
  → 이력보다 **현재 동시 편집 제어**에 초점

이렇게 역할을 분리해서,
- **DB 레벨에서는 이력과 동시성 두 가지를 모두 책임지고,**
- 애플리케이션 레벨에서는 이를 이용해  
  Git처럼 히스토리 + Google Docs처럼 편집 충돌 방지까지 구현할 수 있도록 함.
