# mock 응답

네이버 endpoint는 호출이 잦으면 차단될 수 있어, 실제 응답을 저장해 두고
차단·5xx 시 대체 경로로 쓴다. (`docs/NAVER_API.md` 「네트워크가 막힐 때」)

| 파일 | endpoint | 인코딩 |
|---|---|---|
| `auto_complete.json` | 검색 자동완성 | UTF-8 |
| `realtime_quote.json` | 실시간 시세 | UTF-8 |
| `stock_meta.json` | 종목 메타데이터 | UTF-8 |
| `daily_quote.html` | 일별 시세 | **EUC-KR** |

## 종목명은 실제와 다르다

`삼성전자` 같은 실제 이름을 그대로 두면 화면만 보고 mock인지 실데이터인지 구분할 수 없다.
그래서 종목명만 가상 이름(`성훈전자`, `성훈하이닉스` …)으로 바꿔 두었다.
**종목코드·가격·날짜는 실제 응답 그대로**라 파싱 검증에는 영향이 없다.

화면에 `성훈`으로 시작하는 종목이 보이면 mock이 쓰이고 있다는 뜻이다.

## 켜고 끄기

`lib/constants/dev_config.dart`의 `useMockOnFailure`로 제어한다.
