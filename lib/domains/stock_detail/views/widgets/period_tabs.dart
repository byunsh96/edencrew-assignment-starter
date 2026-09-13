import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../enums/chart_period.dart';

//TODO 리뷰 확인

/// 기간 선택 칩. `1개월` / `3개월` / `6개월` / `1년`.
class PeriodTabs extends StatelessWidget {
  const PeriodTabs({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// Figma 칩 세로 여백.
  static const double _verticalPadding = 5;

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Row(
      children: <Widget>[
        for (final ChartPeriod period in ChartPeriod.values) ...<Widget>[
          if (period != ChartPeriod.values.first)
            SizedBox(width: dimens.space1),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(period),
              borderRadius: BorderRadius.circular(dimens.radiusMd),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: dimens.space3,
                  vertical: _verticalPadding,
                ),
                decoration: BoxDecoration(
                  color: period == selected ? colors.accentBg : null,
                  borderRadius: BorderRadius.circular(dimens.radiusMd),
                ),
                child: Text(
                  period.label,
                  style: AppTextStyles.labelRegular.copyWith(
                    color: period == selected
                        ? colors.accentDefault
                        : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
