import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../viewmodels/student_view_model.dart';
import '../../routes/route_manager.dart';
import '../../services/student_service.dart';
import '../../services/storage_service.dart';

enum _DocSlot {
  idDocument,
  proofOfRegistration,
  academicTranscript,
  cv,
  matricCertificate,
}

class EditStudentProfile extends StatefulWidget {
  const EditStudentProfile({super.key});

  @override
  State<EditStudentProfile> createState() => _EditStudentProfileState();
}

class _EditStudentProfileState extends State<EditStudentProfile> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  static const String _bucket = 'student-documents';

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController studentNumberController = TextEditingController();
  final TextEditingController currentYearController = TextEditingController();

  String? _idDocumentUrl;
  String? _proofOfRegistrationUrl;
  String? _academicTranscriptUrl;
  String? _cvUrl;
  String? _matricCertificateUrl;

  String? _idDocumentName;
  String? _proofOfRegistrationName;
  String? _academicTranscriptName;
  String? _cvName;
  String? _matricCertificateName;

  final Set<_DocSlot> _uploadingSlots = <_DocSlot>{};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<StudentViewModel>(context, listen: false);
      firstNameController.text = vm.firstName;
      lastNameController.text = vm.lastName;
      studentNumberController.text = vm.studentNumber;
      currentYearController.text = vm.currentYear;

      setState(() {
        _idDocumentUrl = vm.idDocument;
        _proofOfRegistrationUrl = vm.proofOfRegistration;
        _academicTranscriptUrl = vm.academicTranscript;
        _cvUrl = vm.cv;
        _matricCertificateUrl = vm.matricCertificate;

        _idDocumentName = _fileNameFromUrl(vm.idDocument);
        _proofOfRegistrationName = _fileNameFromUrl(vm.proofOfRegistration);
        _academicTranscriptName = _fileNameFromUrl(vm.academicTranscript);
        _cvName = _fileNameFromUrl(vm.cv);
        _matricCertificateName = _fileNameFromUrl(vm.matricCertificate);
      });
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    studentNumberController.dispose();
    currentYearController.dispose();
    super.dispose();
  }

  String? _fileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final cleaned = url.split('?').first;
    final parts = cleaned.split('/');
    return parts.isNotEmpty ? parts.last : url;
  }

  String _slotKey(_DocSlot slot) {
    switch (slot) {
      case _DocSlot.idDocument:
        return 'id_document';
      case _DocSlot.proofOfRegistration:
        return 'proof_of_registration';
      case _DocSlot.academicTranscript:
        return 'academic_transcript';
      case _DocSlot.cv:
        return 'cv';
      case _DocSlot.matricCertificate:
        return 'matric_certificate';
    }
  }

  String _slotLabel(_DocSlot slot) {
    switch (slot) {
      case _DocSlot.idDocument:
        return 'ID Document';
      case _DocSlot.proofOfRegistration:
        return 'Proof of Registration';
      case _DocSlot.academicTranscript:
        return 'Academic Transcript';
      case _DocSlot.cv:
        return 'CV';
      case _DocSlot.matricCertificate:
        return 'Matric Certificate';
    }
  }

  Future<void> _pickAndUpload(_DocSlot slot) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to upload documents."),
        ),
      );
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
        withData: kIsWeb,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not open file picker: $e")));
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    final originalName = picked.name;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = originalName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final storagePath = '${user.id}/${_slotKey(slot)}/${timestamp}_$safeName';

    setState(() => _uploadingSlots.add(slot));

    try {
      String publicUrl;
      if (kIsWeb) {
        final bytes = picked.bytes;
        if (bytes == null)
          throw Exception("Could not read file bytes from picker (web).");
        publicUrl = await _storageService.uploadBytes(
          _bucket,
          storagePath,
          bytes,
        );
      } else {
        final path = picked.path;
        if (path == null)
          throw Exception("Picked file has no path on this platform.");
        publicUrl = await _storageService.uploadFile(
          _bucket,
          storagePath,
          path,
        );
      }

      if (!mounted) return;
      setState(() {
        switch (slot) {
          case _DocSlot.idDocument:
            _idDocumentUrl = publicUrl;
            _idDocumentName = originalName;
            break;
          case _DocSlot.proofOfRegistration:
            _proofOfRegistrationUrl = publicUrl;
            _proofOfRegistrationName = originalName;
            break;
          case _DocSlot.academicTranscript:
            _academicTranscriptUrl = publicUrl;
            _academicTranscriptName = originalName;
            break;
          case _DocSlot.cv:
            _cvUrl = publicUrl;
            _cvName = originalName;
            break;
          case _DocSlot.matricCertificate:
            _matricCertificateUrl = publicUrl;
            _matricCertificateName = originalName;
            break;
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${_slotLabel(slot)} uploaded.")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading ${_slotLabel(slot)}: $e")),
      );
    } finally {
      if (mounted) setState(() => _uploadingSlots.remove(slot));
    }
  }

  void _clearSlot(_DocSlot slot) {
    setState(() {
      switch (slot) {
        case _DocSlot.idDocument:
          _idDocumentUrl = null;
          _idDocumentName = null;
          break;
        case _DocSlot.proofOfRegistration:
          _proofOfRegistrationUrl = null;
          _proofOfRegistrationName = null;
          break;
        case _DocSlot.academicTranscript:
          _academicTranscriptUrl = null;
          _academicTranscriptName = null;
          break;
        case _DocSlot.cv:
          _cvUrl = null;
          _cvName = null;
          break;
        case _DocSlot.matricCertificate:
          _matricCertificateUrl = null;
          _matricCertificateName = null;
          break;
      }
    });
  }

  Future<void> submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to update your profile."),
        ),
      );
      return;
    }

    final studentViewModel = Provider.of<StudentViewModel>(
      context,
      listen: false,
    );
    studentViewModel.setStudentId(user.id); // ✅ CRITICAL – set the ID

    studentViewModel.updateFirstName(firstNameController.text.trim());
    studentViewModel.updateLastName(lastNameController.text.trim());
    studentViewModel.updateStudentNumber(studentNumberController.text.trim());
    studentViewModel.updateCurrentYear(currentYearController.text.trim());
    studentViewModel.updateIdDocument(_idDocumentUrl ?? '');
    studentViewModel.updateProofOfRegistration(_proofOfRegistrationUrl ?? '');
    studentViewModel.updateAcademicTranscript(_academicTranscriptUrl ?? '');
    studentViewModel.updateCv(_cvUrl ?? '');
    studentViewModel.updateMatricCertificate(_matricCertificateUrl ?? '');

    setState(() => _isSubmitting = true);

    try {
      final service = StudentService();
      final existing = await service.getStudentById(user.id);

      if (existing == null) {
        await service.createStudent(studentViewModel.student);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student profile created successfully!"),
          ),
        );
      } else {
        await service.updateStudent(studentViewModel.student);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student profile updated successfully!"),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteManager.homeScreen);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDocPicker(
    _DocSlot slot,
    String? currentUrl,
    String? currentName,
  ) {
    final hasFile = currentUrl != null && currentUrl.isNotEmpty;
    final uploading = _uploadingSlots.contains(slot);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _slotLabel(slot),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  hasFile
                      ? Icons.check_circle
                      : Icons.insert_drive_file_outlined,
                  color: hasFile ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasFile ? (currentName ?? 'Uploaded') : 'No file selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: uploading ? null : () => _pickAndUpload(slot),
                  icon: uploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(hasFile ? Icons.refresh : Icons.upload_file),
                  label: Text(
                    uploading
                        ? 'Uploading...'
                        : (hasFile ? 'Replace File' : 'Choose File'),
                  ),
                ),
                if (hasFile && !uploading) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _clearSlot(slot),
                    icon: const Icon(Icons.clear, color: Colors.red),
                    label: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Student Profile"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: "First Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter first name"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: "Last Name",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter last name"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: studentNumberController,
                        decoration: const InputDecoration(
                          labelText: "Student Number",
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter student number"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: currentYearController,
                        decoration: const InputDecoration(
                          labelText: "Current Year",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter current year"
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Required Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Pick a file for each required document. Allowed: PDF, images, Word docs.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildDocPicker(
                _DocSlot.idDocument,
                _idDocumentUrl,
                _idDocumentName,
              ),
              _buildDocPicker(
                _DocSlot.proofOfRegistration,
                _proofOfRegistrationUrl,
                _proofOfRegistrationName,
              ),
              _buildDocPicker(
                _DocSlot.academicTranscript,
                _academicTranscriptUrl,
                _academicTranscriptName,
              ),
              _buildDocPicker(_DocSlot.cv, _cvUrl, _cvName),
              _buildDocPicker(
                _DocSlot.matricCertificate,
                _matricCertificateUrl,
                _matricCertificateName,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("SUBMIT", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "All documents are optional. You can upload them now or later.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
