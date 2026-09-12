# 코딩 컨벤션

`flutter analyze`를 통과하는 것은 최소 조건이다. 아래는 그 위에 얹는 프로젝트 규칙.

---

## 네이밍

| 대상 | 규칙 | 예 |
|---|---|---|
| 파일 | snake_case | `watchlist_controller.dart` |
| 클래스 / enum / mixin | PascalCase | `WatchlistController` |
| 상수 | lowerCamelCase | `maxChartPage` |
| private | `_` prefix | `_stockRepository` |

**파일명과 파일 내 최상위 class/enum/mixin 이름이 일치해야 한다.**

- `stock_quote.dart` → `class StockQuote`
- `price_direction.dart` → `enum PriceDirection`
- `chart_cache_mixin.dart` → `mixin ChartCacheMixin`

Dart는 `SCREAMING_SNAKE_CASE`를 쓰지 않는다. `constant_identifier_names` lint 위반이다.

---

## 상태

**`setState`를 쓰지 않는다.** `ChangeNotifier` + `Consumer`로 처리한다.

```dart
// 금지
setState(() => _isExpanded = true);

// 권장 — 컨트롤러가 상태를 갖고 알린다
class DetailController extends ChangeNotifier {
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}

Consumer<DetailController>(
  builder: (BuildContext context, DetailController controller, _) =>
      controller.isExpanded ? const DetailBody() : const SizedBox.shrink(),
)
```

`context.read` / `context.watch` / `Consumer`를 구분해서 쓴다.

| | 구독 | 쓰는 곳 |
|---|---|---|
| `context.read<T>()` | 안 함 | `onTap` 등 이벤트 핸들러 |
| `context.watch<T>()` | 함 | `build`. 위젯 전체가 리빌드된다 |
| `Consumer<T>` | 함 | 리빌드 범위를 좁힐 때 |
| `Selector<T, S>` | 해당 값만 | 특정 필드만 볼 때 |

`build` 안에서 `context.read`로 상태를 읽으면 갱신되지 않는다.
`initState`에서 `context.watch`를 부르면 예외가 난다.

`StatefulWidget`은 다음 경우에만 쓴다.

- `TextEditingController` · `AnimationController` 등 dispose가 필요할 때
- `initState`에서 1회 생성해야 하는 인스턴스가 있을 때

컨트롤러 자체의 dispose는 `ChangeNotifierProvider`가 처리하므로 그것 때문에 `StatefulWidget`을 쓰지 않는다.

### build 안에서 인스턴스 생성 금지

```dart
// 금지 — build는 자주 재실행된다
Widget build(BuildContext context) {
  final formatter = PriceFormatter(locale: 'ko');
  ...
}

// 권장
class _WatchlistRowState extends State<WatchlistRow> {
  late final PriceFormatter _formatter;

  @override
  void initState() {
    super.initState();
    _formatter = PriceFormatter(locale: 'ko');
  }
}
```

`context`·`MediaQuery` 같은 build 인자에 의존하는 객체는 예외다. 그건 build 안에 두는 게 맞다.

---

## 디자인 토큰

`lib/theme/`은 Figma 변수를 1:1로 옮긴 것이다. **값을 임의로 수정하지 않는다.**

```dart
// 금지
Container(color: const Color(0xFF0F0F0E), padding: const EdgeInsets.all(16))
Text('삼성전자', style: TextStyle(color: AppPalette.neutral0))   // 원시 팔레트 직접 참조

// 권장
Container(
  color: context.colors.surfaceBase,
  padding: EdgeInsets.all(context.dimens.space4),
)
Text('삼성전자', style: TextStyle(color: context.colors.textPrimary))
```

- 색상 hex를 화면 코드에 직접 쓰지 않는다.
- `AppPalette`를 화면에서 바로 참조하지 않는다. 반드시 `AppColors`(= `context.colors`)를 거친다.
- 토큰이 정말 없으면 추가해도 된다. **단 왜 추가했는지 README에 남긴다.**
- 글자 크기와 행간은 스타터 토큰(`AppTypography`)에 없다. `AppTextStyles`를 쓴다.
  - `AppTextStyles`는 Figma 텍스트 스타일을 그대로 옮긴 것이다. 화면에서 `fontSize`를 직접 적지 않는다.
  - 색은 들어 있지 않다. `AppTextStyles.body.copyWith(color: context.colors.textPrimary)` 형태로 조합한다.

### 등락 색상

국내 관행을 따른다. **상승은 빨강, 하락은 파랑.** 반대로 구현하지 않는다.

| 상태 | 텍스트 | 배경 | 차트 |
|---|---|---|---|
| 상승 | `priceUpText` | `priceUpBg` | `chartLineUp` |
| 하락 | `priceDownText` | `priceDownBg` | `chartLineDown` |
| 보합 | `priceFlatText` | `priceFlatBg` | `chartLineFlat` |

세 상태를 모두 처리한다. 보합(0%)을 빠뜨리지 않는다.

---

## 매직 넘버

의미 없는 큰 숫자로 우회하지 않는다.

```dart
// 금지
SizedBox(width: 9999)

// 권장
LayoutBuilder(builder: (context, constraints) => SizedBox(width: constraints.maxWidth, ...))
```

하드코딩이 불가피하면 named const로 뽑고 **왜 그 값인지** 주석을 단다.

```dart
/// 1년 탭 기준 거래일 245일 ÷ 페이지당 10일
const maxChartPage = 25;
```

---

## 로깅

**`print` 금지.** `LogUtil`을 쓴다.

```dart
LogUtil().logError('getAutoComplete: $e', module: _file);
LogUtil().logInfo('페이지 캐시 적중: $page', module: _file);
```

`catch` 블록에서 로깅만 하고 사용자 알림은 별도로 판단한다. 조용히 삼키지 않는다.

---

## 주석

- **기존 주석을 삭제하지 않는다.** 코드 변경에 맞게 수정하는 것은 가능하다.
- 주석은 한국어로 쓴다.
- 무엇을 하는지가 아니라 **왜 그렇게 했는지**를 적는다. 코드를 읽으면 아는 내용은 적지 않는다.
- Figma에 없어서 직접 판단한 부분은 주석에 근거를 남긴다. README 작성 때 그대로 쓴다.

```dart
// 시세 미수신 행은 정렬 시 항상 뒤로 보낸다. 0으로 취급하면 하락 종목과 섞여 오독된다.
```

---

## 비동기

- `Future`를 반환하는 메서드는 `Future<T>`로 반환 타입을 명시한다. (lint로 강제되지는 않으니 직접 챙긴다)
- `await`를 빠뜨리지 않는다. 의도적으로 기다리지 않으면 `unawaited()`로 표시한다.
- 화면이 사라진 뒤 `notifyListeners`가 불리지 않도록 `dispose`에서 리스너와 타이머를 정리한다.

---

## 금지 패턴 요약

| 금지 | 대안 |
|---|---|
| `setState` | `ChangeNotifier` + `Consumer` |
| `print` | `LogUtil` |
| `build` 안 인스턴스 생성 | `initState` + `late final` |
| 색상 hex 직접 입력 | `context.colors.*` |
| `AppPalette` 화면 직접 참조 | `context.colors.*` |
| 매직 넘버 (`9999`) | named const + 근거 주석 |
| repository record/tuple 반환 | 모델 또는 `bool` |
| Controller에서 raw json 접근 | repository에서 모델 변환 |
| 화면 전용 컨트롤러를 전역 provider에 등록 | 화면 위젯에 `ChangeNotifierProvider` |
| 이벤트 핸들러에서 `context.watch` | `context.read` |
| 컨트롤러 안에서 `context` 참조 | 생성자 주입 |
| `removeListener` 누락 | `dispose`에서 해제 |
| 종목별 개별 시세 호출 | 일괄 조회 1회 |
| 기존 주석 삭제 | 수정만 |

---

## 작성 후 확인

- [ ] `flutter analyze` 통과 (새 경고 0)
- [ ] 파일명과 최상위 클래스명 일치
- [ ] 디자인 토큰 우회 없음
- [ ] 상승 / 하락 / 보합 세 상태 처리
- [ ] 직접 판단한 부분에 근거 주석
