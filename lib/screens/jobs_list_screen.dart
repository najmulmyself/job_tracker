import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job_application_model.dart';
import '../utils/app_theme.dart';
import '../widgets/job_card.dart';
import '../widgets/filter_chip_widget.dart';
import 'job_detail_screen.dart';

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                                CupertinoPageRoute(
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
