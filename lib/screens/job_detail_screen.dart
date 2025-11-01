import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/job_application_model.dart';
import '../providers/job_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import 'job_form_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final JobApplicationModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late bool reminderEnabled;

  @override
  void initState() {
    super.initState();
    reminderEnabled = widget.job.interviewReminderEnabled;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('h:mm a').format(time);
  }

  String _formatSalary() {
    if (widget.job.salaryRange != null && widget.job.salaryRange!.isNotEmpty) {
      return widget.job.salaryRange!;
    }
    if (widget.job.expectedSalary != null &&
        widget.job.expectedSalary!.isNotEmpty) {
      return widget.job.expectedSalary!;
    }
    return 'Not specified';
  }

  Color _getStatusColor() {
    return AppColors.getStageColor(widget.job.stage);
  }

  String _getJobType() {
    // You can add jobType field to model later
    // For now, returning a default
    return 'Full-time';
  }

  void _toggleReminder(bool value) async {
    // Check if interview is scheduled
    if (widget.job.interviewScheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set an interview date first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      reminderEnabled = value;
    });

    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final updatedJob = widget.job.copyWith(
      interviewReminderEnabled: value,
      updatedAt: DateTime.now(),
    );

    await jobProvider.updateJob(updatedJob);

    // Schedule or cancel notifications
    final notificationService = NotificationService();
    if (value) {
      await notificationService.scheduleInterviewReminders(
        jobId: widget.job.id,
        companyName: widget.job.companyName,
        jobTitle: widget.job.jobTitle,
        interviewDateTime: widget.job.interviewScheduledDate!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview reminders scheduled! 🔔'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await notificationService.cancelInterviewReminders(widget.job.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interview reminders cancelled'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final jobProvider = Provider.of<JobProvider>(
                context,
                listen: false,
              );
              await jobProvider.deleteJob(widget.job.userId, widget.job.id);
              if (mounted) {
                Navigator.of(context).pop(); // Go back to home screen
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(widget.job.companyName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Delete Application',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title
                  Text(
                    widget.job.jobTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.job.stage.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface.withOpacity(0.5)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getJobType(),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Job Details Section
            _buildSection(
              context: context,
              title: 'Job Details',
              isDark: isDark,
              children: [
                _buildDetailItem(
                  icon: Icons.business,
                  label: widget.job.source.displayName,
                  isDark: isDark,
                ),
                _buildDetailItem(
                  icon: Icons.attach_money,
                  label: _formatSalary(),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dates & Deadlines Section
            _buildSection(
              context: context,
              title: 'Dates & Deadlines',
              isDark: isDark,
              children: [
                _buildDetailItem(
                  icon: Icons.calendar_today,
                  label: 'Date Applied',
                  isDark: isDark,
                  trailing: Text(
                    _formatDate(widget.job.applicationDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildDetailItem(
                  icon: Icons.event,
                  label: 'Deadline',
                  isDark: isDark,
                  trailing: Text(
                    _formatDate(widget.job.deadline),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildDetailItem(
                  icon: Icons.notifications,
                  label: 'Reminder',
                  isDark: isDark,
                  trailing: Switch(
                    value: reminderEnabled,
                    onChanged: _toggleReminder,
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Interview Call Section
            if (widget.job.stage == ApplicationStage.interviewCalled ||
                widget.job.stage == ApplicationStage.interviewed)
              _buildSection(
                context: context,
                title: 'Interview Information',
                isDark: isDark,
                children: [
                  if (widget.job.interviewCallDate != null)
                    _buildDetailItem(
                      icon: Icons.phone_callback,
                      label: 'Interview Call Received',
                      isDark: isDark,
                      trailing: Text(
                        _formatDate(widget.job.interviewCallDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (widget.job.interviewScheduledDate != null) ...[
                    _buildDetailItem(
                      icon: Icons.event_available,
                      label: 'Interview Scheduled',
                      isDark: isDark,
                      trailing: Text(
                        '${_formatDate(widget.job.interviewScheduledDate)} ${_formatTime(widget.job.interviewScheduledDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.job.interviewType != null)
                      _buildDetailItem(
                        icon: Icons.video_call,
                        label: 'Interview Type',
                        isDark: isDark,
                        trailing: Text(
                          widget.job.interviewType!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    _buildDetailItem(
                      icon: Icons.notifications_active,
                      label: 'Interview Reminders',
                      isDark: isDark,
                      trailing: Switch(
                        value: reminderEnabled,
                        onChanged: _toggleReminder,
                        activeThumbColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                  if (widget.job.interviewCallNotes != null &&
                      widget.job.interviewCallNotes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interview Notes:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.job.interviewCallNotes!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

            if (widget.job.stage == ApplicationStage.interviewCalled ||
                widget.job.stage == ApplicationStage.interviewed)
              const SizedBox(height: 16),

            // Notes Section
            if (widget.job.notes.isNotEmpty)
              _buildSection(
                context: context,
                title: 'Notes',
                isDark: isDark,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      widget.job.notes,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => JobFormScreen(job: widget.job),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Edit Application',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required bool isDark,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withOpacity(0.5)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
