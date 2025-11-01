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
  final _salaryRangeController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  JobSource _selectedSource = JobSource.linkedin;
  ApplicationStage _selectedStage = ApplicationStage.interested;
  DateTime? _applicationDate;
  DateTime? _deadline;
  String? _selectedResumeId;

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
    _salaryRangeController.text = job.salaryRange ?? '';
    _expectedSalaryController.text = job.expectedSalary ?? '';
    _jobDescriptionController.text = job.jobDescription;
    _selectedStage = job.stage;
    _applicationDate = job.applicationDate;
    _deadline = job.deadline;
    _selectedResumeId = job.resumeId;
    _notesController.text = job.notes;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _salaryRangeController.dispose();
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
      salaryRange: _salaryRangeController.text.trim().isNotEmpty
          ? _salaryRangeController.text.trim()
          : null,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'Add Job' : 'Edit Job'),
        actions: [
          TextButton(
            onPressed: () => _saveJob(asDraft: true),
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                prefixIcon: Icon(Icons.business),
              ),
              validator: Validators.validateCompanyName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                prefixIcon: Icon(Icons.work),
              ),
              validator: Validators.validateJobTitle,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<JobSource>(
              initialValue: _selectedSource,
              decoration: const InputDecoration(
                labelText: 'Source',
                prefixIcon: Icon(Icons.source),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _jobDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Job Description *',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 5,
              validator: Validators.validateJobDescription,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ApplicationStage>(
              initialValue: _selectedStage,
              decoration: const InputDecoration(
                labelText: 'Application Stage',
                prefixIcon: Icon(Icons.timeline),
              ),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _saveJob(asDraft: false),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Job', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
