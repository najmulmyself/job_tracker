import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/job_application_model.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../utils/validators.dart';

class JobFormScreen extends StatefulWidget {
  final JobApplicationModel? job;

  const JobFormScreen({super.key, this.job});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _salaryMinController = TextEditingController(text: '60');
  final _salaryMaxController = TextEditingController(text: '90');
  final _expectedSalaryController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  JobSource _selectedSource = JobSource.linkedin;
  ApplicationStage _selectedStage = ApplicationStage.applied;
  DateTime? _applicationDate;
  DateTime? _deadline;
  String? _selectedResumeId;

  double _minSalary = 60.0;
  double _maxSalary = 90.0;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _loadJobData();
    }
  }

  void _loadJobData() {
    final job = widget.job!;
    _companyController.text = job.companyName;
    _jobTitleController.text = job.jobTitle;
    _selectedSource = job.source;
    _expectedSalaryController.text = job.expectedSalary ?? '';
    _jobDescriptionController.text = job.jobDescription;
    _selectedStage = job.stage;
    _applicationDate = job.applicationDate;
    _deadline = job.deadline;
    _selectedResumeId = job.resumeId;
    _notesController.text = job.notes;

    // Parse salary range if exists
    if (job.salaryRange != null) {
      final parts = job.salaryRange!.split('-');
      if (parts.length == 2) {
        _minSalary =
            double.tryParse(parts[0].replaceAll(RegExp(r'[^\d.]'), '')) ?? 60.0;
        _maxSalary =
            double.tryParse(parts[1].replaceAll(RegExp(r'[^\d.]'), '')) ?? 90.0;
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _expectedSalaryController.dispose();
    _jobDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveJob({required bool asDraft}) async {
    if (!asDraft && !_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) return;

    final job = JobApplicationModel(
      id: widget.job?.id ?? const Uuid().v4(),
      userId: userId,
      companyName: _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      source: _selectedSource,
      salaryRange: '\$${_minSalary.toInt()}K - \$${_maxSalary.toInt()}K',
      expectedSalary: _expectedSalaryController.text.trim().isNotEmpty
          ? _expectedSalaryController.text.trim()
          : null,
      jobDescription: _jobDescriptionController.text.trim(),
      stage: _selectedStage,
      applicationDate: _applicationDate,
      deadline: _deadline,
      resumeId: _selectedResumeId,
      notes: _notesController.text.trim(),
      isDraft: asDraft,
      createdAt: widget.job?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.job == null) {
        await jobProvider.createJob(job);
      } else {
        await jobProvider.updateJob(job);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(asDraft ? 'Draft saved' : 'Job saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.job == null ? 'New Application' : 'Edit Application',
        ),
        actions: [
          TextButton(
            onPressed: () => _saveJob(asDraft: true),
            child: const Text('Saved', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Company Name
            Text(
              'Company Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _companyController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Enter company name',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateCompanyName,
            ),
            const SizedBox(height: 20),

            // Job Title
            Text('Job Title', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _jobTitleController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Enter job title',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateJobTitle,
            ),
            const SizedBox(height: 20),

            // Source
            Text('Source', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<JobSource>(
              initialValue: _selectedSource,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'e.g., LinkedIn, Indeed, Referral',
                border: OutlineInputBorder(),
              ),
              items: JobSource.values
                  .map(
                    (source) => DropdownMenuItem(
                      value: source,
                      child: Text(source.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSource = value);
                }
              },
            ),
            const SizedBox(height: 20),

            // Salary Range (Slider)
            Text(
              'Salary Range (Advertised)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: RangeValues(_minSalary, _maxSalary),
              min: 0,
              max: 200,
              divisions: 40,
              labels: RangeLabels(
                '\$${_minSalary.toInt()}K',
                '\$${_maxSalary.toInt()}K',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _minSalary = values.start;
                  _maxSalary = values.end;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${_minSalary.toInt()}K',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '\$${_maxSalary.toInt()}K',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Expected Salary
            Text(
              'Expected Salary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _expectedSalaryController,
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Your target salary',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Job Description
            Text(
              'Job Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _jobDescriptionController,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Paste the job description here...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: Validators.validateJobDescription,
            ),
            const SizedBox(height: 20),

            // Application Stage
            Text(
              'Application Stage',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ApplicationStage>(
              initialValue: _selectedStage,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ApplicationStage.values
                  .map(
                    (stage) => DropdownMenuItem(
                      value: stage,
                      child: Text(stage.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStage = value);
                }
              },
            ),
            const SizedBox(height: 20),

            // Date Pickers Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _applicationDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _applicationDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _applicationDate != null
                                      ? '${_applicationDate!.day}/${_applicationDate!.month}/${_applicationDate!.year}'
                                      : 'Select date',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow-up Deadline',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _deadline ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _deadline = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _deadline != null
                                      ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                      : 'Select date',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Resume Used (placeholder)
            Text('Resume Used', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedResumeId,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Select a resume version',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Select a resume version'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedResumeId = value);
              },
            ),
            const SizedBox(height: 20),

            // Notes
            Text('Notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Add contact info, thoughts, or reminders...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveJob(asDraft: false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
