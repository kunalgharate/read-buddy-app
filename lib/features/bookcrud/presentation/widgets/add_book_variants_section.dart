import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_variant_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/parent_book_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/variant_repository.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';

class LocalBookFormat {
  final String type; // 'hardcover', 'ebook', 'audiobook'
  final String? isbn;
  final int? copies;
  final bool? available;
  final String? fileName;
  final String? audioFileName;
  final int? duration;

  LocalBookFormat({
    required this.type,
    this.isbn,
    this.copies,
    this.available,
    this.fileName,
    this.audioFileName,
    this.duration,
  });
}

class LocalBookVariant {
  final String language;
  final List<LocalBookFormat> formats;

  LocalBookVariant({required this.language, required this.formats});
}

class AddBookVariantsSection extends StatefulWidget {
  final BookCrudModel bookCrudModel;
  final VoidCallback onBack;

  const AddBookVariantsSection({
    super.key,
    required this.bookCrudModel,
    required this.onBack,
  });

  @override
  State<AddBookVariantsSection> createState() => _AddBookVariantsSectionState();
}

class _AddBookVariantsSectionState extends State<AddBookVariantsSection> {
  final List<LocalBookVariant> _variants = [];
  bool _isAddingOrEditing = false;
  int? _editingIndex;

  // Form Fields for Add/Edit Variant
  String? _selectedLanguage;
  final List<String> _languages = ['english', 'hindi', 'marathi', 'tamil', 'malayalam'];

  bool _hasHardcover = false;
  bool _hasEbook = false;
  bool _hasAudiobook = false;

  // Hardcover sub-fields
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController(text: "1");
  bool _hardcoverAvailable = true;

  // Ebook sub-fields
  String? _ebookFileName;
  bool _ebookUploading = false;
  double _ebookUploadProgress = 0.0;

  // Audiobook sub-fields
  String? _audioFileName;
  bool _audioUploading = false;
  double _audioUploadProgress = 0.0;
  final TextEditingController _audioDurationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadExistingVariants();
  }

  Future<void> _loadExistingVariants() async {
    try {
      final repository = getIt<VariantRepository>();
      final bookId = widget.bookCrudModel.id ?? '';
      if (bookId.isNotEmpty && !bookId.startsWith('id-')) {
        final existingEntities = await repository.getVariantsForBook(bookId);
        if (existingEntities.isNotEmpty) {
          setState(() {
            _variants.clear();
            for (final entity in existingEntities) {
              final formats = entity.formats.map((f) => LocalBookFormat(
                type: f.type,
                isbn: f.isbn,
                copies: f.copies,
                available: f.available,
                fileName: f.fileName,
                audioFileName: f.audioFileName,
                duration: f.duration,
              )).toList();
              
              _variants.add(LocalBookVariant(
                language: entity.language,
                formats: formats,
              ));
            }
          });
        }
      }
    } catch (e) {
      print("Error loading existing variants: $e");
    }
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _copiesController.dispose();
    _audioDurationController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedLanguage = null;
      _hasHardcover = false;
      _hasEbook = false;
      _hasAudiobook = false;
      _isbnController.clear();
      _copiesController.text = "1";
      _hardcoverAvailable = true;
      _ebookFileName = null;
      _ebookUploading = false;
      _ebookUploadProgress = 0.0;
      _audioFileName = null;
      _audioUploading = false;
      _audioUploadProgress = 0.0;
      _audioDurationController.clear();
      _isAddingOrEditing = false;
      _editingIndex = null;
    });
  }

  void _startEdit(int index) {
    final variant = _variants[index];
    setState(() {
      _isAddingOrEditing = true;
      _editingIndex = index;
      _selectedLanguage = variant.language;
      _hasHardcover = false;
      _hasEbook = false;
      _hasAudiobook = false;

      for (final format in variant.formats) {
        if (format.type == 'hardcover') {
          _hasHardcover = true;
          _isbnController.text = format.isbn ?? '';
          _copiesController.text = (format.copies ?? 1).toString();
          _hardcoverAvailable = format.available ?? true;
        } else if (format.type == 'ebook') {
          _hasEbook = true;
          _ebookFileName = format.fileName;
        } else if (format.type == 'audiobook') {
          _hasAudiobook = true;
          _audioFileName = format.audioFileName;
          _audioDurationController.text = (format.duration ?? 0).toString();
        }
      }
    });
  }

  Future<void> _simulateUpload(bool isEbook, String fileName) async {
    // Validate file extensions
    final extension = fileName.toLowerCase().split('.').last;
    if (isEbook) {
      if (extension != 'pdf' && extension != 'epub') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid E-Book format! Only PDF or EPUB files are supported.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        _ebookUploading = true;
        _ebookUploadProgress = 0.0;
        _ebookFileName = fileName;
      });
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        setState(() {
          _ebookUploadProgress = i * 0.1;
        });
      }
      setState(() {
        _ebookUploading = false;
      });
    } else {
      if (extension != 'mp3' && extension != 'wav' && extension != 'm4a') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Audio format! Only MP3, WAV or M4A are supported.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        _audioUploading = true;
        _audioUploadProgress = 0.0;
        _audioFileName = fileName;
      });
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        setState(() {
          _audioUploadProgress = i * 0.1;
        });
      }
      setState(() {
        _audioUploading = false;
      });
    }
  }

  void _showSimulatedPicker(bool isEbook) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isEbook ? Icons.book_online_rounded : Icons.headphones_rounded, color: const Color(0xFF042153)),
            const SizedBox(width: 10),
            Text(
              isEbook ? 'Upload E-Book File' : 'Upload Audiobook Track',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF042153)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a preset file:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: isEbook
                  ? [
                      ActionChip(
                        label: const Text('AtomicHabits.epub'),
                        onPressed: () {
                          Navigator.pop(context);
                          _simulateUpload(true, 'AtomicHabits.epub');
                        },
                      ),
                      ActionChip(
                        label: const Text('DesignPatterns.pdf'),
                        onPressed: () {
                          Navigator.pop(context);
                          _simulateUpload(true, 'DesignPatterns.pdf');
                        },
                      ),
                    ]
                  : [
                      ActionChip(
                        label: const Text('Chapter1.mp3'),
                        onPressed: () {
                          Navigator.pop(context);
                          _simulateUpload(false, 'Chapter1.mp3');
                        },
                      ),
                      ActionChip(
                        label: const Text('Intro.wav'),
                        onPressed: () {
                          Navigator.pop(context);
                          _simulateUpload(false, 'Intro.wav');
                        },
                      ),
                    ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Or enter custom filename:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Filename',
                hintText: isEbook ? 'e.g. guide.pdf' : 'e.g. narration.mp3',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF042153)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF042153),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final file = controller.text.trim();
                Navigator.pop(context);
                _simulateUpload(isEbook, file);
              }
            },
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveVariant() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a variant language'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    if (!_hasHardcover && !_hasEbook && !_hasAudiobook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one format option'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    if (_hasEbook && _ebookFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an E-Book file'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    if (_hasAudiobook && _audioFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an Audiobook audio file'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    final List<LocalBookFormat> formats = [];
    if (_hasHardcover) {
      formats.add(LocalBookFormat(
        type: 'hardcover',
        isbn: _isbnController.text.trim(),
        copies: int.tryParse(_copiesController.text.trim()) ?? 1,
        available: _hardcoverAvailable,
      ));
    }
    if (_hasEbook) {
      formats.add(LocalBookFormat(
        type: 'ebook',
        fileName: _ebookFileName,
      ));
    }
    if (_hasAudiobook) {
      formats.add(LocalBookFormat(
        type: 'audiobook',
        audioFileName: _audioFileName,
        duration: int.tryParse(_audioDurationController.text.trim()) ?? 0,
      ));
    }

    final newVariant = LocalBookVariant(
      language: _selectedLanguage!,
      formats: formats,
    );

    setState(() {
      if (_editingIndex != null) {
        _variants[_editingIndex!] = newVariant;
      } else {
        _variants.add(newVariant);
      }
      _resetForm();
    });
  }

  Future<void> _submitBook(bool isDraft) async {
    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one language variant before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final bookId = widget.bookCrudModel.id ?? 'book_${DateTime.now().millisecondsSinceEpoch}';
    final bool isExistingBook = widget.bookCrudModel.id != null &&
        widget.bookCrudModel.id!.isNotEmpty &&
        !widget.bookCrudModel.id!.startsWith('id-');
    
    // 1. Create and populate parent book entity
    final parentBook = ParentBookEntity(
      id: bookId,
      title: widget.bookCrudModel.title,
      author: widget.bookCrudModel.author,
      publisher: widget.bookCrudModel.publisher,
      description: widget.bookCrudModel.description,
      coverImageUrl: widget.bookCrudModel.coverImageUrl,
      coversingleImage: widget.bookCrudModel.coversingleImage,
      categories: [widget.bookCrudModel.category],
      tags: widget.bookCrudModel.tags,
      status: isDraft ? 'Draft' : 'Published',
    );

    try {
      final repository = getIt<VariantRepository>();
      
      // Save Parent book details
      await repository.saveParentBook(parentBook);

      // 2. Create and populate variant entities
      for (final localVariant in _variants) {
        final formats = localVariant.formats.map((f) => BookFormatEntity(
          type: f.type,
          isbn: f.isbn,
          copies: f.copies,
          available: f.available,
          fileUrl: f.type == 'ebook' ? 'https://mock-s3.com/ebooks/${f.fileName}' : null,
          fileName: f.fileName,
          audioUrl: f.type == 'audiobook' ? 'https://mock-s3.com/audio/${f.audioFileName}' : null,
          audioFileName: f.audioFileName,
          duration: f.duration,
        )).toList();

        final variant = BookVariantEntity(
          id: 'var_${localVariant.language}_${DateTime.now().millisecondsSinceEpoch}',
          bookId: bookId,
          language: localVariant.language,
          formats: formats,
        );
        
        await repository.saveVariant(variant);
      }

      if (isExistingBook) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isDraft
                  ? 'Book "${parentBook.title}" variants saved as Draft successfully!'
                  : 'Book "${parentBook.title}" variants published successfully!'),
              backgroundColor: isDraft ? Colors.orange[800] : Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Save parent book using existing BLoC
        context.read<BookCrudBloc>().add(AddBookCrudEvent(widget.bookCrudModel));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isDraft
                  ? 'Book "${parentBook.title}" and its variants saved as Draft successfully!'
                  : 'Book "${parentBook.title}" and its variants published successfully!'),
              backgroundColor: isDraft ? Colors.orange[800] : Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving variants: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Book Preview Card
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  height: 90,
                  width: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: widget.bookCrudModel.coversingleImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(widget.bookCrudModel.coversingleImage!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.book_rounded, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF042153).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PARENT BOOK METADATA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF042153)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.bookCrudModel.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF042153)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${widget.bookCrudModel.author}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (!_isAddingOrEditing) ...[
          // Variants List & Dashboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Language Variants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF042153)),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isAddingOrEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 1,
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                label: const Text('Add Variant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVariantsList(),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back', style: TextStyle(color: Color(0xFF042153), fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitBook(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[850],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: const Text('Save Draft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitBook(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: const Text('Publish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ] else ...[
          // Add/Edit Form section
          Card(
            elevation: 1.5,
            shadowColor: Colors.black12,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _editingIndex != null ? Icons.edit_note_rounded : Icons.translate_rounded,
                          color: const Color(0xFF042153),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _editingIndex != null ? 'Edit Language Variant' : 'Add Language Variant',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF042153)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Language *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF042153))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.language_rounded, color: Colors.grey, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF042153)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                      items: _languages.map((lang) {
                        final isAlreadyAdded = _variants.any(
                          (v) => v.language == lang && (_editingIndex == null || _variants[_editingIndex!].language != lang),
                        );
                        return DropdownMenuItem<String>(
                          value: lang,
                          enabled: !isAlreadyAdded,
                          child: Text(
                            lang.toUpperCase() + (isAlreadyAdded ? ' (Already Added)' : ''),
                            style: TextStyle(
                              color: isAlreadyAdded ? Colors.grey : const Color(0xFF042153),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _editingIndex != null ? null : (val) => setState(() => _selectedLanguage = val),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Please select a language';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildFormatSelectors(),
                    const SizedBox(height: 20),

                    // Hardcover forms
                    if (_hasHardcover) ...[
                      const Divider(height: 32),
                      const Text(
                        'Hardcover Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _isbnController,
                        decoration: InputDecoration(
                          labelText: 'ISBN Number *',
                          prefixIcon: const Icon(Icons.qr_code_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => _hasHardcover && (val == null || val.isEmpty) ? 'ISBN is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildCopiesSelector(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Instantly Available for Requests',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                          Switch(
                            value: _hardcoverAvailable,
                            activeColor: const Color(0xFF4F46E5),
                            onChanged: (val) => setState(() => _hardcoverAvailable = val),
                          ),
                        ],
                      ),
                    ],

                    // E-book form
                    if (_hasEbook) ...[
                      const Divider(height: 32),
                      const Text(
                        'E-Book File Upload',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D9488)),
                      ),
                      const SizedBox(height: 16),
                      _buildSimulatedUploadCard(
                        isEbook: true,
                        label: 'E-Book',
                        fileName: _ebookFileName,
                        uploading: _ebookUploading,
                        progress: _ebookUploadProgress,
                        onSelect: () => _showSimulatedPicker(true),
                        onClear: () => setState(() {
                          _ebookFileName = null;
                          _ebookUploading = false;
                        }),
                        accentColor: const Color(0xFF0D9488),
                      ),
                    ],

                    // Audiobook form
                    if (_hasAudiobook) ...[
                      const Divider(height: 32),
                      const Text(
                        'Audiobook Audio Track',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFD97706)),
                      ),
                      const SizedBox(height: 16),
                      _buildSimulatedUploadCard(
                        isEbook: false,
                        label: 'Audiobook',
                        fileName: _audioFileName,
                        uploading: _audioUploading,
                        progress: _audioUploadProgress,
                        onSelect: () => _showSimulatedPicker(false),
                        onClear: () => setState(() {
                          _audioFileName = null;
                          _audioUploading = false;
                        }),
                        accentColor: const Color(0xFFD97706),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _audioDurationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Track Duration (in seconds) *',
                          prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (_hasAudiobook) {
                            if (val == null || val.isEmpty) return 'Duration is required';
                            if (int.tryParse(val) == null) return 'Must be a valid integer';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _resetForm,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF042153),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _saveVariant,
                          icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                          label: const Text('Save Variant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? activeColor.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? activeColor : Colors.grey.shade200,
              width: selected ? 2.2 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? activeColor.withOpacity(0.12) : Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: selected ? activeColor : Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
                  if (selected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: activeColor,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: selected ? activeColor : Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Content Formats *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF042153)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFormatCard(
              title: 'Hardcover',
              subtitle: 'Physical book',
              icon: Icons.menu_book_rounded,
              selected: _hasHardcover,
              activeColor: const Color(0xFF4F46E5), // Indigo
              onTap: () => setState(() => _hasHardcover = !_hasHardcover),
            ),
            const SizedBox(width: 8),
            _buildFormatCard(
              title: 'E-Book',
              subtitle: 'PDF / EPUB',
              icon: Icons.book_online_rounded,
              selected: _hasEbook,
              activeColor: const Color(0xFF0D9488), // Teal
              onTap: () => setState(() => _hasEbook = !_hasEbook),
            ),
            const SizedBox(width: 8),
            _buildFormatCard(
              title: 'Audiobook',
              subtitle: 'MP3 / WAV',
              icon: Icons.headphones_rounded,
              selected: _hasAudiobook,
              activeColor: const Color(0xFFD97706), // Amber
              onTap: () => setState(() => _hasAudiobook = !_hasAudiobook),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCopiesSelector() {
    return Row(
      children: [
        const Text(
          'Number of Copies *',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF042153)),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: () {
                  int val = int.tryParse(_copiesController.text) ?? 1;
                  if (val > 1) {
                    setState(() {
                      _copiesController.text = (val - 1).toString();
                    });
                  }
                },
              ),
              SizedBox(
                width: 50,
                child: TextFormField(
                  controller: _copiesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  validator: (val) {
                    if (_hasHardcover) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () {
                  int val = int.tryParse(_copiesController.text) ?? 1;
                  setState(() {
                    _copiesController.text = (val + 1).toString();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatedUploadCard({
    required bool isEbook,
    required String label,
    required String? fileName,
    required bool uploading,
    required double progress,
    required VoidCallback onSelect,
    required VoidCallback onClear,
    required Color accentColor,
  }) {
    return DashedContainer(
      color: fileName != null ? accentColor : Colors.grey.shade400,
      borderRadius: 12,
      onTap: uploading ? null : (fileName == null ? onSelect : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: fileName != null ? accentColor.withOpacity(0.01) : Colors.grey.shade50,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        width: double.infinity,
        child: uploading
            ? Column(
                children: [
                  Row(
                    children: [
                      Icon(isEbook ? Icons.picture_as_pdf_rounded : Icons.audiotrack_rounded, color: accentColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploading $label...',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(progress * 100).toInt()}% • ${(2.4 * progress).toStringAsFixed(1)} MB/s',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: onClear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      color: accentColor,
                      backgroundColor: accentColor.withOpacity(0.1),
                      minHeight: 5,
                    ),
                  ),
                ],
              )
            : (fileName != null
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isEbook ? Icons.document_scanner_rounded : Icons.music_note_rounded, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF042153)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEbook ? 'Format: ${fileName.split('.').last.toUpperCase()} • 12.4 MB' : 'Format: ${fileName.split('.').last.toUpperCase()} • 8.6 MB',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: onClear,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        isEbook ? Icons.cloud_upload_outlined : Icons.audio_file_outlined,
                        size: 36,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Select $label File',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF042153)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEbook ? 'Supports PDF, EPUB up to 25MB' : 'Supports MP3, WAV, M4A up to 50MB',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  )),
      ),
    );
  }

  Widget _buildVariantsList() {
    if (_variants.isEmpty) {
      return DashedContainer(
        color: Colors.grey.shade300,
        borderRadius: 16,
        child: Container(
          height: 160,
          width: double.infinity,
          color: Colors.grey.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.translate_rounded, size: 36, color: Colors.green),
              ),
              const SizedBox(height: 12),
              const Text(
                'No language variants added yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF042153)),
              ),
              const SizedBox(height: 4),
              Text(
                'Add at least one variant before publishing the book.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _variants.length,
      itemBuilder: (context, index) {
        final variant = _variants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 1.5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1.2),
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language_rounded, color: Colors.blue, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      variant.language.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF042153)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      onPressed: () => _startEdit(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          _variants.removeAt(index);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Formats list details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: variant.formats.map((format) {
                    Color accentColor;
                    IconData icon;
                    String details = '';
                    
                    if (format.type == 'hardcover') {
                      accentColor = const Color(0xFF4F46E5);
                      icon = Icons.menu_book_rounded;
                      details = 'ISBN: ${format.isbn} • Copies: ${format.copies} • Available: ${format.available == true ? "Yes" : "No"}';
                    } else if (format.type == 'ebook') {
                      accentColor = const Color(0xFF0D9488);
                      icon = Icons.book_online_rounded;
                      details = 'File: ${format.fileName}';
                    } else {
                      accentColor = const Color(0xFFD97706);
                      icon = Icons.headphones_rounded;
                      details = 'Track: ${format.audioFileName} • Duration: ${format.duration}s';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: accentColor, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  format.type.toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: accentColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  details,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
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
      },
    );
  }
}

class DashedContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;
  final VoidCallback? onTap;

  const DashedContainer({
    super.key,
    required this.child,
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.borderRadius = 12.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: color,
          strokeWidth: strokeWidth,
          gap: gap,
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    for (final metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length) {
        final end = start + gap;
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
