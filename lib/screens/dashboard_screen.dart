import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../models/job_application_model.dart';
import '../utils/app_theme.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          return CustomScrollView(
            slivers: [
              // Sticky App Bar using SliverAppBar
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 70,
                collapsedHeight: 70,
                toolbarHeight: 70,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: _DashboardAppBarContent(isDark: isDark),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatsCard(
                                  title: 'TOTAL APPLIED',
                                  value: jobProvider.totalJobs.toString(),
                                  subtitle: '+12%',
                                  subtitleColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatsCard(
                                  title: 'INTERVIEWS',
                                  value: jobProvider.interviewCount.toString(),
                                  subtitle: _getInterviewRate(jobProvider),
                                  hasAccentBar: true,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatsCard(
                                  title: 'OFFERS REC.',
                                  value: jobProvider.offerCount.toString(),
                                  subtitle: 'Active',
                                  subtitleColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatsCard(
                                  title: 'AVG. RESPONSE',
                                  value: '6.2',
                                  subtitle: 'Days',
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Application Funnel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ApplicationFunnel(
                        total: jobProvider.totalJobs,
                        applied: jobProvider.appliedCount,
                        interview: jobProvider.interviewCount,
                        offer: jobProvider.offerCount,
                        rejected: jobProvider.rejectedCount,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Monthly Activity
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _MonthlyActivity(
                        jobs: jobProvider.jobs,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Application Trend
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ApplicationTrend(
                        jobs: jobProvider.jobs,
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getInterviewRate(JobProvider provider) {
    if (provider.totalJobs == 0) return '0%';
    final rate = (provider.interviewCount / provider.totalJobs * 100);
    return '${rate.toStringAsFixed(1)}%';
  }
}

class _DashboardAppBarContent extends StatelessWidget {
  final bool isDark;

  const _DashboardAppBarContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            Row(
              children: [
                // Notification Bell
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                      size: 22,
                    ),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Profile Avatar
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.firebaseUser;
                    final photoUrl = user?.photoURL;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                ),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Center(
      child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;
  final bool hasAccentBar;
  final bool isDark;

  const _StatsCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.hasAccentBar = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent bar on left side
          if (hasAccentBar)
            Positioned(
              left: -20,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                      height: 1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              subtitleColor ??
                              (isDark ? Colors.white60 : Colors.black54),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationFunnel extends StatelessWidget {
  final int total;
  final int applied;
  final int interview;
  final int offer;
  final int rejected;
  final bool isDark;

  const _ApplicationFunnel({
    required this.total,
    required this.applied,
    required this.interview,
    required this.offer,
    required this.rejected,
    required this.isDark,
  });

  double _getInterviewRate() {
    if (total == 0) return 0;
    return (interview / total * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Funnel',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interview Rate',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'export', child: Text('Export Data')),
                  PopupMenuItem(value: 'details', child: Text('View Details')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(140, 140),
                      painter: _DonutChartPainter(
                        applied: applied,
                        interview: interview,
                        offer: offer,
                        rejected: rejected,
                        total: total,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_getInterviewRate().toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Interview Rate',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: AppColors.statusApplied,
                      label: 'Applied',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.statusInterview,
                      label: 'Interview',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.primaryBlue,
                      label: 'Offer',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.statusRejected,
                      label: 'Rejected',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final int applied;
  final int interview;
  final int offer;
  final int rejected;
  final int total;

  _DonutChartPainter({
    required this.applied,
    required this.interview,
    required this.offer,
    required this.rejected,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) {
      // Draw a gray circle if no data
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0
        ..color = Colors.grey.withOpacity(0.3);

      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        (size.width / 2) - 10,
        paint,
      );
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    final strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const double pi = 3.14159265359;
    double startAngle = -pi / 2; // Start at top (12 o'clock)

    // Draw each segment with a tiny gap for visual separation
    final segments = [
      {'count': applied, 'color': AppColors.statusApplied},
      {'count': interview, 'color': AppColors.statusInterview},
      {'count': offer, 'color': AppColors.primaryBlue},
      {'count': rejected, 'color': AppColors.statusRejected},
    ];

    for (var segment in segments) {
      final count = segment['count'] as int;
      if (count == 0) continue;

      final sweepAngle = (count / total) * 2 * pi;
      paint.color = segment['color'] as Color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MonthlyActivity extends StatelessWidget {
  final List<JobApplicationModel> jobs;
  final bool isDark;

  const _MonthlyActivity({required this.jobs, required this.isDark});

  Map<String, int> _getMonthlyData() {
    final now = DateTime.now();
    final months = <String, int>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = _getMonthName(month.month);
      months[monthKey] = 0;
    }

    for (var job in jobs) {
      final date = job.createdAt;
      final monthKey = _getMonthName(date.month);
      if (months.containsKey(monthKey)) {
        months[monthKey] = months[monthKey]! + 1;
      }
    }

    return months;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  int _getCurrentMonthCount() {
    final now = DateTime.now();
    return jobs
        .where(
          (job) =>
              job.createdAt.year == now.year &&
              job.createdAt.month == now.month,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();
    final currentMonth = _getCurrentMonthCount();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '$currentMonth this month',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Last 6 months',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '+15%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.entries.map((entry) {
                final maxValue = monthlyData.values.reduce(
                  (a, b) => a > b ? a : b,
                );
                final heightRatio = maxValue > 0 ? entry.value / maxValue : 0;
                final barHeight = maxValue > 0
                    ? (100 * heightRatio).clamp(2.0, 100.0).toDouble()
                    : 2.0;
                final now = DateTime.now();
                final currentMonthName = _getMonthName(now.month);
                final isCurrentMonth = entry.key == currentMonthName;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isCurrentMonth
                              ? AppColors.primaryBlue
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentMonth
                              ? AppColors.primaryBlue
                              : (isDark ? Colors.white60 : Colors.black54),
                          fontWeight: isCurrentMonth
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationTrend extends StatelessWidget {
  final List<JobApplicationModel> jobs;
  final bool isDark;

  const _ApplicationTrend({required this.jobs, required this.isDark});

  List<double> _getTrendData() {
    // Generate sample trend data based on last 12 weeks
    final data = <double>[];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final count = jobs
          .where((job) {
            return job.createdAt.isAfter(weekStart) &&
                job.createdAt.isBefore(weekEnd);
          })
          .length
          .toDouble();

      data.add(count);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final trendData = _getTrendData();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Trend',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Trending Up',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'This Year',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '+8%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _LineChartPainter(
                data: trendData,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y =
          size.height -
          (normalizedValue * size.height * 0.8) -
          (size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw fill area
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
