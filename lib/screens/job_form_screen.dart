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
  final _interviewNotesController = TextEditingController();

  JobSource _selectedSource = JobSource.linkedin;
  ApplicationStage _selectedStage = ApplicationStage.applied;
  SalaryCurrency _selectedCurrency = SalaryCurrency.usd;
  DateTime? _applicationDate;
  DateTime? _deadline;
  String? _selectedResumeId;

  double _minSalary = 60.0;
  double _maxSalary = 90.0;

  // Interview call tracking
  DateTime? _interviewCallDate;
  DateTime? _interviewScheduledDate;
  TimeOfDay? _interviewTime;
  String? _interviewType;

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
    _selectedCurrency = job.salaryCurrency;
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

    // Load interview data
    _interviewCallDate = job.interviewCallDate;
    _interviewScheduledDate = job.interviewScheduledDate;
    _interviewType = job.interviewType;
    _interviewNotesController.text = job.interviewCallNotes ?? '';

    if (job.interviewScheduledDate != null) {
      _interviewTime = TimeOfDay.fromDateTime(job.interviewScheduledDate!);
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
    _interviewNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveJob({required bool asDraft}) async {
    if (!asDraft && !_formKey.currentState!.validate()) {
      return;
    }

    // Validate interview fields if stage is "Interview Called"
    if (!asDraft && _selectedStage == ApplicationStage.interviewCalled) {
      if (_interviewScheduledDate == null || _interviewTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set interview date and time'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) return;

    // Combine interview date and time
    DateTime? finalInterviewDateTime;
    if (_interviewScheduledDate != null && _interviewTime != null) {
      finalInterviewDateTime = DateTime(
        _interviewScheduledDate!.year,
        _interviewScheduledDate!.month,
        _interviewScheduledDate!.day,
        _interviewTime!.hour,
        _interviewTime!.minute,
      );
    }

    final job = JobApplicationModel(
      id: widget.job?.id ?? const Uuid().v4(),
      userId: userId,
      companyName: _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      source: _selectedSource,
      salaryRange:
          '${_selectedCurrency.symbol}${_minSalary.toInt()}K - ${_selectedCurrency.symbol}${_maxSalary.toInt()}K',
      salaryCurrency: _selectedCurrency,
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
      interviewCallDate: _interviewCallDate,
      interviewCallNotes: _interviewNotesController.text.trim().isNotEmpty
          ? _interviewNotesController.text.trim()
          : null,
      interviewScheduledDate: finalInterviewDateTime,
      interviewType: _interviewType,
      interviewReminderEnabled: widget.job?.interviewReminderEnabled ?? false,
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

            // Salary Currency
            Text(
              'Salary Currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCurrencyChip('BDT', SalaryCurrency.bdt, isDark),
                _buildCurrencyChip('USD', SalaryCurrency.usd, isDark),
                _buildCurrencyChip('EUR', SalaryCurrency.eur, isDark),
                _buildCurrencyChip('INR', SalaryCurrency.inr, isDark),
                _buildCurrencyChip('GBP', SalaryCurrency.gbp, isDark),
                _buildCurrencyChip('Other', SalaryCurrency.other, isDark),
              ],
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
                '${_selectedCurrency.symbol}${_minSalary.toInt()}K',
                '${_selectedCurrency.symbol}${_maxSalary.toInt()}K',
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
                  '${_selectedCurrency.symbol}${_minSalary.toInt()}K',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${_selectedCurrency.symbol}${_maxSalary.toInt()}K',
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

            // Interview Section (only show if stage is interviewCalled)
            if (_selectedStage == ApplicationStage.interviewCalled) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.cyan.withOpacity(0.1)
                      : Colors.cyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone_in_talk, color: Colors.cyan),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Interview Call Information',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '* Interview date & time required',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Interview Call Date
                    Text(
                      'Interview Call Received',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _interviewCallDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _interviewCallDate = date);
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
                                _interviewCallDate != null
                                    ? '${_interviewCallDate!.day}/${_interviewCallDate!.month}/${_interviewCallDate!.year}'
                                    : 'Select date',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interview Scheduled Date
                    Text(
                      'Interview Scheduled Date',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    _interviewScheduledDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() => _interviewScheduledDate = date);
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
                                      _interviewScheduledDate != null
                                          ? '${_interviewScheduledDate!.day}/${_interviewScheduledDate!.month}/${_interviewScheduledDate!.year}'
                                          : 'Select date',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _interviewTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => _interviewTime = time);
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
                                      _interviewTime != null
                                          ? _interviewTime!.format(context)
                                          : 'Select time',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ),
                                  const Icon(Icons.access_time, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Interview Type
                    Text(
                      'Interview Type',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _interviewType,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select interview type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                        DropdownMenuItem(value: 'Video', child: Text('Video')),
                        DropdownMenuItem(
                          value: 'In-Person',
                          child: Text('In-Person'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _interviewType = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Interview Notes
                    Text(
                      'Interview Notes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _interviewNotesController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Notes from the interview call...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

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

  Widget _buildCurrencyChip(
    String label,
    SalaryCurrency currency,
    bool isDark,
  ) {
    final isSelected = _selectedCurrency == currency;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrency = currency;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
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
    );
  }
}
