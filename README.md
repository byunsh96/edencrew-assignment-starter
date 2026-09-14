# `[Flutter 과제] 변성훈`

네이버 증권 데이터로 **관심 · 검색 · 종목상세** 세 화면을 구현한 Flutter 앱입니다.
다크 테마 단일 모드, 프레임 기준 `393 × 852`.

- 스타터가 제공한 원본 문서는 `_README.md`로 남겨 두었습니다.
- 요구사항 원문은 `[docs/ASSIGNMENT.md](docs/ASSIGNMENT.md)`, API 명세는 `[docs/NAVER_API.md](docs/NAVER_API.md)`에 그대로 있습니다.

---

## 1. 실행 방법

```bash
flutter pub get
flutter run
```

- **Flutter 3.47.3 / Dart 3.13.3** — 사용했습니다.

### 확인한 플랫폼과 기기

**iOS 18.5 시뮬레이터(iPhone 16)** 에서 실행해 확인했습니다.
실제 네이버 데이터로 관심 목록 · 검색 · 상세가 모두 동작합니다.
**Android 기기와 실제 iPhone에서는 확인하지 못했습니다.**

### 폰트

스타터가 제공한 `Noto Sans KR`(`assets/fonts/`, `AppTypography.fontFamily`)을 **그대로 씁니다.**
등록 방식도 바꾸지 않았습니다.

### 저장소를 가져온 방식

`Use this template` 대신 **스타터 저장소를 클론해서 본인 저장소를** `origin`**으로 붙이는 방식**을 썼습니다.

```
origin    git@github.com:byunsh96/edencrew-assignment-starter.git
upstream  https://github.com/edencrew/edencrew-assignment-starter.git
```

`Use this template`은 히스토리가 새로 시작되어, 스타터가 준 코드와 제가 쓴 코드의 경계가 커밋 위에 남지 않습니다.
클론해서 가져오면 스타터의 초기 커밋(`207ae8a init`)이 그대로 남아, 아래 한 줄로 **제가 손댄 범위 전체**를 바로 볼 수 있습니다.

```bash
git diff 207ae8a HEAD --stat
```

스타터 원본 파일(`lib/theme/*`, `docs/*`, `_README.md`)을 기준으로 두고 대조하며 작업했습니다.
토큰이 부족할 때 원본을 고치는 대신 새 파일을 추가한 것(`[AppTextStyles](lib/constants/app_text_styles.dart)`)도 같은 이유입니다.

커밋은 요구사항대로 **작업 단위로 나눠** 쌓았습니다. (총 70여 개)

---



## 2. 구현 범위



### 필수 — 전부 완료


| 화면         | 항목                                                                                                                                                               |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **관심**     | 종목명 · `종목코드 · 시장` · 현재가 · 등락액/등락률, 상승·하락·**보합** 세 상태 색, 상단 새로고침, 하단 탭 바(`navActive`/`navInactive`), 시세 미수신 행 스켈레톤, 빈 상태, 정렬(현재가순/등락률순/가나다순) 바텀시트 + 체크 + 헤더 칩 연동  |
| **검색**     | 입력창 + 지우기 버튼, 종목명 검색어 하이라이트(`searchHighlight`), 관심 등록/해제 즉시 반영, 등록·해제 토스트(아이콘·문구 구분), 결과 행 → 상세 이동, 검색 전 초기 상태, 검색 결과 없음(입력한 검색어 포함)                             |
| **상세**     | 상단바(뒤로가기 · 종목명 · `코드 · 시장` · 관심 토글), 현재가 + 등락(▲/▼), 기간 탭 4종(`accentDefault`/`accentBg`), 캔들 차트, 요약 카드(시가·고가·저가·거래량·시가총액 축약 표기), 일별 시세 표(`MM.DD` · 종가 · 등락 · 거래량) |
| **상태 동기화** | 세 화면의 별 아이콘이 함께 바뀜, 검색 직후에도 현재 관심 상태 반영, 검색에서 등록 → 관심 목록 반영, 상세에서 해제 → 목록 반영                                                                                     |




### 추가로 구현한 선택 항목

- Pull to refresh (관심)
- 검색 입력 디바운스 300ms
- 검색 중 로딩 표시
- 토스트 페이드 인 / 아웃 (200ms)



### 구현하지 않은 선택 항목

관심종목 스와이프 삭제, 정렬 기준 영구 저장, 최근 검색어,
차트 축 라벨 · 거래량 바 · 영역 채우기 · 크로스헤어 · 전환 애니메이션, 일별 시세 무한 스크롤

### 테스트

```bash
fvm flutter test
# 00:00 +29: All tests passed!

fvm flutter analyze
# No issues found!
```


| 파일                              | 검증 내용                                                      |
| ------------------------------- | ---------------------------------------------------------- |
| `parsing_test.dart`             | `assets/mock/`에 저장한 **실제 응답**으로 endpoint 4개 파싱 (EUC-KR 포함) |
| `page_cache_test.dart`          | 일별 시세의 **실제 요청 페이지 번호**와 재사용                               |
| `favorite_controller_test.dart` | 관심 토글 · 중복 방지 · 불변성 · 이름/시장 동반 저장                          |
| `watchlist_sort_test.dart`      | 정렬 규칙(미수신 행 포함)과 정렬 바텀시트 체크 표시                             |
| `app_toast_test.dart`           | 토스트 아이콘 색과 노출 위치                                           |
| `widget_test.dart`              | 앱 기동과 빈 상태 렌더링                                             |


---



## 3. 기술 선택과 이유



### 상태관리 — `provider` + `ChangeNotifier`

`ChangeNotifier`는 Flutter 내장이고, `provider`는 그걸 위젯 트리에 올려 DI와 dispose를 대신해 주는 얇은 레이어입니다. 상태관리 "철학"이 아니라 **배선 도구**라 학습 비용이 낮습니다.

이 과제에서 결정적이었던 건 **컨트롤러의 수명을 플래그가 아니라 위젯 트리 위치로 정한다**는 점입니다.

```
main.dart
└── FavoriteController              ← 세 화면이 공유해야 하는 유일한 상태 (전역)
    └── MaterialApp
        ├── FavoriteListScreen  → FavoriteListController   ┐
        ├── StockSearchScreen   → StockSearchController    │ 화면과 함께 소멸
        └── StockDetailScreen   → StockDetailController    ┘
```

전역에 올린 것은 `FavoriteController` 하나뿐입니다(`[AppProviders.global](lib/binding/app_providers.dart)`). 상세 화면을 나가면 컨트롤러와 **일별 시세 페이지 캐시가 함께 정리**되고, 그 사실이 코드 구조에 그대로 드러납니다.

- **riverpod을 쓰지 않은 이유** — 컴파일 타임 안전성은 장점이지만 학습 곡선과 코드 생성이 붙습니다. 화면 3개 · 전역 상태 1개 규모에는 과합니다.
- **GetX를 쓰지 않은 이유** — `Get.find`가 어디서나 통해서 "일단 전역에 올리자"가 쉬워집니다. 전역 컨트롤러가 늘면 수명 추적이 어려워지는데, 그걸 규칙이 아니라 **구조로** 막고 싶었습니다.



### 아키텍처 — 별도 ViewModel 레이어를 두지 않음

```
View (StatelessWidget + Consumer/Selector)
  ▼
Controller (ChangeNotifier)     상태 보유 · 이벤트 처리 · notifyListeners
  ▼
StockRepository                 endpoint 1개 = 메서드 1개, 모델 변환, 에러 로깅
  ▼
CoreRepository (Dio)            요청 · 응답 래핑 · charset 판별 · 로깅
```

Controller가 ViewModel 역할을 겸합니다. 레이어를 하나 더 두면 이 규모에서는 위임 코드만 늘어납니다.
View는 계산하지 않습니다. 파생값(등락액·등락률·방향)은 **모델의 getter**, 표기 형식은 `[FormatUtil](lib/utils/format_util.dart)`이 맡습니다.

### 폴더 구조

```
lib/
├── binding/       전역 provider 등록
├── constants/     endpoint · 아이콘 경로 · 텍스트 스타일 · 개발 플래그
├── core/          ApiResponseModel · CoreRepository
├── domains/       favorite_list · stock_search · stock_detail · home
│   └── <도메인>/  controllers · models · enums · views/{screens,widgets}
├── enums/         공용 (PriceDirection · MainTab)
├── models/        공용 (StockModel · StockQuoteModel)
├── repository/    StockRepository · MockRepository
├── theme/         디자인 토큰 (스타터 제공)
├── utils/         LogUtil · ParseUtil · FormatUtil · DebounceMixin
└── widgets/       공용 App* 위젯
```

`StockRepository`**를 도메인별로 쪼개지 않았습니다.** endpoint가 4개뿐이고 세 화면이 나눠 쓰기 때문입니다. 쪼개면 실시간 시세 메서드가 관심 화면과 상세 화면에 중복됩니다.

반대로 **화면에서 반복되는 조각은 도메인 밖으로 뺐습니다.** `StockLabel`(종목명 + `코드 · 시장`), `FavoriteStarButton`, `AppEmptyView`, `AppToast`는 세 화면이 같은 것을 씁니다.

### 주요 패키지


| 패키지           | 용도         | 선택 이유                                             |
| ------------- | ---------- | ------------------------------------------------- |
| `provider`    | 상태관리 · DI  | 위 참고                                              |
| `dio`         | 네트워크       | `ResponseType.bytes`로 원문 바이트를 받아야 해서 (charset 판별) |
| `flutter_svg` | 아이콘        | 벡터라 크기와 무관하게 선명하고, `colorFilter`로 토큰 색을 덮어쓸 수 있음  |
| `html`        | 일별 시세 파싱   | CSS 선택자로 표 구조를 읽음                                 |
| `cp949_codec` | EUC-KR 디코딩 | 순수 Dart (→ [막혔던 지점](#6-막혔던-지점과-접근-방법))            |




### 차트 — 패키지 없이 `CustomPainter`

`[CandleChart](lib/domains/stock_detail/views/widgets/candle_chart.dart)`에서 직접 그렸습니다.
캔들을 지원하면서 토큰 색과 시안 여백까지 맞추기 쉬운 패키지가 마땅치 않았습니다.

- 캔들 두께는 데이터 개수에 맞춰 자동 계산됩니다(간격 비율 25%, 최소 몸통 1px). 기간 탭에 따라 달라집니다.
- 고가와 저가가 같은 종목(상한가 등)에서 0으로 나누지 않도록 가격 범위 하한을 1로 둡니다.
- 응답이 최신순이라 **뒤집어서** 왼쪽이 과거가 되게 그립니다.
- 축 라벨 · 거래량 바 · 영역 채우기는 선택 항목이라 넣지 않았습니다.



### 디자인 토큰을 추가한 이유

스타터의 `lib/theme/*` 값은 **하나도 바꾸지 않았습니다.** 아래는 전부 *추가*입니다.

**(1)** `lib/constants/app_text_styles.dart` **— 새 파일**

`AppTypography`에는 서체와 굵기만 있고 **글자 크기와 행간이 없습니다.** Figma가 그 값을 Variables가 아니라 Text Styles로 관리해서 토큰에서 빠진 것으로 보입니다.

그대로 두면 화면마다 `fontSize: 15, height: 20/15, letterSpacing: -0.1`을 반복해야 하고, 이는 매직 넘버 금지와 정면으로 부딪힙니다. `body` 하나만 시안에서 수십 번 쓰입니다.
Figma 텍스트 스타일 6종을 그대로 옮겼고, `letterSpacing`은 Figma가 `em` 단위라 `fontSize`를 곱해 논리 픽셀로 환산했습니다. **원본** `app_typography.dart`**를 고치지 않으려고 별도 파일로 뒀습니다.**

**(2)** `AppDimens`**에 추가한 스케일** — 시안에 실제로 쓰이는데 `Scale` 컬렉션에 없던 값들입니다.


| 추가                                 | 값            | 어디에 쓰이는지                                          |
| ---------------------------------- | ------------ | ------------------------------------------------- |
| `spaceHalf`                        | 2            | 종목명과 `코드 · 시장` 사이, 시세와 등락 사이                      |
| `space2Mid`                        | 10           | 검색 입력칸 세로 여백                                      |
| `space3Mid`                        | 14           | 상세 화면 본문 위쪽 여백                                    |
| `radiusXlg`                        | 16           | 정렬 바텀시트 모서리                                       |
| `iconSmMd` · `iconMdLg` · `iconLg` | 18 · 22 · 24 | 시안의 아이콘 크기가 `iconSm`(16) / `iconMd`(20)만으로는 맞지 않음 |
| `iconXlg`                          | 40           | 빈 상태 일러스트                                         |
| `bottomSheetTitleHeight`           | 64           | 정렬 바텀시트 제목 영역                                     |


**(3)** `AppColors` **·** `AppPalette`**에 추가한 색** — 2개입니다.


| 추가           | 값             | 사유                                                           |
| ------------ | ------------- | ------------------------------------------------------------ |
| `dropShadow` | `#000000` 55% | 정렬 바텀시트 뒤 딤. 시안에 있으나 Semantic 토큰에 대응값이 없었습니다.                |
| `textFafafa` | `#FAFAFA`     | 정렬 바텀시트 체크 표시 색. 시안 값이 `textPrimary`(`neutral0`)와 미세하게 다릅니다. |


> `textFafafa`는 **의미가 아니라 hex로 이름이 붙은 토큰**이라 다른 토큰들과 결이 다릅니다.
> 시안 값을 그대로 옮기는 쪽을 택했지만, 시안에서 `textPrimary`로 통일해 준다면 지워야 할 토큰입니다.

---



## 4. 직접 판단한 부분과 이유



### 시세를 못 받은 행의 정렬

**어떤 정렬 기준에서든 목록 맨 뒤로 보냅니다.** 미수신 행끼리는 가나다순입니다.

0으로 취급하면 `현재가순`에서는 저가 종목과, `등락률순`에서는 하락 종목과 섞여 **실제로 떨어진 종목처럼 읽힙니다.** 값이 없는 것과 값이 0인 것은 다릅니다.

정렬 자체는 시세가 도착한 뒤 기준으로 하고, 로딩 중에는 **정렬을 마친 순서를 유지한 채 시세만 비웁니다.** 새로고침할 때마다 행이 위아래로 튀지 않게 하기 위해서입니다. (`[FavoriteListController.items](lib/domains/favorite_list/controllers/favorite_list_controller.dart)`)

### 토스트 (노출 시간 · 사라지는 방식)

Figma에는 떠 있는 모습만 있습니다.

- **2초 뒤 자동으로 사라집니다.** 문구가 한 줄이라 읽기에 충분하고, 연속으로 토글할 때 화면을 오래 가리지 않습니다.
- **이미 떠 있으면 교체합니다.** 빠르게 여러 번 누를 때 쌓이면 마지막 동작의 결과를 알 수 없습니다.
- **200ms 페이드 인 / 아웃.** 즉시 사라지면 상태가 바뀐 건지 화면이 튄 건지 구분되지 않습니다.
- **하단 탭 바 위에 띄웁니다.** `AppToastScope`로 탭 바를 뺀 영역을 경계로 잡아, 토스트가 탭을 가리지 않습니다. 탭 바가 없는 상세 화면에서는 본문 영역이 그대로 경계가 됩니다.



### 로딩 / 네트워크 에러


| 화면  | 처리                                                                    |
| --- | --------------------------------------------------------------------- |
| 관심  | 관심 목록은 로컬 상태라 **행은 바로 그리고, 시세 칸만 스켈레톤**으로 둡니다. 목록 전체를 스피너로 덮지 않습니다.   |
| 검색  | 디바운스 시작부터 결과 도착까지 스피너를 띄웁니다. 응답이 오는 사이 검색어가 바뀌면 **늦게 온 이전 결과는 버립니다.** |
| 상세  | 첫 진입만 스피너, 기간 전환은 **차트 영역만** 교체합니다. 이미 그려진 현재가·요약·표가 사라지지 않습니다.       |


에러는 **조용히 삼키지 않되 앱을 멈추지도 않습니다.** 모든 Repository 메서드가 `try/catch` 후 `LogUtil`로 남기고 빈 값으로 떨어집니다. 일별 시세를 못 받으면 표 자리에 안내 문구를 둡니다.

### 긴 종목명 오버플로

목록 행 · 검색 결과 · 상세 상단바 모두 **한 줄** `ellipsis` 입니다.
여러 줄로 늘리면 행 높이가 들쭉날쭉해지고, 오른쪽 시세 영역을 밀어냅니다. 목록에서는 행 높이가 일정한 편이 스캔하기 좋습니다.

### 검색어가 매우 길 때의 빈 상태 문구

결과 없음 안내문에 검색어를 그대로 넣으면 문구가 화면을 넘칩니다.
**20자를 넘으면 잘라서** `...`를 붙입니다. 20자는 `393px` 폭에서 두 줄을 넘지 않는 선으로 잡은 임의값입니다.

### 유사해 보이는 위젯의 1px 차이 — 통일하고 TODO를 남김

시안에서 **같아 보이는 요소가 화면마다 1px씩 다른** 곳이 있었습니다.

- 종목명 + `코드 · 시장` 묶음의 세로 간격: 상세 상단바 **1px**, 관심 목록 · 검색 결과 **2px**
- 상세 요약 카드 셀의 세로 여백 **9px**, 라벨-값 간격 **3px** (주변 토큰이 전부 짝수인데 이 둘만 홀수)

시안의 `Components` 페이지가 비어 있어, 이들이 **하나의 컴포넌트인지 화면마다 따로 그린 것인지 판단할 근거가 없었습니다.**
1px 차이를 그대로 살리려면 같은 모양의 위젯을 화면 수만큼 만들거나 파라미터를 뚫어야 하는데, **보일러플레이트가 늘어나는 대가에 비해 얻는 것이 1px**이라고 봤습니다.

그래서 **같은 요소로 보고 하나로 통일**했습니다. (`[StockLabel](lib/widgets/stock_label.dart)` — `spaceHalf`(2)로 맞춤)
대신 **넘어간 자리마다** `//TODO` **주석으로 근거와 원래 값을 남겨** 두었습니다. 시안이 컴포넌트로 정리되거나 의도된 차이라는 확인을 받으면 그 지점만 되돌리면 됩니다.

```dart
//TODO Figma 확인 필요.
// 세로 간격이 화면마다 다르다. (상세 상단바 1px / 그 외 2px)
// 같은 요소로 보고 spaceHalf(2)로 통일해 진행한다. 시안이 컴포넌트로 정리되면 다시 맞춘다.
```



### 버튼 눌림 효과 — 끄고 한곳에 묶음

시안에 **press / hover 상태가 정의되어 있지 않습니다.** 그렇다고 `InkWell`을 그대로 쓰면 Material 기본 잉크 효과(splash · highlight · hover · focus)가 나오는데, 이건 **시안에 없는 시각 효과를 제가 추가하는 셈**입니다.

그래서 `[AppInkWell](lib/widgets/app_ink_well.dart)`로 네 가지 효과를 모두 `transparent`로 두고, **터치 영역만** 쓰도록 묶었습니다.

```dart
InkWell(
  onTap: onTap,
  hoverColor: Colors.transparent,
  splashColor: Colors.transparent,
  focusColor: Colors.transparent,
  highlightColor: Colors.transparent,
  child: child,
)
```

한곳에 묶어 둔 이유는, 나중에 효과 스펙이 정해지면 **이 파일 하나만 고치면 앱 전체에 적용되기 때문**입니다. 화면마다 `InkWell`을 직접 쓰면 그때 전수 조사를 해야 합니다. (생성자에 주석으로 남겨둔 `hoverColor` / `pressedColor` 자리가 그 확장 지점입니다.)

### Figma와 다르게 구현한 부분


| 부분          | 시안                                    | 구현                                       | 이유                                                           |
| ----------- | ------------------------------------- | ---------------------------------------- | ------------------------------------------------------------ |
| 빈 상태 안내문 정렬 | 텍스트 레이어가 `RIGHT`                      | `CENTER`                                 | 아이콘·제목이 가운데 정렬된 블록에서 본문만 오른쪽 정렬은 어색합니다. 레이어 속성이 남은 값으로 봤습니다. |
| 관심 별 아이콘 색  | `ico_star_fill.svg`에 `#FAF9F5`가 박혀 있음 | `favoriteActive` / `favoriteInactive` 토큰 | `ASSIGNMENT.md`가 이 토큰을 쓰라고 명시합니다. `colorFilter`로 덮어썼습니다.     |
| 위 1px 차이들   | 화면마다 1~2px 상이                         | 하나로 통일                                   | 위 항목 참고                                                      |




### 그 밖에 직접 정한 것

**탭 전환 시 상태 유지** — `IndexedStack`으로 관심 · 검색 화면을 함께 살려둡니다. 단순 교체면 탭을 옮길 때마다 검색어가 날아가고 시세를 다시 받습니다. 대신 두 컨트롤러가 앱 수명 내내 살아있게 되는데, 두 화면은 탭 바의 양쪽 끝이라 앱이 켜져 있는 동안 항상 접근 가능하므로 상주가 자연스럽다고 봤습니다.

**등락을 응답 값이 아니라 직접 계산** — 실시간 시세 응답의 등락액(`cv`)과 등락률(`cr`)은 **둘 다 절댓값**이고 방향은 별도 코드(`rf`)로 옵니다. 코드 해석에 기대는 대신 `nv - pcv`로 계산했습니다. 일별 시세 HTML의 전일비도 절댓값이라 `em.bu_pdn`(하락) 클래스로 방향을 판별해 부호를 붙였습니다.

**관심 등록 시 종목명과 시장을 함께 저장** — 실시간 시세 응답에는 거래소명이 없습니다. 관심 목록에 종목코드만 저장하면 화면을 그릴 때마다 **종목마다** 메타 endpoint를 불러야 합니다. 검색 결과에 이미 종목명과 시장이 있으므로 등록 시점에 함께 저장해 추가 요청을 없앴습니다. (상세 화면은 한 종목뿐이라 메타를 1건 부르고, 응답이 오면 그 값으로 갈아끼웁니다.)

**보합(0%) 처리** — `[PriceDirection](lib/enums/price_direction.dart)`에 `flat`을 두고 텍스트 · 배경 · 차트 색을 모두 분기합니다. `+0`은 상승으로 읽히므로 보합에는 부호를 붙이지 않습니다.

**시가총액 축약 단위** — Figma에는 조 단위 예시(`1,063조`)만 있습니다. 조에 못 미치는 종목은 `0조`가 되어 의미를 잃으므로 **억으로 한 단계 내렸습니다.**

---



## 5. 데이터 로딩 — 요청을 어떻게 줄였는가



### 실시간 시세는 한 번의 요청으로

관심종목 전체를 `query` 파라미터에 이어 붙여 **1회 호출**합니다. 종목마다 부르지 않습니다.

```dart
await _stockRepository.getRealtimeQuotes(symbols);   // symbols 전체를 한 번에
```



### 일별 시세는 페이지 단위로 캐시

`[DailyQuoteCacheManager](lib/domains/stock_detail/controllers/daily_quote_cache_manager.dart)`가 페이지 번호 → 데이터를 들고 있습니다. 기간 탭을 오갈 때 **이미 받은 페이지는 다시 요청하지 않습니다.**


| 동작                | 실제 요청 페이지                |
| ----------------- | ------------------------ |
| 진입 (1개월, 2페이지)    | `1, 2`                   |
| → 1년 (25페이지)      | `3 ~ 25` (1·2는 캐시)       |
| → 1개월로 복귀         | **0건**                   |
| `lastPage`가 5인 종목 | 5를 넘는 페이지는 요청 자체를 만들지 않음 |


`lastPage`를 알아야 그보다 큰 페이지를 거를 수 있어서 **1페이지를 먼저 받고**, 나머지는 `Future.wait`로 한꺼번에 받습니다. 25페이지를 순차로 받으면 너무 느립니다.
빈 응답은 캐시하지 않습니다. 저장해 버리면 "이미 받았다"고 판단해 영영 재시도하지 않습니다.

이 동작은 눈으로 확인하기 어려워 **Dio의** `HttpClientAdapter`**를 가짜로 바꿔 실제 요청된 페이지 번호를 기록하는 테스트**(`page_cache_test.dart`)로 검증했습니다.

---



## 6. 막혔던 지점과 접근 방법



### (1) EUC-KR 디코딩 패키지가 잘못 동작했습니다

처음 쓴 `charset` 패키지(2.0.1)에서 `삼성전자`가 `鋱鏋飜飅`로 나왔습니다.
패키지 내부를 열어 보니 **두 매핑 테이블의 이름이 서로 뒤바뀌어** 있었습니다.

```
utf8ToEucKr[0xbbef] = 0xc0bc   ← 실제로는 EUC-KR→유니코드(삼). 디코딩에 써야 할 테이블
eucKrToUtf8[0xbbef] = 0x92f1   ← 鋱. 디코더가 이걸 참조하고 있었음
```

인코딩·디코딩 양방향이 모두 깨지는 상태였습니다.
`charset_converter`는 정상 동작하지만 **네이티브 플러그인**이라 ① SDK 하한을 올려 스타터가 선언한 `^3.11.5`를 깨뜨리고 ② 플랫폼 채널이라 기기 없이 `flutter test`에서 쓸 수 없습니다.

`cp949_codec`**으로 교체**했습니다. CP949는 EUC-KR의 상위 호환이고 순수 Dart라 두 문제가 모두 없습니다. 덕분에 파싱 검증을 전부 `flutter test`로 돌릴 수 있게 됐습니다.

### (2) 인코딩이 endpoint마다 달랐습니다

`NAVER_API.md`는 일별 시세 HTML만 EUC-KR이라고 안내하지만, 실제로는 **실시간 시세도 EUC-KR**이었습니다.


| endpoint                    | Content-Type                                    |
| --------------------------- | ----------------------------------------------- |
| `ac.stock.naver.com`        | (헤더 없음 → UTF-8)                                 |
| `polling.finance.naver.com` | `text/plain;charset=EUC-KR` — **JSON인데 EUC-KR** |
| `stock.naver.com`           | `application/json; charset=utf-8`               |
| `finance.naver.com`         | `text/html;charset=EUC-KR`                      |


JSON이니까 UTF-8이라고 가정하면 종목명이 깨집니다.
endpoint별로 분기하는 대신, `CoreRepository`**가 항상** `ResponseType.bytes`**로 원문을 받아 응답 헤더의 charset을 보고 디코딩**하도록 했습니다. 새 endpoint가 추가돼도 그대로 동작합니다.

### (3) 네이버가 200으로 차단 페이지를 돌려줍니다

`finance.naver.com`은 기본 User-Agent로는 응답하지 않는 경우가 있어 **브라우저 UA**를 붙였습니다.
또 차단 시에도 상태 코드가 200이라 `statusCode`로는 실패를 잡을 수 없어, **표를 파싱해 0행이면 정상 응답이 아니라고** 판정합니다.

호출이 잦아 차단되면 개발이 멈추므로, `docs/NAVER_API.md`의 「네트워크가 막힐 때」를 따라 `assets/mock/`에 저장한 실제 응답으로 이어가는 경로를 뒀습니다(`[MockRepository](lib/repository/mock_repository.dart)`).
다만 **저장본이 실시간 시세로 오인될 수 있어**, 한 번이라도 대체가 일어나면 화면 상단에 배너(`[MockBanner](lib/widgets/mock_banner.dart)`)로 알리도록 했습니다.

> ⚠️ 이 대체 경로는 `[DevConfig.useMockOnFailure](lib/constants/dev_config.dart)`로 끕니다.
> 현재 저장소에는 `true`**로 커밋되어 있습니다.** 네트워크가 살아 있으면 저장본을 쓰지 않지만,
> 네이버가 막힌 환경에서 실행하면 과거 시세가 배너와 함께 표시됩니다.



### (4) 페이지 캐시를 어떻게 "증명"할 것인가

"필요한 만큼만 요청하고 재사용한다"는 요구는 화면만 봐서는 확인할 수 없습니다.
로그로 남기는 방법도 있지만 사람이 읽어야 하고, 리팩터링하다 깨져도 아무도 모릅니다.

`HttpClientAdapter`를 갈아끼워 **요청된 페이지 번호를 배열로 수집**하고 그 배열을 단언하는 테스트를 만들었습니다. 위 [표](#일별-시세는-페이지-단위로-캐시)가 그 테스트의 기대값입니다.

---



## 7. 남은 것 / 알려진 사항

- `//TODO` 주석 2건 — 위에서 설명한 **1px 차이 통일 지점**입니다. 판단 근거와 원래 값을 함께 남겨 두었습니다.
- `DevConfig.useMockOnFailure`가 `true`입니다. (위 ⚠️ 참고)
- `FavoriteListController.hasError`는 계산하지만 **화면에서 쓰지 않습니다.** 목록 전체를 에러 화면으로 덮는 대신 행별 스켈레톤을 유지하기로 하면서 쓰임이 없어졌고, 전용 에러 표시가 필요해질 때를 위해 남겨 두었습니다.
- Android 실기기 · iOS 실기기 확인은 하지 못했습니다.

