# 국내 주식 관심종목 앱

네이버 증권 데이터로 관심종목 · 검색 · 종목상세 화면을 구현한 Flutter 앱입니다.

---

## 실행 방법

```bash
fvm flutter pub get
fvm flutter run
```

- **Flutter 3.47.3 / Dart 3.13.3** (`.fvmrc`에 고정)
- `fvm`을 쓰지 않으면 `flutter` 명령을 그대로 쓰시면 됩니다. (Dart `^3.11.5`, Flutter `>=3.38.0` 필요)
- **웹(Chrome)에서는 동작하지 않습니다.** 네이버 endpoint가 CORS를 허용하지 않습니다.
- 저장소에 `ios/` · `android/` · `web/`만 있습니다. 데스크톱 플랫폼은 제거된 상태로 받았습니다.

### 폰트

스타터가 제공한 `Noto Sans KR`을 그대로 씁니다. 변경하지 않았습니다.

### 확인한 환경

**⚠️ 실제 기기나 시뮬레이터에서 실행 검증을 하지 못했습니다.**
`flutter analyze` 통과와 테스트 21건 통과까지만 확인한 상태입니다.
SVG 아이콘 렌더링, 폰트 적용, 실제 레이아웃은 눈으로 확인이 필요합니다.

---

## 구현 범위

### 필수 — 전부 완료

**1. 관심 화면**

- [x] 종목명 / `종목코드 · 시장` / 현재가 / 등락액·등락률
- [x] 상승 · 하락 · **보합** 세 상태 색상
- [x] 상단 새로고침
- [x] 하단 탭 바 (`navActive` / `navInactive`)
- [x] 시세 미수신 행 스켈레톤
- [x] 빈 상태
- [x] 정렬 (현재가순 / 등락률순 / 가나다순), 바텀시트 + 체크 표시 + 헤더 칩 연동

**2. 검색 화면**

- [x] 입력창 + 지우기 버튼
- [x] 종목명 검색어 하이라이트 (`searchHighlight`)
- [x] 관심 등록 / 해제 즉시 반영
- [x] 등록 · 해제 토스트 (아이콘과 문구 구분)
- [x] 결과 행 → 상세 이동
- [x] 검색 전 초기 상태
- [x] 검색 결과 없음 (입력한 검색어 포함)

**3. 종목상세 화면**

- [x] 상단바 (뒤로가기 · 종목명 · `코드 · 시장` · 관심 토글)
- [x] 현재가 + 등락 (▲ / ▼)
- [x] 기간 탭 4종 (`accentDefault` / `accentBg`)
- [x] 캔들 차트
- [x] 요약 카드 (시가 · 고가 · 저가 · 거래량 · 시가총액, 축약 표기)
- [x] 일별 시세 표 (날짜 `MM.DD` · 종가 · 등락 · 거래량)

**4. 상태 동기화**

- [x] 세 화면의 별 아이콘이 함께 바뀜
- [x] 검색 직후에도 현재 관심 상태 반영
- [x] 검색에서 등록 → 관심 목록 반영
- [x] 상세에서 해제 → 목록 반영

### 추가로 구현한 선택 항목

- Pull to refresh (관심)
- 검색 입력 디바운스 (300ms)
- 검색 로딩 표시
- 토스트 페이드 인 / 아웃

### 구현하지 않은 선택 항목

관심종목 스와이프 삭제, 정렬 기준 영구 저장, 최근 검색어,
차트 축 라벨 · 거래량 바 · 영역 채우기 · 크로스헤어, 일별 시세 무한 스크롤

### 테스트

```bash
fvm flutter test
# 21건 통과
```

| 파일 | 검증 내용 |
|---|---|
| `parsing_test.dart` | 저장한 실제 응답으로 endpoint 4개 파싱 |
| `page_cache_test.dart` | 일별 시세 페이지 요청 횟수와 재사용 |
| `favorite_controller_test.dart` | 관심 상태 토글 · 중복 방지 · 불변성 |
| `widget_test.dart` | 앱 기동과 빈 상태 렌더링 |

---

## 기술 선택과 이유

### 상태관리 — provider + `ChangeNotifier`

`ChangeNotifier`는 Flutter 내장이고, provider는 그걸 위젯 트리에 올려 DI와 dispose를 대신해 주는 얇은 레이어입니다. 상태관리 "철학"이 아니라 배선 도구라 학습 비용이 낮습니다.

**수명을 플래그가 아니라 위젯 트리 위치로 결정한다**는 점이 이 과제에 특히 맞았습니다. 전역에 올린 것은 둘뿐입니다.

```
main.dart
└── CoreRepository          ← 모든 Repository가 참조
    FavoriteController      ← 세 화면이 공유 (요구사항)
    └── MaterialApp
        ├── WatchlistScreen     → WatchlistController    (화면과 함께 소멸)
        ├── SearchScreen        → StockSearchController  (화면과 함께 소멸)
        └── StockDetailScreen   → StockDetailController  (화면과 함께 소멸)
```

상세 화면을 나가면 컨트롤러와 페이지 캐시가 함께 정리되고, 이게 코드에 드러납니다.

**riverpod을 쓰지 않은 이유** — 컴파일 타임 안전성과 `context` 비의존이 장점이지만 학습 곡선과 코드 생성이 붙습니다. 화면 3개, 전역 상태 1개 규모에서는 과합니다.

**GetX를 쓰지 않은 이유** — `Get.find`가 어디서나 통해서 "일단 전역에 올리자"가 쉬워집니다. 전역 컨트롤러가 늘어나면 수명 추적이 어려워집니다.

### 화면 전환 — Flutter 표준

`Navigator.push`, `showModalBottomSheet`, `Overlay`를 씁니다. 라우팅 패키지를 따로 두지 않았습니다. 화면이 3개고 딥링크 요구가 없습니다.

### 네트워크 — Dio

네이버 endpoint 4개는 호스트가 서로 달라 `baseUrl`을 두지 않고 전체 URL을 넘깁니다.

### 폴더 구조

```
lib/
├── binding/       전역 provider 등록
├── constants/     endpoint · 아이콘 경로 · 텍스트 스타일 · 개발 플래그
├── core/          ApiResponse · ResponseList · CoreRepository
├── domains/       watchlist · search · stock_detail
│   └── <도메인>/  controllers · models · enums · views/{screens,widgets}
├── enums/         공용 (PriceDirection)
├── models/        공용 (StockQuote · StockMeta · FavoriteStock)
├── repository/    StockRepository
├── theme/         디자인 토큰 (스타터 제공, 수정하지 않음)
├── utils/         LogUtil · ParseUtil · FormatUtil
└── views/         공용 화면 · 위젯
```

`StockRepository`를 도메인별로 쪼개지 않고 한 클래스에 모았습니다. endpoint가 4개뿐이고 세 화면이 나눠 쓰기 때문입니다. 쪼개면 실시간 시세 메서드가 관심과 상세에 중복됩니다.

### 주요 패키지

| 패키지 | 용도 | 선택 이유 |
|---|---|---|
| `provider` | 상태관리 · DI | 위 참고 |
| `dio` | 네트워크 | 인터셉터와 `ResponseType.bytes` |
| `flutter_svg` | 아이콘 | 벡터라 크기 무관하게 선명, `colorFilter`로 토큰 색 적용 |
| `html` | 일별 시세 파싱 | CSS 선택자로 표 구조를 읽음 |
| `cp949_codec` | EUC-KR 디코딩 | 순수 Dart (아래 참고) |

### 차트 — `CustomPainter`

패키지를 쓰지 않고 직접 그렸습니다. 캔들 차트를 지원하면서 토큰 색과 시안 여백까지 맞추기 쉬운 패키지가 마땅치 않았습니다.

시안과 다른 점: 축 라벨과 거래량 바를 넣지 않았습니다(선택 항목). 캔들 두께는 데이터 개수에 맞춰 자동 계산되므로 기간에 따라 달라집니다.

### 디자인 토큰을 추가한 이유

**`lib/constants/app_text_styles.dart`를 새로 만들었습니다.**

스타터의 `AppTypography`에는 서체와 굵기만 있고 **글자 크기와 행간이 없습니다.** Figma가 그 값을 Variables가 아니라 Text Styles로 관리하고 있어서 토큰에서 빠진 것으로 보입니다.

그대로 두면 화면마다 `fontSize: 15, height: 20/15, letterSpacing: -0.1`을 반복해야 하고, 이는 매직 넘버 금지 규칙과 부딪힙니다. `body` 스타일만 시안에서 28번 쓰입니다.

Figma 텍스트 스타일 6종(`display/price`, `title`, `body`, `label`, 13/18 Regular, `caption`)을 그대로 옮겼습니다. `letterSpacing`은 Figma가 `em` 단위라 `fontSize`를 곱해 논리 픽셀로 환산했습니다.

`lib/theme/`의 원본 파일은 하나도 수정하지 않았습니다.

---

## 직접 판단한 부분과 이유

### 시세를 못 받은 행의 정렬

**어떤 정렬에서든 목록 맨 뒤로 보냅니다.** 0으로 취급하면 하락 종목과 섞여 실제로 떨어진 종목처럼 읽힙니다. 미수신 행끼리는 가나다순입니다.

### 토스트

- **2초 뒤 자동으로 사라집니다.** 문구가 짧아 읽기에 충분하고, 연속으로 토글할 때 화면을 오래 가리지 않습니다.
- **이미 떠 있으면 교체합니다.** 빠르게 여러 번 누를 때 쌓이면 마지막 동작의 결과를 알 수 없습니다.
- 200ms 페이드로 등장 / 퇴장합니다.
- 하단 탭 바 위에 띄워 탭을 가리지 않습니다.

### 긴 종목명 오버플로

목록 행과 상단바 모두 **한 줄 `ellipsis`** 입니다. 여러 줄로 늘리면 행 높이가 들쭉날쭉해지고, 시세 영역을 밀어냅니다.

### 검색어가 매우 길 때

결과 없음 안내문에 검색어를 그대로 넣으면 문구가 화면을 넘칩니다. **20자를 넘으면 잘라서** 보여줍니다.

### 로딩 / 네트워크 에러

- 관심 화면: 관심 목록은 로컬 상태라 바로 그리고, 시세를 못 받은 행만 스켈레톤으로 둡니다. 목록 전체를 로딩으로 덮지 않습니다.
- 검색 화면: 디바운스 직후부터 결과 도착까지 스피너를 띄웁니다.
- 상세 화면: 첫 로딩만 스피너, 기간 전환은 차트 영역만 교체합니다. 일별 시세를 못 받으면 표 자리에 안내 문구를 둡니다.
- 에러 시 앱이 멈추지 않고 빈 값으로 떨어집니다. 모든 Repository 메서드가 `try/catch` 후 로그를 남기고 fallback합니다.

### 빈 상태 안내문 정렬

Figma 텍스트 레이어는 `RIGHT` 정렬인데, 가운데 정렬된 빈 상태에서 오른쪽 정렬은 어색해 **`CENTER`로 구현**했습니다.

### 관심 별 아이콘 색

Figma에서 내보낸 `ico_star_fill.svg`에는 `#FAF9F5`가 박혀 있습니다. 다만 `ASSIGNMENT.md`가 `favoriteActive` / `favoriteInactive`를 쓰라고 명시해 **토큰을 따랐습니다.** (`colorFilter`로 덮어씀)

### 탭 전환 시 상태 유지

`IndexedStack`으로 관심 · 검색 화면을 함께 살려둡니다. 단순 교체면 탭을 옮길 때마다 검색어가 날아가고 시세를 다시 받습니다.

대신 두 컨트롤러가 앱 수명 내내 살아있게 됩니다. 두 화면은 탭 바의 양쪽 끝이라 앱이 켜져 있는 동안 항상 접근 가능하므로 상주가 자연스럽다고 판단했습니다.

### 등락을 직접 계산

실시간 시세 응답에 등락액(`cv`)과 등락률(`cr`)이 있지만 **둘 다 절댓값**이고 방향은 별도 코드(`rf`)로 옵니다. 코드 해석에 기대는 대신 `nv - pcv`로 직접 계산했습니다.

일별 시세 HTML의 전일비도 절댓값입니다. `em.bu_pdn`(하락) 클래스로 방향을 판별해 부호를 붙였습니다.

### 관심 등록 시 종목명과 시장을 함께 저장

실시간 시세 응답에는 거래소명이 없습니다. 관심 목록에 종목코드만 저장하면 화면을 그릴 때마다 **종목마다** 메타 endpoint를 불러야 합니다.

검색 결과에 이미 종목명과 시장이 있으므로, 등록 시점에 함께 저장해 추가 요청을 없앴습니다.

---

## 막혔던 지점

### EUC-KR 디코딩 — 패키지가 잘못 동작했습니다

처음에 `charset` 패키지를 썼는데 테스트에서 `삼성전자`가 `鋱鏋飜飅`로 나왔습니다.

패키지 내부를 열어 보니 **두 매핑 테이블의 이름이 뒤바뀌어** 있었습니다.

```
utf8ToEucKr[0xbbef] = 0xc0bc   ← 실제로는 EUC-KR→유니코드 (삼). 디코딩에 써야 할 테이블
eucKrToUtf8[0xbbef] = 0x92f1   ← 鋱. 디코더가 이걸 참조
```

인코딩 · 디코딩 양방향이 모두 깨지는 상태였습니다.

`charset_converter`는 정상 동작하지만 네이티브 플러그인이라 (1) SDK 하한을 Dart 3.12 / Flutter 3.44로 올려 스타터가 선언한 `^3.11.5`를 깨뜨리고 (2) 플랫폼 채널이라 기기 없이 `flutter test`에서 쓸 수 없습니다.

**`cp949_codec`으로 교체**했습니다. CP949는 EUC-KR의 상위 호환이고 순수 Dart라 두 문제가 모두 없습니다.

### 인코딩이 endpoint마다 달랐습니다

`NAVER_API.md`는 일별 시세 HTML만 EUC-KR이라고 안내하지만, 실제로는 **실시간 시세도 EUC-KR**이었습니다.

| endpoint | Content-Type |
|---|---|
| `ac.stock.naver.com` | (헤더 없음 → UTF-8) |
| `polling.finance.naver.com` | `text/plain;charset=EUC-KR` — **JSON인데 EUC-KR** |
| `stock.naver.com` | `application/json; charset=utf-8` |
| `finance.naver.com` | `text/html;charset=EUC-KR` |

JSON이라고 UTF-8을 가정하면 종목명이 깨집니다. endpoint별로 분기하는 대신 **`CoreRepository`가 항상 원문 바이트를 받아 응답 헤더의 charset을 보고 디코딩**하도록 했습니다. 새 endpoint가 추가돼도 그대로 동작합니다.

### 페이지 캐시를 어떻게 검증할 것인가

"필요한 만큼만 요청하고 재사용한다"는 요구는 눈으로 확인하기 어렵습니다.

Dio의 `HttpClientAdapter`를 가짜로 바꿔 **실제 요청된 페이지 번호를 기록**하는 테스트를 만들었습니다.

- 1개월 → `[1, 2]`만 요청
- 1년으로 전환 → `[3..25]`만 요청 (1·2는 캐시)
- 1개월로 되돌림 → **요청 0건**
- `lastPage`가 5인 종목 → 5를 넘는 페이지 요청 없음

`lastPage`를 알아야 그보다 큰 페이지를 거를 수 있어서 1페이지를 먼저 받고, 나머지는 `Future.wait`로 한꺼번에 받습니다. 25페이지를 순차로 받으면 너무 느립니다.

### `finance.naver.com`이 응답하지 않았습니다

기본 User-Agent로는 응답이 오지 않는 경우가 있어 브라우저 UA를 붙였습니다.
