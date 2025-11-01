import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/resume_provider.dart';
import '../models/job_application_model.dart';
import '../utils/app_theme.dart';
import '../widgets/job_card.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/stats_card.dart';
import 'job_form_screen.dart';
import 'job_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.firebaseUser?.uid;

      if (userId != null) {
        Provider.of<JobProvider>(context, listen: false).listenToJobs(userId);
        Provider.of<ResumeProvider>(
          context,
          listen: false,
        ).listenToResumes(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'All Jobs', icon: Icon(Icons.work)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Show warning banner if Firestore is not configured
          if (authProvider.error != null &&
              authProvider.error!.contains('Firestore'))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade900,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setup Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Firestore not enabled. Please follow ENABLE_FIRESTORE.md to save your data.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      authProvider.clearError();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDashboardTab(), _buildJobsListTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const JobFormScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('New Application'),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total',
                      count: jobProvider.totalJobs,
                      icon: Icons.work_outline,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Applied',
                      count: jobProvider.appliedCount,
                      icon: Icons.send,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Interviews',
                      count: jobProvider.interviewCount,
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Drafts',
                      count: jobProvider.draftCount,
                      icon: Icons.drafts,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Applications
              const Text(
                'Recent Applications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (jobProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (jobProvider.jobs.isEmpty)
                _buildEmptyState()
              else
                ...jobProvider.jobs
                    .take(5)
                    .map(
                      (job) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobCard(
                          job: job,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(job: job),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobsListTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        return Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Stage:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          jobProvider.clearFilters();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipWidget(
                          label: 'All',
                          isSelected: jobProvider.filterStage == null,
                          onSelected: (_) => jobProvider.setFilterStage(null),
                        ),
                        ...ApplicationStage.values.map(
                          (stage) => FilterChipWidget(
                            label: stage.displayName,
                            isSelected: jobProvider.filterStage == stage,
                            color: AppColors.getStageColor(stage),
                            onSelected: (_) =>
                                jobProvider.setFilterStage(stage),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: jobProvider.sortBy,
                          decoration: const InputDecoration(
                            labelText: 'Sort By',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'updatedAt',
                              child: Text('Last Updated'),
                            ),
                            DropdownMenuItem(
                              value: 'createdAt',
                              child: Text('Date Added'),
                            ),
                            DropdownMenuItem(
                              value: 'deadline',
                              child: Text('Deadline'),
                            ),
                            DropdownMenuItem(
                              value: 'company',
                              child: Text('Company Name'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              jobProvider.setSortBy(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Drafts Only'),
                        selected: jobProvider.showDraftsOnly,
                        onSelected: (_) => jobProvider.toggleDraftsOnly(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Jobs List
            Expanded(
              child: jobProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : jobProvider.jobs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobProvider.jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobProvider.jobs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobCard(
                            job: job,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(job: job),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No jobs yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first job application to get started!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
