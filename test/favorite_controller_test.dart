import 'package:edencrew_assignment_starter/domains/favorite_list/controllers/favorite_controller.dart';
import 'package:edencrew_assignment_starter/models/favorite_stock.dart';
import 'package:flutter_test/flutter_test.dart';

/// 관심 상태는 세 화면이 공유하므로 어긋나면 안 된다.
void main() {
  const FavoriteStock samsung = FavoriteStock(
    symbol: '005930',
    name: '삼성전자',
    marketName: '코스피',
  );

  late FavoriteController controller;
  late int notifyCount;

  setUp(() {
    controller = FavoriteController();
    notifyCount = 0;
    controller.addListener(() => notifyCount++);
  });

  tearDown(() => controller.dispose());

  test('처음에는 비어 있다', () {
    expect(controller.isEmpty, isTrue);
    expect(controller.symbols, isEmpty);
  });

  test('toggle은 등록 여부를 돌려주고 상태를 알린다', () {
    expect(controller.toggle(samsung), isTrue); // 등록
    expect(controller.contains('005930'), isTrue);
    expect(notifyCount, 1);

    expect(controller.toggle(samsung), isFalse); // 해제
    expect(controller.contains('005930'), isFalse);
    expect(notifyCount, 2);
  });

  test('등록 시 이름과 거래소명을 함께 보관한다', () {
    controller.toggle(samsung);

    final FavoriteStock stored = controller.items.single;
    expect(stored.name, '삼성전자');
    expect(stored.symbolWithMarket, '005930 · 코스피');
  });

  test('같은 종목은 중복 등록되지 않는다', () {
    controller.toggle(samsung);
    controller.toggle(
      const FavoriteStock(symbol: '005930', name: '삼성전자', marketName: '코스피'),
    );

    expect(controller.items, isEmpty); // 두 번째 toggle은 해제로 동작한다
  });

  test('items는 외부에서 수정할 수 없다', () {
    controller.toggle(samsung);

    expect(
      () => controller.items.add(samsung),
      throwsUnsupportedError,
    );
  });

  test('remove는 등록되지 않은 종목에 대해 알리지 않는다', () {
    controller.remove('000660');
    expect(notifyCount, 0);

    controller.toggle(samsung);
    controller.remove('005930');
    expect(controller.isEmpty, isTrue);
    expect(notifyCount, 2);
  });
}
