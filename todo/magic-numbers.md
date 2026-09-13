# 매직 넘버 정리

`.claude/rules/coding-convention.md`의 **매직 넘버 금지** 규칙 기준으로 훑은 결과입니다.
하드코딩이 불가피하면 named const로 뽑고 **왜 그 값인지** 주석을 답니다.

---

## 1. 탭 인덱스 — `0` / `1`

- [x] 완료

**대상**

- `lib/widgets/app_tab_bar.dart`
- `lib/domains/home/home_screen.dart`

**문제**

```dart
icon: currentIndex == 0 ? AppIcons.starFill : AppIcons.star,
isSelected: currentIndex == 1,
final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
```

숫자만으로는 어느 탭인지 알 수 없었습니다. 더 큰 문제는 `IndexedStack`의 `children` 순서와
인덱스가 **암묵적으로 결합**되어 있던 점입니다. 탭을 하나 추가하면 세 군데를 동시에 맞춰야 했습니다.

**처리**

`lib/enums/main_tab.dart`에 `MainTab`을 두고 `switch`로 화면과 아이콘을 매핑했습니다.
enum에 값을 추가하면 컴파일러가 빠진 분기를 잡아줍니다.

---

## 2. 토스트의 인라인 숫자

- [~] 일부 완료 — 탭 바 높이 의존 제거됨. 나머지는 미착수

### 완료: 탭 바 높이 의존 (`AppTabBar.height = 63`)

```dart
bottom: MediaQuery.paddingOf(context).bottom + AppTabBar.height + dimens.space3,
```

토스트가 자기 아래에 무엇이 얼마나 있는지 직접 계산하고 있었습니다.
63은 토큰에서 나오는 값(8×2 + 4×2 + 22 + 3 + 14)을 손으로 적어둔 것이라
토큰이 바뀌면 조용히 어긋납니다.

더 큰 문제는 **탭 바가 없는 상세 화면에서도 63을 더해 토스트가 63px 위에 떴다**는 점입니다.

`AppToastScope`(내부 `Overlay`)를 두고 `Overlay.of(context)`가 가장 가까운 것을 찾게 했습니다.
토스트에는 `bottom: dimens.space3` 한 줄만 남고 `AppTabBar.height`는 삭제했습니다.

### 남은 것

```dart
vertical: 14,                  // Figma 토스트 세로 여백
blurRadius: 24,
offset: Offset(0, 8),
color: Color(0x8C000000),      // rgba(0, 0, 0, 0.55)
```

**대상** `lib/widgets/app_toast.dart`

```dart
vertical: 14,                  // Figma 토스트 세로 여백
blurRadius: 24,
offset: Offset(0, 8),
color: Color(0x8C000000),      // rgba(0, 0, 0, 0.55)
```

다른 위젯은 `static const`로 뽑아뒀는데 여기만 빠졌습니다.
`Color(0x8C000000)`은 **색상 hex 직접 입력 금지 규칙 위반**이기도 합니다.

`AppColors`는 스타터 원본이라 수정할 수 없으므로, `AppTextStyles`처럼
`lib/constants/`에 새 파일을 만들어 그림자를 빼내는 방식을 검토합니다.

---

## 3. `dimens.space1 / 2`

- [ ] 미착수

**대상** (4곳)

- `lib/domains/watchlist/views/widgets/watchlist_row.dart` (3곳)
- `lib/domains/search/views/widgets/search_result_row.dart` (1곳)

```dart
SizedBox(height: dimens.space1 / 2)   // = 2
```

Figma의 `gap: 2`인데 `AppDimens`에 2가 없어 나눗셈으로 만들었습니다.
**"왜 절반인가"가 코드에 드러나지 않습니다.** 이름 있는 상수로 뽑거나 토큰 추가를 검토합니다.

---

## 4. 일별 시세 표의 열 인덱스

- [ ] 미착수

**대상** `lib/domains/stock_detail/models/daily_quote_page.dart`

```dart
if (cells.length != 7) continue;
closePrice: _number(cells[1]),
openPrice:  _number(cells[3]),
highPrice:  _number(cells[4]),
lowPrice:   _number(cells[5]),
```

`cells[3]`이 시가인지 고가인지 코드만 봐선 모릅니다.
네이버가 열 순서를 바꾸면 **예외 없이 조용히 틀린 값**이 들어갑니다.

열 이름을 enum이나 named const로 두면 의미가 드러나고, 열 개수 검사도 한곳에서 관리됩니다.

---

## 5. 캔들 차트의 남은 숫자

- [ ] 미착수

**대상** `lib/domains/stock_detail/views/widgets/candle_chart.dart`

```dart
paint..strokeWidth = math.max(bodyWidth * 0.15, 0.5),
math.max(bottom, top + 0.5),
```

`_gapRatio`와 `_minBodyWidth`는 뽑아뒀는데 꼬리 두께 비율(`0.15`)과
최소 몸통 높이(`0.5`)는 남았습니다.

---

## 매직 넘버가 아니라고 판단한 것

고치지 않습니다. 판단 근거를 남겨 다시 훑을 때 중복 검토를 피합니다.

| 위치 | 값 | 근거 |
| --- | --- | --- |
| `core_repository.dart`, `api_response.dart` | `200`, `300` | HTTP 상태 코드 표준 |
| `daily_quote_page.dart` | `date.length != 8` | `yyyyMMdd` 형식 길이 |
| `stock_detail_controller.dart` | `page = 1`, `page = 2` | 페이지 번호 그 자체 |
| 여러 위젯 | `maxLines: 1` | Flutter 관용 표현 |
| `app_text_styles.dart` | `36 / 30`, `22 / 19` | Figma 값을 그대로 적어 의도가 드러남 |
