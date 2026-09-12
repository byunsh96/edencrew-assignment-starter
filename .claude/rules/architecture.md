# 아키텍처 규칙

레이어별 작성 규칙과 템플릿. 새 코드를 짜기 전에 해당 레이어 절을 읽는다.

---

## 1. View

`StatelessWidget`을 기본으로 한다. `StatefulWidget`은 `initState`에서 1회 생성해야 할 인스턴스가 있거나 `TextEditingController` 등 dispose가 필요할 때만 쓴다.

```dart
class WatchlistScreen extends StatelessWidget {
  WatchlistScreen({super.key});

  final _controller = Get.find<WatchlistController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: Column(
        children: [
          const WatchlistHeader(),        // 정적 구간은 const, Obx 밖
          Expanded(
            child: Obx(() {               // 반응 구간만 감싼다
              if (_controller.isLoading.value) return const WatchlistSkeleton();
              if (_controller.isEmpty.value) return const WatchlistEmpty();
              return ListView.builder(
                itemCount: _controller.items.length,
                itemBuilder: (context, index) => WatchlistRow(item: _controller.items[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}
```

규칙:

- **`Obx`는 반응이 필요한 구간만** 감싼다. `build` 전체를 감싸지 않는다.
- 컨트롤러는 위젯 필드에 `Get.find`로 잡는다. `build` 안에서 매번 찾지 않는다.
- 화면은 `views/screens/`, 부분 위젯은 `views/widgets/`에 둔다.
- 위젯 파일 하나에 최상위 public 위젯 하나. 파일명과 클래스명을 맞춘다.
- 색은 `context.colors.*`, 간격은 `context.dimens.*`로만 꺼낸다.
- 리스트 행처럼 반복되는 요소는 반드시 별도 위젯으로 분리한다.

---

## 2. Controller

`GetxController`를 상속하고, 공통 책임은 mixin으로 붙인다.

```dart
class WatchlistController extends GetxController {
  final _stockRepository = StockRepository();
  final _favoriteController = Get.find<FavoriteController>();

  final RxList<WatchlistItem> items = <WatchlistItem>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<WatchlistSort> sort = WatchlistSort.price.obs;

  RxBool get isEmpty => (items.isEmpty).obs;

  @override
  void onInit() {
    super.onInit();
    _bindFavorites();
    fetchQuotes();
  }

  /// 관심종목 시세를 한 번의 요청으로 조회한다.
  Future<void> fetchQuotes() async {
    isLoading.value = true;

    final symbols = _favoriteController.symbols;
    if (symbols.isEmpty) {
      items.clear();
      isLoading.value = false;
      return;
    }

    final quotes = await _stockRepository.getRealtimeQuotes(symbols);  // 일괄 조회
    items.value = _merge(symbols, quotes);
    isLoading.value = false;
  }
}
```

규칙:

- **Repository는 private 필드**로 잡는다. `final _stockRepository = StockRepository();`
- **다른 컨트롤러 참조는 `Get.find`**로 잡되, 순환 참조가 생기면 getter로 미룬다.
- 상태는 전부 `Rx*`로 노출한다. 외부에서 직접 대입하지 않도록 변경은 메서드로 감싼다.
- `onInit`에서 초기 로딩을 건다. 생성자에서 비동기 작업을 하지 않는다.
- 화면에 쓰이는 파생값은 getter로 만든다. View에서 계산하지 않는다.
- 공통 로직(정렬, 페이지 캐시 등)이 둘 이상의 컨트롤러에 필요해지면 **mixin으로 뽑는다.**

### 관심 상태 공유

관심 등록/해제는 세 화면이 같은 상태를 봐야 한다. 단일 컨트롤러를 `permanent`로 올리고 모든 화면이 참조한다.

```dart
// binding/initial_binding.dart
Get.put(FavoriteController(), permanent: true);
```

각 화면은 `Get.find<FavoriteController>()`로 같은 인스턴스를 본다. 화면별로 관심 목록을 복사해 들고 있지 않는다.

### 의존성 등록

`binding/initial_binding.dart`에서 일괄 등록한다.

| 대상 | 방식 |
|---|---|
| 앱 전역 서비스 · 공유 상태 | `Get.put(..., permanent: true)` |
| 화면 컨트롤러 | `Get.lazyPut(() => ..., fenix: true)` |
| Dialog · 일시적 위젯 컨트롤러 | 위젯 내부에서 `GetBuilder(init:)` |

Dialog에 `Get.put`을 쓰지 않는다. 닫혀도 인스턴스가 남는다.

---

## 3. Repository

도메인별로 클래스 하나. endpoint 하나당 메서드 하나.

```dart
class StockRepository {
  CoreRepository get _coreRepository => Get.find<CoreRepository>();   // 반드시 getter
  final _file = 'StockRepository';

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

- **`CoreRepository`는 반드시 getter로 참조한다.** 필드로 잡으면 등록 전에 평가될 수 있다.
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

`GetConnect`를 상속한다. 네이버 endpoint는 호스트가 서로 달라 **`baseUrl`을 설정하지 않고 전체 URL을 넘긴다.**

책임:

- 요청 수행과 `ApiResponse` 래핑
- 요청/응답 로깅 (`DevConfig`로 on/off)
- HTML 응답은 바이트를 받아 **EUC-KR 디코딩** 후 문자열로 반환 (`getHtml`)

`getHtml`은 `GetConnect`가 body를 UTF-8로 디코딩해 한글이 깨지므로 `http` 패키지로 직접 요청해 `bodyBytes`를 다룬다.

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
3. `domains/<도메인>/controllers/` — Rx 상태와 `onInit`
4. `binding/initial_binding.dart` — 등록
5. `domains/<도메인>/views/screens/` — 화면
6. `domains/<도메인>/views/widgets/` — 반복 요소 분리
7. `flutter analyze`
