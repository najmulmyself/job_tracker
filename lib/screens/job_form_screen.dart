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
  JobType _selectedJobType = JobType.remote;
  DateTime? _applicationDate;
  DateTime? _deadline;
  String? _selectedResumeId;

  double _minSalary = 60.0;
  double _maxSalary = 90.0;
  bool _isNegotiable = false;
  bool _isUpTo = false;

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
    _selectedJobType = job.jobType;
    _applicationDate = job.applicationDate;
    _deadline = job.deadline;
    _selectedResumeId = job.resumeId;
    _notesController.text = job.notes;

    // Parse salary range if exists
    if (job.salaryRange == null || job.salaryRange!.isEmpty) {
      _isNegotiable = true;
    } else if (job.salaryRange!.toLowerCase().startsWith('up to')) {
      _isUpTo = true;
      final numbers = RegExp(r'\d+\.?\d*').allMatches(job.salaryRange!);
      final parsed = numbers
          .map((m) => double.tryParse(m.group(0)!) ?? 0)
          .toList();
      if (parsed.isNotEmpty) {
        _maxSalary = parsed[0];
        _salaryMaxController.text = _maxSalary.toInt().toString();
      }
    } else {
      final numbers = RegExp(r'\d+\.?\d*').allMatches(job.salaryRange!);
      final parsed = numbers
          .map((m) => double.tryParse(m.group(0)!) ?? 0)
          .toList();
      if (parsed.length >= 2) {
        _minSalary = parsed[0];
        _maxSalary = parsed[1];
        _salaryMinController.text = _minSalary.toInt().toString();
        _salaryMaxController.text = _maxSalary.toInt().toString();
      } else if (parsed.length == 1) {
        _minSalary = parsed[0];
        _maxSalary = parsed[0];
        _salaryMinController.text = _minSalary.toInt().toString();
        _salaryMaxController.text = _maxSalary.toInt().toString();
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

    // Validate interview fields if stage is "Interview Called" or "Interviewed"
    if (!asDraft &&
        (_selectedStage == ApplicationStage.interviewCalled ||
            _selectedStage == ApplicationStage.interviewed)) {
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
      salaryRange: _isNegotiable
          ? null
          : _isUpTo
          ? 'Up to ${_maxSalary.toInt()}K'
          : '${_minSalary.toInt()}K - ${_maxSalary.toInt()}K',
      salaryCurrency: _selectedCurrency,
      jobType: _selectedJobType,
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
          padding: const EdgeInsets.all(16),
          children: [
            // Card 1: Basic Info
            _buildSectionCard(
              context,
              isDark,
              title: 'Basic Information',
              icon: Icons.business_outlined,
              children: [
                // Company Name
                Text(
                  'Company Name',
                  style: Theme.of(context).textTheme.titleSmall,
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
                const SizedBox(height: 16),

                // Job Title
                Text(
                  'Job Title',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
                const SizedBox(height: 16),

                // Source
                Text('Source', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _buildSheetSelector<JobSource>(
                  context: context,
                  isDark: isDark,
                  value: _selectedSource,
                  hint: 'Select source',
                  displayText: _selectedSource.displayName,
                  icon: _getSourceIcon(_selectedSource),
                  items: JobSource.values,
                  sheetTitle: 'Select Source',
                  itemBuilder: (source) => _SheetItem(
                    icon: _getSourceIcon(source),
                    label: source.displayName,
                  ),
                  onSelected: (source) {
                    setState(() => _selectedSource = source);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card 2: Compensation
            _buildSectionCard(
              context,
              isDark,
              title: 'Compensation',
              icon: Icons.payments_outlined,
              children: [
                // Salary Currency
                Text(
                  'Salary Currency',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 16),

                // Negotiable toggle
                _buildToggleRow(
                  context: context,
                  isDark: isDark,
                  label: 'Negotiable',
                  subtitle: 'Salary is open to discussion',
                  value: _isNegotiable,
                  onChanged: (val) {
                    setState(() {
                      _isNegotiable = val;
                      if (val) _isUpTo = false;
                    });
                  },
                ),

                if (!_isNegotiable) ...[
                  const SizedBox(height: 12),

                  // Up To toggle
                  _buildToggleRow(
                    context: context,
                    isDark: isDark,
                    label: 'Up to',
                    subtitle: 'Single max amount (e.g. Up to 45K)',
                    value: _isUpTo,
                    onChanged: (val) {
                      setState(() => _isUpTo = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Salary fields
                  if (_isUpTo) ...[
                    TextFormField(
                      controller: _salaryMaxController,
                      keyboardType: TextInputType.number,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Amount (K)',
                        prefixText: _selectedCurrency.symbol,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _maxSalary = parsed;
                        }
                      },
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMinController,
                            keyboardType: TextInputType.number,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Min (K)',
                              prefixText: _selectedCurrency.symbol,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null && parsed >= 0) {
                                _minSalary = parsed;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('—', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMaxController,
                            keyboardType: TextInputType.number,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Max (K)',
                              prefixText: _selectedCurrency.symbol,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null && parsed >= 0) {
                                _maxSalary = parsed;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Expected Salary
                  Text(
                    'Expected Salary',
                    style: Theme.of(context).textTheme.titleSmall,
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
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Card 3: Job Details
            _buildSectionCard(
              context,
              isDark,
              title: 'Job Details',
              icon: Icons.work_outline,
              children: [
                // Job Type
                Text('Job Type', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildJobTypeChip('Remote', JobType.remote, isDark),
                    _buildJobTypeChip('Onsite', JobType.onsite, isDark),
                    _buildJobTypeChip('Hybrid', JobType.hybrid, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Job Description
                Text(
                  'Job Description',
                  style: Theme.of(context).textTheme.titleSmall,
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
              ],
            ),
            const SizedBox(height: 12),

            // Card 4: Application & Tracking
            _buildSectionCard(
              context,
              isDark,
              title: 'Application & Tracking',
              icon: Icons.timeline_outlined,
              children: [
                // Application Stage
                Text(
                  'Application Stage',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildSheetSelector<ApplicationStage>(
                  context: context,
                  isDark: isDark,
                  value: _selectedStage,
                  hint: 'Select stage',
                  displayText: _selectedStage.displayName,
                  icon: _getStageIcon(_selectedStage),
                  items: ApplicationStage.values,
                  sheetTitle: 'Select Stage',
                  itemBuilder: (stage) => _SheetItem(
                    icon: _getStageIcon(stage),
                    label: stage.displayName,
                    color: _getStageColor(stage),
                  ),
                  onSelected: (stage) {
                    setState(() => _selectedStage = stage);
                  },
                ),
                const SizedBox(height: 16),

                // Interview Section (conditional)
                if (_selectedStage == ApplicationStage.interviewCalled ||
                    _selectedStage == ApplicationStage.interviewed) ...[
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '* Interview date & time required',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
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
                                        _interviewScheduledDate ??
                                        DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setState(
                                      () => _interviewScheduledDate = date,
                                    );
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
                                    initialTime:
                                        _interviewTime ?? TimeOfDay.now(),
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
                        _buildSheetSelector<String?>(
                          context: context,
                          isDark: isDark,
                          value: _interviewType,
                          hint: 'Select interview type',
                          displayText:
                              _interviewType ?? 'Select interview type',
                          icon: _getInterviewTypeIcon(_interviewType),
                          items: const ['Phone', 'Video', 'In-Person'],
                          sheetTitle: 'Interview Type',
                          itemBuilder: (type) => _SheetItem(
                            icon: _getInterviewTypeIcon(type),
                            label: type ?? '',
                          ),
                          onSelected: (type) {
                            setState(() => _interviewType = type);
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
                  const SizedBox(height: 16),
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
                            style: Theme.of(context).textTheme.titleSmall,
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
                            style: Theme.of(context).textTheme.titleSmall,
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Resume Used
                Text(
                  'Resume Used',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildSheetSelector<String?>(
                  context: context,
                  isDark: isDark,
                  value: _selectedResumeId,
                  hint: 'Select a resume version',
                  displayText: _selectedResumeId ?? 'Select a resume version',
                  icon: Icons.description_outlined,
                  items: const <String?>[null],
                  sheetTitle: 'Select Resume',
                  itemBuilder: (_) => const _SheetItem(
                    icon: Icons.description_outlined,
                    label: 'No resumes uploaded yet',
                  ),
                  onSelected: (value) {
                    setState(() => _selectedResumeId = value);
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                Text('Notes', style: Theme.of(context).textTheme.titleSmall),
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
              ],
            ),
            const SizedBox(height: 24),

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

  Widget _buildSectionCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: isDark ? 1 : 2,
      shadowColor: isDark ? Colors.black45 : Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // --- Modern bottom sheet selector ---

  Widget _buildSheetSelector<T>({
    required BuildContext context,
    required bool isDark,
    required T value,
    required String hint,
    required String displayText,
    required IconData icon,
    required List<T> items,
    required String sheetTitle,
    required _SheetItem Function(T item) itemBuilder,
    required ValueChanged<T> onSelected,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final isPlaceholder = displayText == hint;

    return InkWell(
      onTap: () => _showSelectionSheet<T>(
        context: context,
        isDark: isDark,
        title: sheetTitle,
        items: items,
        selectedValue: value,
        itemBuilder: itemBuilder,
        onSelected: onSelected,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isPlaceholder ? Colors.grey : primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w500,
                  color: isPlaceholder
                      ? (isDark ? Colors.white38 : Colors.black38)
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet<T>({
    required BuildContext context,
    required bool isDark,
    required String title,
    required List<T> items,
    required T selectedValue,
    required _SheetItem Function(T item) itemBuilder,
    required ValueChanged<T> onSelected,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: items.map((item) {
                      final sheet = itemBuilder(item);
                      final isSelected = item == selectedValue;
                      return ListTile(
                        leading: Icon(
                          sheet.icon,
                          size: 22,
                          color: isSelected
                              ? primary
                              : (sheet.color ??
                                    (isDark ? Colors.white54 : Colors.black45)),
                        ),
                        title: Text(
                          sheet.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? primary
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: primary, size: 22)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          onSelected(item);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSourceIcon(JobSource source) {
    switch (source) {
      case JobSource.linkedin:
        return Icons.link;
      case JobSource.indeed:
        return Icons.search;
      case JobSource.email:
        return Icons.email_outlined;
      case JobSource.referral:
        return Icons.people_outlined;
      case JobSource.companyWebsite:
        return Icons.language;
      case JobSource.wellfound:
        return Icons.rocket_launch_outlined;
      case JobSource.remoteOk:
        return Icons.wifi;
      case JobSource.other:
        return Icons.more_horiz;
    }
  }

  IconData _getStageIcon(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.interested:
        return Icons.bookmark_outline;
      case ApplicationStage.applied:
        return Icons.send_outlined;
      case ApplicationStage.interviewCalled:
        return Icons.phone_outlined;
      case ApplicationStage.interviewed:
        return Icons.record_voice_over_outlined;
      case ApplicationStage.offer:
        return Icons.card_giftcard_outlined;
      case ApplicationStage.rejected:
        return Icons.cancel_outlined;
    }
  }

  Color _getStageColor(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.interested:
        return Colors.grey;
      case ApplicationStage.applied:
        return Colors.blue;
      case ApplicationStage.interviewCalled:
        return Colors.orange;
      case ApplicationStage.interviewed:
        return Colors.cyan;
      case ApplicationStage.offer:
        return Colors.green;
      case ApplicationStage.rejected:
        return Colors.red;
    }
  }

  IconData _getInterviewTypeIcon(String? type) {
    switch (type) {
      case 'Phone':
        return Icons.phone_outlined;
      case 'Video':
        return Icons.videocam_outlined;
      case 'In-Person':
        return Icons.person_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildJobTypeChip(String label, JobType type, bool isDark) {
    final isSelected = _selectedJobType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedJobType = type;
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

class _SheetItem {
  final IconData icon;
  final String label;
  final Color? color;

  const _SheetItem({required this.icon, required this.label, this.color});
}
