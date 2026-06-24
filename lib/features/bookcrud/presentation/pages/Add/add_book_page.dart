import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

/// Simplified Add Book Page aligned with new API.
/// Fields: title, author, publisher, description, categories, tags, coverImage.
class AddBookPage extends StatefulWidget {
  /// Legacy callback for stepper compatibility — still supported.
  final Function? onContinue;

  const AddBookPage({super.key, this.onContinue});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagController = TextEditingController();

  Item? _selectedCategory;
  final List<String> _tags = [];
  File? _coverImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Ensure categories are loaded for autocomplete
    final catState = context.read<CategoryBloc>().state;
    if (catState is! CategoryLoaded) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final newTags = value
        .split(' ')
        .map((e) => e.trim())
        .where((tag) => tag.isNotEmpty && !_tags.contains(tag))
        .toList();
    if (newTags.isNotEmpty) {
      setState(() {
        _tags.addAll(newTags);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _pickCoverImage() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () async {
              Navigator.pop(ctx);
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (picked != null) {
                setState(() => _coverImage = File(picked.path));
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            onTap: () async {
              Navigator.pop(ctx);
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                setState(() => _coverImage = File(picked.path));
              }
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    // Validate tags typed but not added
    if (_tagController.text.trim().isNotEmpty) {
      _addTag(_tagController.text);
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Build a minimal BookCrudModel for the API
    final book = BookCrudModel(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      publisher: _publisherController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!.id,
      categoryId: _selectedCategory!.id,
      tags: _tags,
      coversingleImage: _coverImage,
      // Fields required by entity but not used in new API:
      publicationYear: 0,
      isbn: '',
      edition: '',
      condition: '',
      isAvailable: true,
      status: 'available',
      numberOfCopies: 0,
      format: '',
      language: '',
      genre: '',
      ownerId: '',
      location: '',
      coverImageUrl: '',
      additionalImages: [],
      notes: '',
    );

    // If used inside stepper (legacy), call onContinue
    if (widget.onContinue != null) {
      widget.onContinue!(book);
      return;
    }

    // Otherwise submit directly via BLoC
    context.read<BookCrudBloc>().add(AddBookCrudEvent(book));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookCrudBloc, BookCrudState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is BookCrudListLoaded) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is BookCrudError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: widget.onContinue != null
            ? null
            : AppBar(
                title: const Text('Add Book',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF042153))),
                centerTitle: true,
              ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _label('Book Title *'),
                    MyTextField(
                      controller: _titleController,
                      hintText: 'Enter book title',
                      validator: BookFormValidator.validateTitle,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // Author
                    _label('Author *'),
                    MyTextField(
                      controller: _authorController,
                      hintText: 'Enter author name',
                      validator: BookFormValidator.validateAuthor,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // Publisher
                    _label('Publisher'),
                    MyTextField(
                      controller: _publisherController,
                      hintText: 'Enter publisher name',
                      obscureText: false,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // Category (autocomplete)
                    _label('Category *'),
                    GenericAutocomplete<Item>(
                      options: BookValueItems.bookCategories,
                      controller: _categoryController,
                      displayString: (item) => item.name,
                      onSelected: (Item item) {
                        _selectedCategory = item;
                        _categoryController.text = item.name;
                      },
                      validator: BookFormValidator.validateCategory,
                      hintText: 'Search categories...',
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _label('Description'),
                    MyTextField(
                      controller: _descriptionController,
                      hintText: 'Brief description of the book',
                      obscureText: false,
                      keyboardType: TextInputType.multiline,
                      maxlines: 4,
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    _label('Tags'),
                    MyTextField(
                      controller: _tagController,
                      hintText: 'Enter tags and press space',
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      onChanged: (val) {
                        if (val != null && val.endsWith(' ')) _addTag(val);
                        return null;
                      },
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _tags
                            .map((tag) => Chip(
                                  label: Text(tag,
                                      style: const TextStyle(fontSize: 12)),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => _removeTag(tag),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Cover Image
                    _label('Cover Image'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: _coverImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_coverImage!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _coverImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.red, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Tap to upload cover image',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2CE07F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Add Book',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF042153))),
    );
  }
}
