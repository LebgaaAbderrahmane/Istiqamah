import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';
import '../../widgets/heatmap_cell.dart';
import '../../widgets/day_detail_sheet.dart';
import '../../widgets/empty_state_widget.dart';
import '../../logic/heatmap_aggregator.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              AppDateUtils.formatMonthYear(controller.currentMonth.value),
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildMonthNavigator(),
            _buildWeekdayHeaders(),
            Expanded(child: _buildGrid()),
          ],
        );
      }),
    );
  }

  Widget _buildMonthNavigator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.prevMonth,
          ),
          Text(
            AppDateUtils.formatMonthYear(controller.currentMonth.value),
            style: AppTextStyles.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: weekdays.map((d) {
          return Expanded(
            child: Center(
              child: Text(
                d,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final completions = controller.completions;
    if (completions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_view_month,
        message: 'No data for this month.',
      );
    }

    final firstDay = completions.first.date;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + completions.length;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: rows * 7,
        itemBuilder: (context, index) {
          final dayIndex = index - startWeekday;
          if (dayIndex < 0 || dayIndex >= completions.length) {
            return const SizedBox.shrink();
          }
          final day = completions[dayIndex];
          final isToday = AppDateUtils.isSameDay(day.date, DateTime.now());

          return HeatmapCell(
            bucket: day.bucket,
            isToday: isToday,
            onTap: () => _showDayDetail(day),
          );
        },
      ),
    );
  }

  void _showDayDetail(DayCompletion day) {
    controller.selectDay(day);
    Get.bottomSheet(DayDetailSheet(day: day));
  }
}
