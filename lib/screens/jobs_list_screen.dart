import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job_application_model.dart';
import '../utils/app_theme.dart';
import 'job_detail_screen.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JobApplicationModel> _filterJobs(List<JobApplicationModel> jobs) {
    var filtered = jobs;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        return job.companyName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            job.jobTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by stage
    if (_selectedFilter != 'All') {
      filtered = filtered.where((job) {
        switch (_selectedFilter) {
          case 'Applied':
            return job.stage == ApplicationStage.applied;
          case 'Called':
            return job.stage == ApplicationStage.interviewCalled;
          case 'Interviewed':
            return job.stage == ApplicationStage.interviewed;
          case 'Offer':
            return job.stage == ApplicationStage.offer;
          case 'Rejected':
            return job.stage == ApplicationStage.rejected;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          final filteredJobs = _filterJobs(jobProvider.jobs);
          final activeJobsCount = jobProvider.jobs
              .where(
                (job) =>
                    job.stage != ApplicationStage.rejected &&
                    job.stage != ApplicationStage.offer &&
                    job.stage != ApplicationStage.interested,
              )
              .length;

          return GestureDetector(
            onTap: () {
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                });
                FocusScope.of(context).unfocus();
              }
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: _isSearching ? 150 : 130,
                  collapsedHeight: _isSearching ? 150 : 130,
                  toolbarHeight: _isSearching ? 150 : 130,
                  backgroundColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Applications',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$activeJobsCount active jobs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildIconButton(
                                    icon: Icons.search,
                                    isDark: isDark,
                                    isActive: _isSearching,
                                    onTap: () {
                                      setState(() {
                                        _isSearching = !_isSearching;
                                        if (!_isSearching) {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildIconButton(
                                    icon: Icons.tune,
                                    isDark: isDark,
                                    isActive:
                                        jobProvider.showDraftsOnly ||
                                        jobProvider.sortBy != 'updatedAt',
                                    onTap: () {
                                      _showFilterBottomSheet(
                                        context,
                                        jobProvider,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Search Field (when searching)
                          if (_isSearching) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search jobs...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ],

                          // Filter Chips
                          if (!_isSearching) ...[
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('All', isDark),
                                  _buildFilterChip('Applied', isDark),
                                  _buildFilterChip('Called', isDark),
                                  _buildFilterChip('Interviewed', isDark),
                                  _buildFilterChip('Offer', isDark),
                                  _buildFilterChip('Rejected', isDark),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Jobs List
                jobProvider.isLoading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : filteredJobs.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(
                          isSearching: _searchQuery.isNotEmpty,
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final job = filteredJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _JobCardNew(
                                job: job,
                                isDark: isDark,
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => JobDetailScreen(job: job),
                                    ),
                                  );
                                },
                              ),
                            );
                          }, childCount: filteredJobs.length),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive
              ? Colors.white
              : (isDark ? Colors.white : AppColors.primaryDark),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
          // Turn off drafts-only when switching filter tabs
          final jobProvider = Provider.of<JobProvider>(context, listen: false);
          if (jobProvider.showDraftsOnly) {
            jobProvider.toggleDraftsOnly();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryDark
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(25),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 1,
                  ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, JobProvider jobProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortOption(
                    'Last Updated',
                    jobProvider.sortBy == 'updatedAt',
                    () {
                      jobProvider.setSortBy('updatedAt');
                      Navigator.pop(sheetContext);
                    },
                    isDark,
                  ),
                  _buildSortOption(
                    'Date Added',
                    jobProvider.sortBy == 'createdAt',
                    () {
                      jobProvider.setSortBy('createdAt');
                      Navigator.pop(sheetContext);
                    },
                    isDark,
                  ),
                  _buildSortOption(
                    'Company',
                    jobProvider.sortBy == 'company',
                    () {
                      jobProvider.setSortBy('company');
                      Navigator.pop(sheetContext);
                    },
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  'Show Drafts Only',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                value: jobProvider.showDraftsOnly,
                onChanged: (_) {
                  jobProvider.toggleDraftsOnly();
                  setSheetState(() {});
                  // Also reset the tab filter to 'All' when toggling drafts
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? AppColors.darkBackground : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isSearching = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.work_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'No jobs yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try searching with a different term'
                : 'Add your first job application to get started!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// New Job Card matching mockup design
class _JobCardNew extends StatelessWidget {
  final JobApplicationModel job;
  final bool isDark;
  final VoidCallback onTap;

  const _JobCardNew({
    required this.job,
    required this.isDark,
    required this.onTap,
  });

  IconData _getJobIcon() {
    final title = job.jobTitle.toLowerCase();
    if (title.contains('design') ||
        title.contains('ui') ||
        title.contains('ux')) {
      return Icons.grid_view_rounded;
    } else if (title.contains('product') || title.contains('manager')) {
      return Icons.rocket_launch_rounded;
    } else if (title.contains('engineer') ||
        title.contains('developer') ||
        title.contains('frontend') ||
        title.contains('backend')) {
      return Icons.code_rounded;
    } else if (title.contains('market') || title.contains('sales')) {
      return Icons.trending_up_rounded;
    } else if (title.contains('data') || title.contains('analys')) {
      return Icons.analytics_rounded;
    }
    return Icons.work_outline_rounded;
  }

  Color _getStatusColor() {
    switch (job.stage) {
      case ApplicationStage.interested:
        return AppColors.statusInterested;
      case ApplicationStage.applied:
        return AppColors.statusApplied;
      case ApplicationStage.interviewCalled:
      case ApplicationStage.interviewed:
        return AppColors.statusInterview;
      case ApplicationStage.offer:
        return AppColors.statusOffer;
      case ApplicationStage.rejected:
        return AppColors.statusRejected;
    }
  }

  String _getStatusLabel() {
    switch (job.stage) {
      case ApplicationStage.interested:
        return 'DRAFT';
      case ApplicationStage.applied:
        return 'APPLIED';
      case ApplicationStage.interviewCalled:
        return 'CALLED';
      case ApplicationStage.interviewed:
        return 'INTERVIEWED';
      case ApplicationStage.offer:
        return 'OFFER';
      case ApplicationStage.rejected:
        return 'REJECTED';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            // Header Row: Icon + Title + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getJobIcon(),
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.jobTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primaryDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusLabel(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 1: Date info based on stage
            if (job.stage == ApplicationStage.interviewCalled) ...[
              _buildInfoRow(
                Icons.calendar_today_outlined,
                '${job.interviewType ?? 'Interview'}:',
                _formatDateTime(job.updatedAt),
                isDark,
              ),
            ] else if (job.stage == ApplicationStage.interviewed) ...[
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Interviewed on:',
                _formatDateTime(job.updatedAt),
                isDark,
              ),
            ] else if (job.stage == ApplicationStage.offer) ...[
              _buildInfoRow(
                Icons.card_giftcard_outlined,
                'Got offer:',
                _formatDate(job.updatedAt),
                isDark,
              ),
            ] else if (job.stage == ApplicationStage.rejected) ...[
              _buildInfoRow(
                Icons.event_busy_outlined,
                'Closed on:',
                _formatDate(job.updatedAt),
                isDark,
              ),
            ] else ...[
              // Applied, Interested/Draft
              _buildInfoRow(
                Icons.access_time_rounded,
                'Applied on:',
                _formatDate(job.applicationDate ?? job.createdAt),
                isDark,
              ),
            ],
            const SizedBox(height: 8),

            // Row 2: Job type (remote/onsite/hybrid)
            _buildInfoRow(
              Icons.location_on_outlined,
              '',
              job.jobType.displayName,
              isDark,
            ),
            const SizedBox(height: 8),

            // Row 3: Salary
            _buildInfoRow(
              Icons.payments_outlined,
              '',
              _getSalaryDisplay(),
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 8),
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(date)} ${hour.toString()}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _getSalaryDisplay() {
    if (job.salaryRange == null || job.salaryRange!.isEmpty) {
      return 'Negotiable';
    }
    final symbol = job.salaryCurrency.symbol;
    // Strip any existing currency symbols to avoid duplication
    final cleaned = job.salaryRange!
        .replaceAll(RegExp(r'[^\d\s\-\.K]'), '')
        .trim();
    return '$symbol$cleaned';
  }
}
