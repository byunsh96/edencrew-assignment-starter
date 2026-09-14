import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../enums/price_direction.dart';
import '../../../../theme/theme.dart';
import '../../models/daily_quote_model.dart';

/// 일별 시세를 캔들로 그린다.
class CandleChart extends StatelessWidget {
  const CandleChart({required this.quotes, super.key});

  /// Figma 차트 영역 높이.
  static const double height = 200;

  final List<DailyQuoteModel> quotes;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _CandlePainter(
          // 왼쪽이 과거가 되도록 뒤집는다. 응답은 최신순이다.
          quotes: quotes.reversed.toList(growable: false),
          upColor: colors.chartLineUp,
          downColor: colors.chartLineDown,
          flatColor: colors.chartLineFlat,
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  const _CandlePainter({
    required this.quotes,
    required this.upColor,
    required this.downColor,
    required this.flatColor,
  });

  /// 캔들 사이 간격이 차지하는 비율. 나머지가 몸통 너비가 된다.
  static const double _gapRatio = 0.25;

  /// 몸통이 너무 얇아 보이지 않는 것을 막는 최소 너비.
  static const double _minBodyWidth = 1;

  /// 고가와 저가가 같은 종목(상한가 등)에서 0으로 나누는 것을 막는 여유값.
  static const double _minPriceRange = 1;

  final List<DailyQuoteModel> quotes;
  final Color upColor;
  final Color downColor;
  final Color flatColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (quotes.isEmpty) return;

    double highest = quotes.first.highPrice.toDouble();
    double lowest = quotes.first.lowPrice.toDouble();
    for (final DailyQuoteModel quote in quotes) {
      highest = math.max(highest, quote.highPrice.toDouble());
      lowest = math.min(lowest, quote.lowPrice.toDouble());
    }

    final double range = math.max(highest - lowest, _minPriceRange);
    final double slotWidth = size.width / quotes.length;
    final double bodyWidth = math.max(slotWidth * (1 - _gapRatio), _minBodyWidth);

    double toY(num price) => size.height * (highest - price) / range;

    for (int i = 0; i < quotes.length; i++) {
      final DailyQuoteModel quote = quotes[i];
      final double centerX = slotWidth * (i + 0.5);
      final Paint paint = Paint()
        ..color = switch (quote.candleDirection) {
          PriceDirection.up => upColor,
          PriceDirection.down => downColor,
          PriceDirection.flat => flatColor,
        };

      // 고가 - 저가 꼬리
      canvas.drawLine(
        Offset(centerX, toY(quote.highPrice)),
        Offset(centerX, toY(quote.lowPrice)),
        paint..strokeWidth = math.max(bodyWidth * 0.15, 0.5),
      );

      // 시가 - 종가 몸통. 두 값이 같으면 선으로 보이도록 최소 높이를 준다.
      final double openY = toY(quote.openPrice);
      final double closeY = toY(quote.closePrice);
      final double top = math.min(openY, closeY);
      final double bottom = math.max(openY, closeY);

      canvas.drawRect(
        Rect.fromLTRB(
          centerX - bodyWidth / 2,
          top,
          centerX + bodyWidth / 2,
          math.max(bottom, top + 0.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CandlePainter oldDelegate) =>
      oldDelegate.quotes != quotes || oldDelegate.upColor != upColor;
}
