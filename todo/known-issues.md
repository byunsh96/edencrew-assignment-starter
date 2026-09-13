# 알려진 문제

---

## 1. VS Code 테스트가 chrome에서 돌아 실패한다

- [ ] 미착수 · **우선순위 높음**

**대상** `.vscode/settings.json`

```json
"dart.flutterTestAdditionalArgs": ["--platform", "chrome"]
```

이 설정 때문에 VS Code에서 테스트를 돌리면 **`dart:io`를 쓰는 테스트가 전부 실패**합니다.
`assets/mock/`의 저장된 응답을 `File`로 읽는데 웹에는 `dart:io`가 없습니다.

| 파일 | 상태 |
| --- | --- |
| `test/parsing_test.dart` | 5건 실패 |
| `test/page_cache_test.dart` | 실패 |
| `test/watchlist_sort_test.dart` | 실패 |

터미널에서 `fvm flutter test`로 돌리면 전부 통과합니다.

**선택지**

1. 설정에서 `--platform chrome`을 제거한다 (가장 간단)
2. 파일 읽기를 `rootBundle.load()`로 바꿔 웹에서도 돌게 한다
   - `pubspec.yaml`의 `assets:`에 이미 `assets/mock/`이 등록되어 있어 가능
   - 다만 테스트마다 `TestWidgetsFlutterBinding.ensureInitialized()`가 필요해진다

---

## 2. EUC-KR mock 파일이 에디터 저장으로 손상된다

- [x] 1차 복구 완료 · **재발 주의**

`assets/mock/realtime_quote.json`과 `daily_quote.html`은 **EUC-KR 원문**입니다.
에디터가 UTF-8로 다시 저장하면 한글 바이트가 `U+FFFD`로 바뀌어 복구가 불가능합니다.

실제로 `13687d0 [fix] lint 정리 및 파일 폴더 이동`에서 `realtime_quote.json`이 손상됐고,
`parsing_test.dart`가 `삼성전자` 대신 `占쏙성占쏙옙占쏙옙`을 받아 실패했습니다.
`1698b6b`에서 복구했습니다.

**예방**

- 두 파일은 **에디터로 열지 않습니다.** 내용 확인이 필요하면 터미널에서 디코딩해서 봅니다.
  ```bash
  python3 -c "print(open('assets/mock/daily_quote.html', encoding='euc-kr').read()[:500])"
  ```
- 포맷터가 건드리지 않도록 `.vscode/settings.json`에 `files.autoSave`가 켜져 있는 점을 유의합니다.
- 손상 여부는 아래로 확인합니다.
  ```bash
  grep -c $'\xef\xbf\xbd' assets/mock/realtime_quote.json   # 0이어야 정상
  ```

---

## 3. 시뮬레이터 화면 확인이 불안정하다

- [ ] 참고용

`xcrun simctl io booted screenshot`이 검은 화면만 캡처하는 경우가 있습니다.
시뮬레이터 디스플레이가 절전에 들어가면 발생하며, `open -a Simulator`로 깨운 뒤 다시 찍으면 됩니다.

`Lost connection to device`로 Dart 격리가 멈춰 스피너가 고정되는 경우도 있었습니다.
앱 문제가 아니라 도구 문제이므로 `flutter run`을 다시 띄우면 해결됩니다.

---

## 4. 파일 이동 후 핫 리로드가 깨진다

- [ ] 참고용

파일을 옮기거나 이름을 바꾼 뒤 **핫 리로드(`r`)** 를 하면 이런 에러가 납니다.

```
_CompileTimeError: Lookup failed: _currentIndex ... in _MainScreenState
  at StatefulElement.unmount
```

실행 중인 앱에 살아 있는 옛 `State` 인스턴스를 정리하려는데 새 코드에 해당 클래스가 없어서 납니다.
**핫 리스타트(`R`)** 를 쓰면 해결됩니다.

파일 이동 · 이름 변경 · 클래스 추가/삭제 뒤에는 `r`이 아니라 `R`을 씁니다.

---

## 5. 실제 기기 확인이 남았다

- [ ] 미착수

iOS 18.5 시뮬레이터(iPhone 16)에서만 확인했습니다.
Android 에뮬레이터와 실제 기기는 확인하지 못했습니다.
