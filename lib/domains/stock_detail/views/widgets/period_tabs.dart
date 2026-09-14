import 'package:edencrew_assignment_starter/widgets/app_ink_well.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../enums/chart_period.dart';

/// 기간 선택 칩. `1개월` / `3개월` / `6개월` / `1년`.
class PeriodTabs extends StatelessWidget {
  const PeriodTabs({required this.selected, required this.onChanged, super.key});

  /// Figma 칩 세로 여백.
  static const double _verticalPadding = 5;

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Row(
      spacing: dimens.space1,
      children: ChartPeriod.values.map((ChartPeriod period) {
        return Expanded(
          child: AppInkWell(
            onTap: () => onChanged(period),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: dimens.space3, vertical: _verticalPadding),
              decoration: BoxDecoration(
                color: period == selected ? colors.accentBg : null,
                borderRadius: BorderRadius.circular(dimens.radiusMd),
              ),
              child: Text(
                period.label,
                style: AppTextStyles.labelRegular.copyWith(
                  color: period == selected ? colors.accentDefault : colors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
