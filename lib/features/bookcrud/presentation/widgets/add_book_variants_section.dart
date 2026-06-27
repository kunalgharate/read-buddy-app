import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_variant_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/user_repo.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/variant/variant_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/variant/variant_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/variant/variant_state.dart';

/// Represents a picked file (not yet uploaded — will be sent with variant creation).
class PickedFileItem {
  final File file;
  final String fileName;

  PickedFileItem({required this.file, required this.fileName});
}

class LocalBookFormat {
  final String type; // 'hardcover', 'ebook', 'audiobook', 'videobook'
  final String? id; // MongoDB _id if loaded from server
  final String? isbn;
  final int? copies;
  final bool? available;
  final List<PickedFileItem> ebookFiles; // PDF/EPUB files for ebook
  final List<PickedFileItem> audioFiles; // MP3/WAV/M4A files for audiobook
  final List<AudioPartMeta> audioParts; // part metadata (title) for audiobook
  final List<PickedFileItem> videoFiles; // MP4/WEBM files for videobook
  final List<AudioPartMeta> videoParts; // part metadata for videobook

  LocalBookFormat({
    required this.type,
    this.id,
    this.isbn,
    this.copies,
    this.available,
    this.ebookFiles = const [],
    this.audioFiles = const [],
    this.audioParts = const [],
    this.videoFiles = const [],
    this.videoParts = const [],
  });
}

/// Metadata for each audio part (title + matched file).
class AudioPartMeta {
  final int partNumber;
  String title;
  PickedFileItem? file;
  final bool isFromServer; // true if already uploaded on server

  AudioPartMeta({
    required this.partNumber,
    required this.title,
    this.file,
    this.isFromServer = false,
  });
}

class LocalBookVariant {
  final String language;
  final List<LocalBookFormat> formats;
  final String? donatorInfo; // donor _id
  final String? donatorName; // donor display name
  final String? existingVariantId; // non-null if loaded from server
  final bool isDirty; // true if user modified this variant in current session

  LocalBookVariant({
    required this.language,
    required this.formats,
    this.donatorInfo,
    this.donatorName,
    this.existingVariantId,
    this.isDirty = false,
  });

  LocalBookVariant copyWithDirty(bool dirty) => LocalBookVariant(
        language: language,
        formats: formats,
        donatorInfo: donatorInfo,
        donatorName: donatorName,
        existingVariantId: existingVariantId,
        isDirty: dirty,
      );
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

  // Form Fields
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _variantIsbnController = TextEditingController();

  // Donor search state
  String? _selectedDonorId;
  String? _selectedDonorName;
  List<UserEntity> _donorSearchResults = [];
  bool _isDonorSearching = false;
  Timer? _donorDebounce;

  bool _hasHardcover = false;
  bool _hasEbook = false;
  bool _hasAudiobook = false;
  bool _hasVideobook = false;

  // Track formats already on server (don't require re-uploading files)
  bool _ebookExistsOnServer = false;

  // Hardcover sub-fields
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _copiesController =
      TextEditingController(text: "1");
  bool _hardcoverAvailable = true;

  // Ebook — multiple files (PDF/EPUB)
  List<PickedFileItem> _ebookFiles = [];

  // Audiobook — parts with matched files
  List<AudioPartMeta> _audioParts = [];

  // Videobook — parts with matched files
  List<AudioPartMeta> _videoParts = [];

  // Donor search
  final TextEditingController _donorSearchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingVariants();
  }

  Future<void> _loadExistingVariants() async {
    final bookId = widget.bookCrudModel.id ?? '';
    if (bookId.isNotEmpty && !bookId.startsWith('id-')) {
      context.read<VariantBloc>().add(LoadVariants(bookId));
    }
  }

  @override
  void dispose() {
    _languageController.dispose();
    _variantIsbnController.dispose();
    _donorSearchController.dispose();
    _donorDebounce?.cancel();
    _isbnController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _languageController.clear();
      _variantIsbnController.clear();
      _selectedDonorId = null;
      _selectedDonorName = null;
      _donorSearchResults = [];
      _isDonorSearching = false;
      _hasHardcover = false;
      _hasEbook = false;
      _hasAudiobook = false;
      _hasVideobook = false;
      _ebookExistsOnServer = false;
      _isbnController.clear();
      _copiesController.text = "1";
      _hardcoverAvailable = true;
      _ebookFiles = [];
      _audioParts = [];
      _videoParts = [];
      _isAddingOrEditing = false;
      _editingIndex = null;
    });
  }

  void _startEdit(int index) {
    final variant = _variants[index];
    setState(() {
      _isAddingOrEditing = true;
      _editingIndex = index;
      _languageController.text = variant.language;
      _selectedDonorId = variant.donatorInfo;
      _selectedDonorName = variant.donatorName ?? variant.donatorInfo;
      _donorSearchResults = [];
      _hasHardcover = false;
      _hasEbook = false;
      _hasAudiobook = false;
      _hasVideobook = false;
      _ebookExistsOnServer = false;
      _ebookFiles = [];
      _audioParts = [];
      _videoParts = [];

      for (final format in variant.formats) {
        if (format.type == 'hardcover') {
          _hasHardcover = true;
          _isbnController.text = format.isbn ?? '';
          _copiesController.text = (format.copies ?? 1).toString();
          _hardcoverAvailable = format.available ?? true;
        } else if (format.type == 'ebook') {
          _hasEbook = true;
          _ebookFiles = List.from(format.ebookFiles);
          // If loaded from server, ebookFiles will be empty — mark as existing
          if (format.ebookFiles.isEmpty && variant.existingVariantId != null) {
            _ebookExistsOnServer = true;
          }
        } else if (format.type == 'audiobook') {
          _hasAudiobook = true;
          _audioParts = List.from(format.audioParts);
        } else if (format.type == 'videobook') {
          _hasVideobook = true;
          _videoParts = List.from(format.videoParts);
        }
      }
    });
  }

  // ─── File Picking ───────────────────────────────────────────────────────

  Future<void> _pickEbookFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        for (final platformFile in result.files) {
          if (platformFile.path == null) continue;
          final file = File(platformFile.path!);
          if (!file.existsSync()) continue;
          final alreadyAdded =
              _ebookFiles.any((f) => f.fileName == platformFile.name);
          if (!alreadyAdded) {
            _ebookFiles.add(PickedFileItem(
              file: file,
              fileName: platformFile.name,
            ));
          }
        }
      });
    } catch (e) {
      _showSnackBar('Error picking files: $e', Colors.redAccent);
    }
  }

  Future<void> _pickAudioFileForPart(int partIndex) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;
      final platformFile = result.files.first;
      if (platformFile.path == null) return;

      setState(() {
        _audioParts[partIndex].file = PickedFileItem(
          file: File(platformFile.path!),
          fileName: platformFile.name,
        );
      });
    } catch (e) {
      debugPrint('❌ Audio picker error: $e');
      _showSnackBar('Error picking audio file: $e', Colors.redAccent);
    }
  }

  Future<void> _pickVideoFileForPart(int partIndex) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'webm', 'mkv', 'avi'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;
      final platformFile = result.files.first;
      if (platformFile.path == null) return;

      setState(() {
        _videoParts[partIndex].file = PickedFileItem(
          file: File(platformFile.path!),
          fileName: platformFile.name,
        );
      });
    } catch (e) {
      debugPrint('❌ Video picker error: $e');
      _showSnackBar('Error picking video file: $e', Colors.redAccent);
    }
  }

  void _addAudioPart() {
    setState(() {
      _audioParts.add(AudioPartMeta(
        partNumber: _audioParts.length + 1,
        title: '',
      ));
    });
  }

  void _removeAudioPart(int index) {
    setState(() {
      _audioParts.removeAt(index);
      for (int i = 0; i < _audioParts.length; i++) {
        _audioParts[i] = AudioPartMeta(
          partNumber: i + 1,
          title: _audioParts[i].title,
          file: _audioParts[i].file,
        );
      }
    });
  }

  void _addVideoPart() {
    setState(() {
      _videoParts.add(AudioPartMeta(
        partNumber: _videoParts.length + 1,
        title: '',
      ));
    });
  }

  void _removeVideoPart(int index) {
    setState(() {
      _videoParts.removeAt(index);
      for (int i = 0; i < _videoParts.length; i++) {
        _videoParts[i] = AudioPartMeta(
          partNumber: i + 1,
          title: _videoParts[i].title,
          file: _videoParts[i].file,
        );
      }
    });
  }

  void _removeEbookFile(int index) {
    setState(() => _ebookFiles.removeAt(index));
  }

  // ─── Save Variant ──────────────────────────────────────────────────────

  void _saveVariant() {
    if (!_formKey.currentState!.validate()) return;

    final language = _languageController.text.trim();
    if (language.isEmpty) {
      _showSnackBar('Please enter a language', Colors.orangeAccent);
      return;
    }

    if (!_hasHardcover && !_hasEbook && !_hasAudiobook && !_hasVideobook) {
      _showSnackBar(
          'Please select at least one format option', Colors.orangeAccent);
      return;
    }

    if (_hasEbook && _ebookFiles.isEmpty && !_ebookExistsOnServer) {
      _showSnackBar('Please select at least one E-Book file (PDF/EPUB)',
          Colors.orangeAccent);
      return;
    }

    if (_hasAudiobook) {
      if (_audioParts.isEmpty) {
        _showSnackBar(
            'Please add at least one audio part', Colors.orangeAccent);
        return;
      }
      // Only require files for NEW parts (not ones already on server)
      final newPartsWithoutFiles =
          _audioParts.where((p) => !p.isFromServer && p.file == null).toList();
      if (newPartsWithoutFiles.isNotEmpty) {
        _showSnackBar(
            'Please select audio files for new parts', Colors.orangeAccent);
        return;
      }
      final missingTitles =
          _audioParts.where((p) => p.title.trim().isEmpty).toList();
      if (missingTitles.isNotEmpty) {
        _showSnackBar(
            'Please enter titles for all audio parts', Colors.orangeAccent);
        return;
      }
    }

    if (_hasVideobook) {
      if (_videoParts.isEmpty) {
        _showSnackBar(
            'Please add at least one video part', Colors.orangeAccent);
        return;
      }
      final newPartsWithoutFiles =
          _videoParts.where((p) => !p.isFromServer && p.file == null).toList();
      if (newPartsWithoutFiles.isNotEmpty) {
        _showSnackBar(
            'Please select video files for new parts', Colors.orangeAccent);
        return;
      }
      final missingTitles =
          _videoParts.where((p) => p.title.trim().isEmpty).toList();
      if (missingTitles.isNotEmpty) {
        _showSnackBar(
            'Please enter titles for all video parts', Colors.orangeAccent);
        return;
      }
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
        ebookFiles: List.from(_ebookFiles),
      ));
    }
    if (_hasAudiobook) {
      formats.add(LocalBookFormat(
        type: 'audiobook',
        audioParts: List.from(_audioParts),
        audioFiles: _audioParts
            .where((p) => p.file != null)
            .map((p) => p.file!)
            .toList(),
      ));
    }
    if (_hasVideobook) {
      formats.add(LocalBookFormat(
        type: 'videobook',
        videoParts: List.from(_videoParts),
        videoFiles: _videoParts
            .where((p) => p.file != null)
            .map((p) => p.file!)
            .toList(),
      ));
    }

    final newVariant = LocalBookVariant(
      language: language,
      formats: formats,
      donatorInfo: _selectedDonorId,
      donatorName: _selectedDonorName,
      // Preserve existingVariantId when editing
      existingVariantId: _editingIndex != null
          ? _variants[_editingIndex!].existingVariantId
          : null,
      isDirty: true, // Mark as modified — needs submission
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

  // ─── Submit Book ───────────────────────────────────────────────────────

  Future<void> _submitBook(bool isDraft) async {
    if (_variants.isEmpty) {
      _showSnackBar(
        'Please add at least one language variant before submitting.',
        Colors.redAccent,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final bookId = widget.bookCrudModel.id ??
        'book_${DateTime.now().millisecondsSinceEpoch}';
    final bool isExistingBook = widget.bookCrudModel.id != null &&
        widget.bookCrudModel.id!.isNotEmpty &&
        !widget.bookCrudModel.id!.startsWith('id-');

    try {
      final variantBloc = context.read<VariantBloc>();

      if (!isExistingBook) {
        // Save parent book first
        context
            .read<BookCrudBloc>()
            .add(AddBookCrudEvent(widget.bookCrudModel));
      }

      for (final localVariant in _variants) {
        // Only submit variants that were modified in this session
        if (!localVariant.isDirty) continue;

        // Validate all files still exist before uploading
        bool filesValid = true;
        for (final f in localVariant.formats) {
          if (f.type == 'ebook') {
            for (final pf in f.ebookFiles) {
              if (!pf.file.existsSync()) {
                filesValid = false;
                _showSnackBar(
                    'File "${pf.fileName}" expired. Please re-select it.',
                    Colors.redAccent);
                break;
              }
            }
          } else if (f.type == 'audiobook') {
            for (final p in f.audioParts) {
              // Skip parts already uploaded on server — they have no local file
              if (p.isFromServer) continue;
              if (p.file != null && !p.file!.file.existsSync()) {
                filesValid = false;
                _showSnackBar(
                    'Audio file "${p.file!.fileName}" expired. Please re-select.',
                    Colors.redAccent);
                break;
              }
            }
          } else if (f.type == 'videobook') {
            for (final p in f.videoParts) {
              // Skip parts already uploaded on server — they have no local file
              if (p.isFromServer) continue;
              if (p.file != null && !p.file!.file.existsSync()) {
                filesValid = false;
                _showSnackBar(
                    'Video file "${p.file!.fileName}" expired. Please re-select.',
                    Colors.redAccent);
                break;
              }
            }
          }
          if (!filesValid) break;
        }
        if (!filesValid) {
          setState(() => _isSubmitting = false);
          return;
        }

        // Collect files for this variant
        List<File> ebookFiles = [];
        List<File> audioParts = [];
        List<File> videoParts = [];

        // Build format entities and collect files
        final formats = <BookFormatEntity>[];

        for (final f in localVariant.formats) {
          if (f.type == 'ebook' && f.ebookFiles.isNotEmpty) {
            ebookFiles = f.ebookFiles.map((pf) => pf.file).toList();
            formats.add(BookFormatEntity(
                type: 'ebook', donorId: localVariant.donatorInfo));
          } else if (f.type == 'audiobook' &&
              f.audioParts.any((p) => p.file != null)) {
            audioParts = f.audioParts
                .where((p) => p.file != null)
                .map((p) => p.file!.file)
                .toList();
            final parts = f.audioParts
                .where((p) => p.file != null)
                .map((p) => MediaPartEntity(
                      partNumber: p.partNumber,
                      title: p.title,
                      duration: 0,
                    ))
                .toList();
            formats.add(BookFormatEntity(
                type: 'audiobook',
                donorId: localVariant.donatorInfo,
                parts: parts));
          } else if (f.type == 'videobook' &&
              f.videoParts.any((p) => p.file != null)) {
            videoParts = f.videoParts
                .where((p) => p.file != null)
                .map((p) => p.file!.file)
                .toList();
            final parts = f.videoParts
                .where((p) => p.file != null)
                .map((p) => MediaPartEntity(
                      partNumber: p.partNumber,
                      title: p.title,
                      duration: 0,
                    ))
                .toList();
            formats.add(BookFormatEntity(
                type: 'videobook',
                donorId: localVariant.donatorInfo,
                parts: parts));
          } else if (f.type == 'hardcover' || f.type == 'paperback') {
            // Physical books — always include (no files needed)
            formats.add(BookFormatEntity(
              type: f.type,
              donorId: localVariant.donatorInfo,
              isbn: f.isbn,
              copies: f.copies,
              availableCopies: (f.available == true) ? (f.copies ?? 1) : 0,
            ));
          }
        }

        // Skip if no formats to submit
        if (formats.isEmpty) continue;

        if (localVariant.existingVariantId != null &&
            localVariant.existingVariantId!.isNotEmpty) {
          // Existing variant — decide whether to add new format types
          // or add parts to existing formats.

          // Separate formats into: new types (no server ID) vs existing (has server ID)
          for (final f in localVariant.formats) {
            final hasServerFormatId = f.id != null && f.id!.isNotEmpty;

            if (f.type == 'ebook' && f.ebookFiles.isNotEmpty) {
              if (hasServerFormatId) {
                // Add ebook files to existing format
                variantBloc.add(AddPartsToFormatEvent(
                  variantId: localVariant.existingVariantId!,
                  formatId: f.id!,
                  bookId: bookId,
                  ebookFiles: f.ebookFiles.map((pf) => pf.file).toList(),
                ));
              } else {
                // New ebook format — use AddFormatEvent
                variantBloc.add(AddFormatEvent(
                  localVariant.existingVariantId!,
                  bookId,
                  [BookFormatEntity(type: 'ebook', donorId: localVariant.donatorInfo)],
                  ebookFiles: f.ebookFiles.map((pf) => pf.file).toList(),
                ));
              }
            } else if (f.type == 'audiobook') {
              final newParts = f.audioParts.where((p) => !p.isFromServer && p.file != null).toList();
              if (newParts.isEmpty) continue;

              final audioFiles = newParts.map((p) => p.file!.file).toList();
              final parts = newParts
                  .map((p) => MediaPartEntity(
                        partNumber: p.partNumber,
                        title: p.title,
                        duration: 0,
                      ))
                  .toList();

              if (hasServerFormatId) {
                // Add parts to existing audiobook format
                variantBloc.add(AddPartsToFormatEvent(
                  variantId: localVariant.existingVariantId!,
                  formatId: f.id!,
                  bookId: bookId,
                  parts: parts,
                  audioParts: audioFiles,
                ));
              } else {
                // New audiobook format
                variantBloc.add(AddFormatEvent(
                  localVariant.existingVariantId!,
                  bookId,
                  [BookFormatEntity(type: 'audiobook', donorId: localVariant.donatorInfo, parts: parts)],
                  audioParts: audioFiles,
                ));
              }
            } else if (f.type == 'videobook') {
              final newParts = f.videoParts.where((p) => !p.isFromServer && p.file != null).toList();
              if (newParts.isEmpty) continue;

              final videoFiles = newParts.map((p) => p.file!.file).toList();
              final parts = newParts
                  .map((p) => MediaPartEntity(
                        partNumber: p.partNumber,
                        title: p.title,
                        duration: 0,
                      ))
                  .toList();

              if (hasServerFormatId) {
                // Add parts to existing videobook format
                variantBloc.add(AddPartsToFormatEvent(
                  variantId: localVariant.existingVariantId!,
                  formatId: f.id!,
                  bookId: bookId,
                  parts: parts,
                  videoParts: videoFiles,
                ));
              } else {
                // New videobook format
                variantBloc.add(AddFormatEvent(
                  localVariant.existingVariantId!,
                  bookId,
                  [BookFormatEntity(type: 'videobook', donorId: localVariant.donatorInfo, parts: parts)],
                  videoParts: videoFiles,
                ));
              }
            } else if (f.type == 'hardcover' || f.type == 'paperback') {
              // Physical format — only add if new (not already on server)
              if (!hasServerFormatId) {
                variantBloc.add(AddFormatEvent(
                  localVariant.existingVariantId!,
                  bookId,
                  [BookFormatEntity(
                    type: f.type,
                    donorId: localVariant.donatorInfo,
                    isbn: f.isbn,
                    copies: f.copies,
                    availableCopies: (f.available == true) ? (f.copies ?? 1) : 0,
                  )],
                ));
              }
            }
          }
        } else {
          // New variant — create it with all formats
          final variant = BookVariantEntity(
            id: '',
            bookId: bookId,
            language: localVariant.language,
            donorId: localVariant.donatorInfo,
            formats: formats,
          );

          variantBloc.add(CreateVariantEvent(
            variant,
            ebookFiles: ebookFiles,
            audioParts: audioParts,
            videoParts: videoParts,
          ));
        }
      }

      if (mounted) {
        _showSnackBar(
          isDraft ? 'Submitting draft...' : 'Publishing variants...',
          Colors.blue,
        );
        // Don't navigate — BlocListener handles success/error
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saving variants: $e', Colors.red);
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _confirmDeleteVariant(int index) {
    final variant = _variants[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Variant'),
        content: Text(
            'Are you sure you want to delete the "${variant.language}" variant? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // If it exists on server, call API to delete
              if (variant.existingVariantId != null &&
                  variant.existingVariantId!.isNotEmpty) {
                final bookId = widget.bookCrudModel.id ?? '';
                context.read<VariantBloc>().add(
                      DeleteVariantEvent(variant.existingVariantId!, bookId),
                    );
              }
              setState(() => _variants.removeAt(index));
              _showSnackBar('Variant deleted', Colors.green);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<VariantBloc, VariantState>(
      listener: (context, state) {
        if (state is VariantsLoaded && _variants.isEmpty) {
          setState(() {
            for (final entity in state.variants) {
              final formats = entity.formats.map((f) {
                if (f.type == 'ebook') {
                  return LocalBookFormat(type: f.type, id: f.id, ebookFiles: []);
                } else if (f.type == 'audiobook') {
                  final parts = f.parts
                      .map((p) => AudioPartMeta(
                            partNumber: p.partNumber,
                            title: p.title,
                            isFromServer: true,
                          ))
                      .toList();
                  return LocalBookFormat(type: f.type, id: f.id, audioParts: parts);
                } else if (f.type == 'videobook') {
                  final parts = f.parts
                      .map((p) => AudioPartMeta(
                            partNumber: p.partNumber,
                            title: p.title,
                            isFromServer: true,
                          ))
                      .toList();
                  return LocalBookFormat(type: f.type, id: f.id, videoParts: parts);
                } else {
                  return LocalBookFormat(
                    type: f.type,
                    id: f.id,
                    isbn: f.isbn,
                    copies: f.copies,
                    available: (f.availableCopies ?? 0) > 0,
                  );
                }
              }).toList();

              _variants.add(LocalBookVariant(
                language: entity.language,
                formats: formats,
                donatorInfo: entity.donorId,
                donatorName: entity.donorName,
                existingVariantId: entity.id,
              ));
            }
          });
        } else if (state is VariantCreated) {
          setState(() => _isSubmitting = false);
          _showSnackBar('Variant created successfully!', Colors.green);
          Navigator.pop(context);
        } else if (state is FormatAdded) {
          setState(() => _isSubmitting = false);
          _showSnackBar('Format added successfully!', Colors.green);
          Navigator.pop(context);
        } else if (state is VariantDeleted) {
          _showSnackBar('Variant deleted', Colors.green);
        } else if (state is VariantError) {
          setState(() => _isSubmitting = false);
          _showSnackBar(state.message, Colors.redAccent);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParentBookCard(),
          const SizedBox(height: 24),
          if (!_isAddingOrEditing) ...[
            _buildVariantsDashboard(),
          ] else ...[
            _buildVariantForm(),
          ],
        ],
      ),
    );
  }

  // ─── Parent Book Card ──────────────────────────────────────────────────

  Widget _buildParentBookCard() {
    return Card(
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
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: widget.bookCrudModel.coversingleImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(widget.bookCrudModel.coversingleImage!,
                          fit: BoxFit.cover),
                    )
                  : const Icon(Icons.book_rounded,
                      color: Colors.grey, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF042153).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PARENT BOOK METADATA',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          color: Color(0xFF042153)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.bookCrudModel.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF042153)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${widget.bookCrudModel.author}',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Variants Dashboard ────────────────────────────────────────────────

  Widget _buildVariantsDashboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Language Variants',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF042153)),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isAddingOrEditing = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 1,
              ),
              icon:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: const Text('Add Variant',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
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
                onPressed: _isSubmitting ? null : widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back',
                    style: TextStyle(
                        color: Color(0xFF042153),
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitBook(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Draft',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitBook(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Publish',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Add/Edit Variant Form ─────────────────────────────────────────────

  Widget _buildVariantForm() {
    return Card(
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
              // Header
              Row(
                children: [
                  Icon(
                    _editingIndex != null
                        ? Icons.edit_note_rounded
                        : Icons.translate_rounded,
                    color: const Color(0xFF042153),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _editingIndex != null
                        ? 'Edit Language Variant'
                        : 'Add Language Variant',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF042153)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Language
              _buildLabel('Language *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _languageController,
                enabled: _editingIndex == null,
                decoration: _inputDecoration(
                  hint: 'e.g. English, Hindi, Marathi...',
                  icon: Icons.language_rounded,
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Please enter a language'
                    : null,
              ),
              const SizedBox(height: 16),

              // Donor Search (autocomplete)
              _buildLabel('Donor (Search User) *'),
              const SizedBox(height: 8),
              _buildDonorSearchField(),
              const SizedBox(height: 24),

              // Format selectors
              _buildFormatSelectors(),
              const SizedBox(height: 20),

              // ─── Hardcover Details ───
              if (_hasHardcover) ...[
                const Divider(height: 32),
                _buildSectionTitle(
                    'Hardcover Details', const Color(0xFF4F46E5)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(
                    labelText: 'Hardcover ISBN Number *',
                    prefixIcon: const Icon(Icons.qr_code_rounded, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) =>
                      _hasHardcover && (val == null || val.isEmpty)
                          ? 'ISBN is required'
                          : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Instantly Available for Requests',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Switch(
                      value: _hardcoverAvailable,
                      activeThumbColor: const Color(0xFF4F46E5),
                      onChanged: (val) =>
                          setState(() => _hardcoverAvailable = val),
                    ),
                  ],
                ),
              ],

              // ─── E-Book Files ───
              if (_hasEbook) ...[
                const Divider(height: 32),
                _buildSectionTitle(
                    'E-Book Files (PDF / EPUB)', const Color(0xFF0D9488)),
                const SizedBox(height: 6),
                Text(
                  'Upload one or more files. Multiple formats ensure availability.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                _buildEbookFilesList(),
                const SizedBox(height: 12),
                _buildPickButton(
                  onTap: _pickEbookFiles,
                  accentColor: const Color(0xFF0D9488),
                  label: 'Select E-Book Files',
                  subLabel: 'PDF, EPUB — multiple files allowed',
                  icon: Icons.book_online_rounded,
                ),
              ],

              // ─── Audiobook Parts ───
              if (_hasAudiobook) ...[
                const Divider(height: 32),
                _buildSectionTitle('Audiobook Parts', const Color(0xFFD97706)),
                const SizedBox(height: 6),
                Text(
                  'Add parts (chapters) and attach an audio file to each. '
                  'Files are uploaded in order when publishing.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                _buildAudioPartsList(),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addAudioPart,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Part'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD97706),
                    side: const BorderSide(color: Color(0xFFD97706)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],

              // ─── Videobook Parts ───
              if (_hasVideobook) ...[
                const Divider(height: 32),
                _buildSectionTitle(
                    'Videobook Parts (MP4 / WEBM)', const Color(0xFF7C3AED)),
                const SizedBox(height: 6),
                Text(
                  'Add parts (chapters) and attach a video file to each.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                _buildVideoPartsList(),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addVideoPart,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Part'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C3AED),
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _resetForm,
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF042153),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _saveVariant,
                    icon: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('Save Variant',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── E-Book Files List ─────────────────────────────────────────────────

  Widget _buildEbookFilesList() {
    if (_ebookFiles.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ebookFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _ebookFiles[index];
        final ext = item.fileName.split('.').last.toUpperCase();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_rounded,
                    color: Color(0xFF0D9488), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.fileName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF042153)),
                        overflow: TextOverflow.ellipsis),
                    Text('Format: $ext',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.redAccent, size: 20),
                onPressed: () => _removeEbookFile(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Audiobook Parts List ──────────────────────────────────────────────

  Widget _buildAudioPartsList() {
    if (_audioParts.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _audioParts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final part = _audioParts[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Part ${part.partNumber}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFFD97706)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 18),
                    onPressed: () => _removeAudioPart(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: part.title,
                decoration: InputDecoration(
                  labelText: 'Part Title *',
                  hintText: 'e.g. Introduction, Chapter 1...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  isDense: true,
                ),
                onChanged: (val) => _audioParts[index].title = val,
                validator: (val) =>
                    _hasAudiobook && (val == null || val.trim().isEmpty)
                        ? 'Title is required'
                        : null,
              ),
              const SizedBox(height: 10),
              // File picker for this part
              GestureDetector(
                onTap: () => _pickAudioFileForPart(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: part.file != null
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: part.file != null
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        part.file != null || part.isFromServer
                            ? Icons.audiotrack_rounded
                            : Icons.attach_file_rounded,
                        size: 18,
                        color: part.file != null || part.isFromServer
                            ? Colors.green
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          part.file != null
                              ? part.file!.fileName
                              : part.isFromServer
                                  ? '✓ Already uploaded on server'
                                  : 'Tap to select audio file (MP3/WAV/M4A)',
                          style: TextStyle(
                            fontSize: 12,
                            color: part.file != null || part.isFromServer
                                ? const Color(0xFF042153)
                                : Colors.grey.shade500,
                            fontWeight: part.file != null || part.isFromServer
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (part.file != null || part.isFromServer)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Video Parts List ───────────────────────────────────────────────────

  Widget _buildVideoPartsList() {
    if (_videoParts.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _videoParts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final part = _videoParts[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Part ${part.partNumber}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF7C3AED)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 18),
                    onPressed: () => _removeVideoPart(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: part.title,
                decoration: InputDecoration(
                  labelText: 'Part Title *',
                  hintText: 'e.g. Introduction, Chapter 1...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  isDense: true,
                ),
                onChanged: (val) => _videoParts[index].title = val,
                validator: (val) =>
                    _hasVideobook && (val == null || val.trim().isEmpty)
                        ? 'Title is required'
                        : null,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickVideoFileForPart(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: part.file != null
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: part.file != null
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        part.file != null
                            ? Icons.videocam_rounded
                            : Icons.attach_file_rounded,
                        size: 18,
                        color: part.file != null
                            ? Colors.green
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          part.file != null
                              ? part.file!.fileName
                              : 'Tap to select video file (MP4/WEBM)',
                          style: TextStyle(
                            fontSize: 12,
                            color: part.file != null
                                ? const Color(0xFF042153)
                                : Colors.grey.shade500,
                            fontWeight: part.file != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (part.file != null)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Format Selectors ──────────────────────────────────────────────────

  Widget _buildFormatSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Select Content Formats *'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFormatCard(
              title: 'Hardcover',
              subtitle: 'Physical book',
              icon: Icons.menu_book_rounded,
              selected: _hasHardcover,
              activeColor: const Color(0xFF4F46E5),
              onTap: () => setState(() => _hasHardcover = !_hasHardcover),
            ),
            const SizedBox(width: 8),
            _buildFormatCard(
              title: 'E-Book',
              subtitle: 'PDF / EPUB',
              icon: Icons.book_online_rounded,
              selected: _hasEbook,
              activeColor: const Color(0xFF0D9488),
              onTap: () => setState(() => _hasEbook = !_hasEbook),
            ),
            const SizedBox(width: 8),
            _buildFormatCard(
              title: 'Audiobook',
              subtitle: 'MP3 / WAV',
              icon: Icons.headphones_rounded,
              selected: _hasAudiobook,
              activeColor: const Color(0xFFD97706),
              onTap: () => setState(() => _hasAudiobook = !_hasAudiobook),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFormatCard(
              title: 'Videobook',
              subtitle: 'MP4 / WEBM',
              icon: Icons.videocam_rounded,
              selected: _hasVideobook,
              activeColor: const Color(0xFF7C3AED),
              onTap: () => setState(() => _hasVideobook = !_hasVideobook),
            ),
            const Spacer(flex: 2),
          ],
        ),
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
            color:
                selected ? activeColor.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? activeColor : Colors.grey.shade200,
              width: selected ? 2.2 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.12),
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
                      color: selected
                          ? activeColor.withValues(alpha: 0.12)
                          : Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon,
                        color: selected ? activeColor : Colors.grey.shade500,
                        size: 24),
                  ),
                  if (selected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.check_circle,
                            color: activeColor, size: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: selected ? activeColor : Colors.grey.shade800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pick Button ───────────────────────────────────────────────────────

  Widget _buildPickButton({
    required VoidCallback onTap,
    required Color accentColor,
    required String label,
    required String subLabel,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DashedContainer(
        color: accentColor.withValues(alpha: 0.5),
        borderRadius: 12,
        child: Container(
          color: accentColor.withValues(alpha: 0.02),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          width: double.infinity,
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 32, color: accentColor.withValues(alpha: 0.7)),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: accentColor)),
              const SizedBox(height: 4),
              Text(subLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Variants List ─────────────────────────────────────────────────────

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
                  color: Colors.green.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.translate_rounded,
                    size: 36, color: Colors.green),
              ),
              const SizedBox(height: 12),
              const Text('No language variants added yet',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF042153))),
              const SizedBox(height: 4),
              Text('Add at least one variant before publishing.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language_rounded,
                          color: Colors.blue, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(variant.language.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF042153))),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.blue, size: 20),
                      onPressed: () => _startEdit(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDeleteVariant(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Format details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: variant.formats.map((format) {
                    Color accentColor;
                    IconData formatIcon;
                    String details;

                    if (format.type == 'hardcover') {
                      accentColor = const Color(0xFF4F46E5);
                      formatIcon = Icons.menu_book_rounded;
                      details =
                          'ISBN: ${format.isbn} • Copies: ${format.copies} • Available: ${format.available == true ? "Yes" : "No"}';
                    } else if (format.type == 'ebook') {
                      accentColor = const Color(0xFF0D9488);
                      formatIcon = Icons.book_online_rounded;
                      final names =
                          format.ebookFiles.map((f) => f.fileName).join(', ');
                      details = '${format.ebookFiles.length} file(s): $names';
                    } else if (format.type == 'videobook') {
                      accentColor = const Color(0xFF7C3AED);
                      formatIcon = Icons.videocam_rounded;
                      details =
                          '${format.videoParts.length} part(s): ${format.videoParts.map((p) => p.title).join(', ')}';
                    } else {
                      accentColor = const Color(0xFFD97706);
                      formatIcon = Icons.headphones_rounded;
                      details =
                          '${format.audioParts.length} part(s): ${format.audioParts.map((p) => p.title).join(', ')}';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(formatIcon, color: accentColor, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(format.type.toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: accentColor)),
                                const SizedBox(height: 2),
                                Text(details,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2),
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

  // ─── Donor Search ─────────────────────────────────────────────────────

  void _onDonorSearchChanged(String query) {
    _donorDebounce?.cancel();

    if (query.length < 3) {
      setState(() {
        _donorSearchResults = [];
        _isDonorSearching = false;
      });
      return;
    }

    _donorDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isDonorSearching = true);
      try {
        debugPrint('🔍 Searching donor: "$query"');
        final repo = getIt<UserRepository>();
        final results = await repo.searchUsers(query);
        debugPrint('🔍 Got ${results.length} results');
        if (mounted) {
          setState(() {
            _donorSearchResults = results;
            _isDonorSearching = false;
          });
        }
      } catch (e) {
        debugPrint('❌ Donor search error: $e');
        if (mounted) {
          setState(() {
            _donorSearchResults = [];
            _isDonorSearching = false;
          });
          _showSnackBar('Search error: $e', Colors.redAccent);
        }
      }
    });
  }

  void _selectDonor(UserEntity user) {
    setState(() {
      _selectedDonorId = user.id;
      _selectedDonorName = user.name;
      _donorSearchController.text = user.name;
      _donorSearchResults = [];
    });
  }

  Widget _buildDonorSearchField() {
    // If donor is already selected, show read-only field with clear button
    if (_selectedDonorId != null && _selectedDonorName != null) {
      return TextFormField(
        readOnly: true,
        controller: TextEditingController(text: _selectedDonorName),
        decoration: InputDecoration(
          prefixIcon:
              const Icon(Icons.person_rounded, color: Colors.green, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
            onPressed: () {
              setState(() {
                _selectedDonorId = null;
                _selectedDonorName = null;
                _donorSearchController.clear();
                _donorSearchResults = [];
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          filled: true,
          fillColor: Colors.green.withValues(alpha: 0.04),
        ),
      );
    }

    // Search field (shown when no donor selected)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _donorSearchController,
          decoration: InputDecoration(
            hintText: 'Type 3+ characters to search users...',
            prefixIcon: const Icon(Icons.person_search_rounded,
                color: Colors.grey, size: 20),
            suffixIcon: _isDonorSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF042153)),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          onChanged: (val) => _onDonorSearchChanged(val),
          validator: (val) {
            if (_selectedDonorId == null || _selectedDonorId!.isEmpty) {
              return 'Please search and select a donor';
            }
            return null;
          },
        ),
        // Search results
        if (_donorSearchResults.isNotEmpty) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _donorSearchResults.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final user = _donorSearchResults[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          const Color(0xFF042153).withValues(alpha: 0.1),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF042153)),
                      ),
                    ),
                    title: Text(user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(user.email,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    onTap: () => _selectDonor(user),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF042153)));
  }

  Widget _buildSectionTitle(String text, Color color) {
    return Text(text,
        style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color));
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF042153)),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }
}

// ─── DashedContainer Widget ──────────────────────────────────────────────────

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
