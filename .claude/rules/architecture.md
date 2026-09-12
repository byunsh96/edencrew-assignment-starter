# 아키텍처 규칙

레이어별 작성 규칙과 템플릿. 새 코드를 짜기 전에 해당 레이어 절을 읽는다.

---

## 1. View

`StatelessWidget`을 기본으로 한다. `StatefulWidget`은 `initState`에서 1회 생성해야 할 인스턴스가 있거나 `TextEditingController` 등 dispose가 필요할 때만 쓴다.

```dart
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 전용 컨트롤러는 여기 붙인다. 화면이 사라지면 함께 dispose된다.
    return ChangeNotifierProvider<WatchlistController>(
      create: (BuildContext context) => WatchlistController(
        stockRepository: StockRepository(context.read<CoreRepository>()),
        favoriteController: context.read<FavoriteController>(),
      ),
      child: const WatchlistView(),
    );
  }
}

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: Column(
        children: <Widget>[
          const WatchlistHeader(),                    // 정적 구간은 const, Consumer 밖
          Expanded(
            child: Consumer<WatchlistController>(     // 갱신 구간만 감싼다
              builder: (BuildContext context, WatchlistController controller, _) {
                if (controller.isLoading) return const WatchlistSkeleton();
                if (controller.isEmpty) return const WatchlistEmpty();
                return ListView.builder(
                  itemCount: controller.items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      WatchlistRow(item: controller.items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

규칙:

- **`Consumer`는 갱신이 필요한 구간만** 감싼다. `build` 전체를 감싸지 않는다.
- 값을 읽기만 할 때는 `context.read<T>()`, 구독해야 할 때만 `Consumer`/`context.watch<T>()`를 쓴다.
  - `onTap` 같은 이벤트 핸들러에서 `watch`를 쓰지 않는다. 불필요한 리빌드가 생긴다.
- 필드 하나만 보면 되는 위젯은 `Selector<T, S>`로 리빌드 범위를 더 좁힌다.
- `ChangeNotifierProvider`는 **화면 위젯에 붙인다.** 전역에 올리는 것은 `FavoriteController`뿐이다.
- 화면은 `views/screens/`, 부분 위젯은 `views/widgets/`에 둔다.
- 위젯 파일 하나에 최상위 public 위젯 하나. 파일명과 클래스명을 맞춘다.
- 색은 `context.colors.*`, 간격은 `context.dimens.*`로만 꺼낸다.
- 리스트 행처럼 반복되는 요소는 반드시 별도 위젯으로 분리한다.

---

## 2. Controller

`ChangeNotifier`를 상속하고, 공통 책임은 mixin으로 붙인다.

```dart
class WatchlistController extends ChangeNotifier {
  WatchlistController({
    required StockRepository stockRepository,
    required FavoriteController favoriteController,
  })  : _stockRepository = stockRepository,
        _favoriteController = favoriteController {
    _favoriteController.addListener(_onFavoriteChanged);
    fetchQuotes();
  }

  final StockRepository _stockRepository;
  final FavoriteController _favoriteController;

  List<WatchlistItem> _items = <WatchlistItem>[];
  bool _isLoading = true;
  WatchlistSort _sort = WatchlistSort.price;

  List<WatchlistItem> get items => List<WatchlistItem>.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  WatchlistSort get sort => _sort;

  /// 관심종목 시세를 한 번의 요청으로 조회한다.
  Future<void> fetchQuotes() async {
    _isLoading = true;
    notifyListeners();

    final List<String> symbols = _favoriteController.symbols;
    if (symbols.isEmpty) {
      _items = <WatchlistItem>[];
      _isLoading = false;
      notifyListeners();
      return;
    }

    final List<StockQuote> quotes =
        await _stockRepository.getRealtimeQuotes(symbols);   // 일괄 조회
    _items = _merge(symbols, quotes);
    _isLoading = false;
    notifyListeners();
  }

  void _onFavoriteChanged() => fetchQuotes();

  @override
  void dispose() {
    _favoriteController.removeListener(_onFavoriteChanged);
    super.dispose();
  }
}
```

규칙:

- **의존성은 생성자로 주입한다.** 컨트롤러 안에서 `context`를 읽지 않는다. 테스트에서 교체가 가능해진다.
- **상태 필드는 private, 읽기는 getter**로 노출한다. 외부에서 직접 대입하지 못하게 한다.
  - 리스트는 `unmodifiable`로 감싸 View가 원본을 건드리지 못하게 한다.
- **상태를 바꾼 뒤 `notifyListeners()`를 부른다.** 연속으로 바꿀 때는 마지막에 한 번만 부른다.
- 초기 로딩은 **생성자**에서 건다. `ChangeNotifier`에는 `onInit`이 없다.
- 다른 컨트롤러를 구독하면 **`dispose`에서 반드시 `removeListener`** 한다. 빠뜨리면 화면을 나간 뒤에도 호출된다.
- 화면에 쓰이는 파생값은 getter로 만든다. View에서 계산하지 않는다.
- 공통 로직(정렬, 페이지 캐시 등)이 둘 이상의 컨트롤러에 필요해지면 **mixin으로 뽑는다.**

### 관심 상태 공유

관심 등록/해제는 세 화면이 같은 상태를 봐야 한다. 유일하게 전역에 올리는 컨트롤러다.

```dart
// binding/app_providers.dart
ChangeNotifierProvider<FavoriteController>(create: (_) => FavoriteController()),
```

각 화면은 `context.read<FavoriteController>()`로 같은 인스턴스를 본다.
화면별로 관심 목록을 복사해 들고 있지 않는다.

### 의존성 등록

| 대상 | 방식 | 위치 |
|---|---|---|
| 앱 전역 서비스 (`CoreRepository`) | `Provider` + `dispose` | `AppProviders.global` |
| 공유 상태 (`FavoriteController`) | `ChangeNotifierProvider` | `AppProviders.global` |
| 화면 컨트롤러 | `ChangeNotifierProvider` | 해당 **화면 위젯** |
| Dialog · 바텀시트 전용 상태 | `StatefulWidget` 지역 상태 또는 `ChangeNotifierProvider.value` | 해당 위젯 |

**전역에 올리는 것은 `CoreRepository`와 `FavoriteController` 둘뿐이다.**
화면 하나에서만 쓰는 컨트롤러를 전역에 올리지 않는다. 화면을 나가도 살아남아 상태가 남는다.

바텀시트·다이얼로그는 상위 트리와 분리된 route라 provider를 상속받지 못한다.
값을 넘겨야 하면 `ChangeNotifierProvider.value`로 명시적으로 전달한다.

## 3. Repository

도메인별로 클래스 하나. endpoint 하나당 메서드 하나.

```dart
class StockRepository {
  StockRepository(this._coreRepository);   // 생성자 주입

  final CoreRepository _coreRepository;
  static const String _file = 'StockRepository';

  //GET https://ac.stock.naver.com/ac (검색 자동완성)
  Future<List<StockSearchItem>> getAutoComplete(String keyword) async {
    try {
      final response = await _coreRepository.getData(
        NaverApi.autoComplete,
        query: {'q': keyword, 'target': 'stock,ipo,index,marketindicator'},
      );

      if (response.data == null) return [];

      return StockSearchItem.listFromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      LogUtil().logError('getAutoComplete: $e', module: _file);
    }
    return [];
  }
}
```

규칙:

- **`CoreRepository`는 생성자로 주입받는다.** Repository는 `context`를 모른다. 컨트롤러가 만들어 넘긴다.
- 메서드 위에 `//GET <url> (설명)` 주석으로 endpoint를 명시한다.
- 조회는 모델 또는 `List<T>` 반환, 변경은 `bool` 반환. **record/tuple 반환은 쓰지 않는다.**
- `try/catch` + `LogUtil().logError('메서드명: $e', module: _file)` 후 빈 값으로 fallback한다.
- **URL 문자열을 메서드 안에 직접 쓰지 않는다.** `constants/naver_api.dart`에 상수로 모은다.
- 응답 → 모델 변환은 repository가 책임진다. Controller가 raw json을 보지 않는다.

### 페이지 캐시

일별 시세는 페이지 단위로 받아 재사용한다. 이미 받은 페이지를 다시 요청하지 않는다.

```dart
final Map<String, Map<int, List<DailyQuote>>> _dailyCache = {};   // symbol -> page -> rows

Future<List<DailyQuote>> getDailyQuotes(String symbol, {required int page}) async {
  final cached = _dailyCache[symbol]?[page];
  if (cached != null) return cached;
  ...
}
```

`lastPage`보다 큰 페이지를 요청하지 않는다.

---

## 4. CoreRepository

`Dio`를 감싼 일반 클래스다. 네이버 endpoint는 호스트가 서로 달라 **`baseUrl`을 설정하지 않고 전체 URL을 넘긴다.**

책임:

- 요청 수행과 `ApiResponse` 래핑
- 요청/응답 로깅 (`DevConfig`로 on/off)
- HTML 응답은 바이트를 받아 **EUC-KR 디코딩** 후 문자열로 반환 (`getHtml`)

### 인코딩

**endpoint마다 인코딩이 다르다.** JSON이라고 UTF-8인 것이 아니다.

| endpoint | Content-Type |
|---|---|
| `ac.stock.naver.com` | (헤더 없음 → UTF-8) |
| `polling.finance.naver.com` | `text/plain;charset=EUC-KR` — **JSON인데 EUC-KR** |
| `stock.naver.com` | `application/json; charset=utf-8` |
| `finance.naver.com` | `text/html;charset=EUC-KR` |

그래서 `getData`와 `getHtml` 모두 `ResponseType.bytes`로 원문을 받고,
응답 헤더의 charset을 보고 디코딩한다. 실시간 시세를 UTF-8로 읽으면 종목명이 깨진다.

디코딩은 `cp949_codec`의 `cp949`를 쓴다. CP949는 EUC-KR의 상위 호환이고 순수 Dart라
네이티브 플러그인이 필요 없다. 덕분에 기기 없이 `flutter test`에서도 파싱을 검증할 수 있다.

> `charset` 패키지(2.0.1)는 쓰지 않는다. `eucKrToUtf8`과 `utf8ToEucKr` 테이블의 이름이
> 뒤바뀌어 있어 인코딩·디코딩 양방향이 모두 깨진다. (`삼성전자` → `鋱鏋飜飅`)

### 기타

`validateStatus`를 항상 `true`로 두어 4xx·5xx를 예외로 던지지 않고 `ApiResponse.statusCode`에 담는다.
`finance.naver.com`은 기본 User-Agent로는 응답하지 않는 경우가 있어 브라우저 UA를 붙인다.

---

## 5. Model

```dart
class StockQuote implements HasSymbol {
  @override
  final String symbol;
  final int currentPrice;
  final int previousClose;

  const StockQuote({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: ParseUtil.parse<String>(json, 'cd'),
      currentPrice: ParseUtil.parse<int>(json, 'nv'),
      previousClose: ParseUtil.parse<int>(json, 'pcv'),
    );
  }

  int get change => currentPrice - previousClose;
  double get changeRate => previousClose == 0 ? 0 : change / previousClose;
  PriceDirection get direction => PriceDirection.of(change);
}
```

규칙:

- 필드는 `final`, 생성자는 가능하면 `const`.
- **`fromJson`은 `ParseUtil.parse<T>(json, 'key')`로 필드별 안전 파싱**한다. 키 누락·타입 불일치로 전체가 터지지 않게 한다.
- 중첩 리스트 파싱은 개별 `try/catch`로 감싸고 실패 시 빈 리스트로 fallback한다.
- 계산 파생값(등락액, 등락률, 시가총액)은 **모델의 getter**로 둔다. View나 Controller에서 계산하지 않는다.
- 표시용 포맷(`-400 (-0.22%)`, `29,113천`, `1,063조`)은 **extension이나 `FormatUtil`**로 분리한다. 모델 본체에 두지 않는다.
- API 응답 DTO와 화면 모델의 필드가 크게 다르면 나눈다. 같으면 굳이 나누지 않는다.

---

## 6. 새 도메인 추가 순서

1. `domains/<도메인>/models/` — 모델과 `fromJson`
2. `domains/<도메인>/repository/` — endpoint 메서드
3. `domains/<도메인>/controllers/` — `ChangeNotifier` 상태와 생성자 초기 로딩
4. `binding/app_providers.dart` — 전역만 등록 (화면 컨트롤러는 화면 위젯에 붙인다)
5. `domains/<도메인>/views/screens/` — 화면
6. `domains/<도메인>/views/widgets/` — 반복 요소 분리
7. `flutter analyze`
