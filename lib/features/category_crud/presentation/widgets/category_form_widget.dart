import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

class CategoryFormWidget extends StatefulWidget {
  final CategoryEntity? existing;

  const CategoryFormWidget({super.key, this.existing});

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Item? _selectedParent;
  XFile? _pickedImage;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
    if (widget.existing?.parentCategoryName != null) {
      final match = CategoryItems.parentCategoryItems
          .where((e) => e.name == widget.existing!.parentCategoryName);
      if (match.isNotEmpty) _selectedParent = match.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Category' : 'Add Category',
          style: const TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategorySuccess) {
            if (context.mounted) Navigator.pop(context);
          }
          if (state is CategoryError) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Title'),
                const SizedBox(height: 6),
                MyTextField(
                  controller: _titleController,
                  hintText: 'Enter title',
                  obscureText: false,
                  isContentPadding: true,
                  digitsOnly: false,
                  keyboardType: TextInputType.text,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                _label('Parent Category (Optional)'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _showParentPicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedParent?.name ?? 'Select parent category',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedParent != null
                                ? Colors.black
                                : Colors.black26,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Description (Optional)'),
                const SizedBox(height: 6),
                MyTextField(
                  controller: _descriptionController,
                  hintText: 'Enter description',
                  obscureText: false,
                  isContentPadding: true,
                  digitsOnly: false,
                  keyboardType: TextInputType.text,
                  maxlines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('Image'),
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.cloud_upload,
                          color: Color(0xFF052E44)),
                    ),
                  ],
                ),
                _imagePreview(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CE07F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      _isEdit ? 'Update' : 'Done',
                      style: const TextStyle(
                        color: Color(0xFF052E44),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Color(0xFF052E44),
        ),
      );

  Widget _imagePreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _pickedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _isEdit && widget.existing!.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.existing!.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.edit,
                                color: Color(0xFF052E44), size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Tap upload icon to add image',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEdit) {
      context.read<CategoryBloc>().add(UpdateCategoryEvent(
            id: widget.existing!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            parentCategoryId: _selectedParent?.id,
            image: _pickedImage != null ? File(_pickedImage!.path) : null,
          ));
    } else {
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image')),
        );
        return;
      }
      context.read<CategoryBloc>().add(AddCategoryEvent(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            parentCategoryId: _selectedParent?.id,
            image: File(_pickedImage!.path),
          ));
    }
  }

  void _showParentPicker() {
    final items = CategoryItems.parentCategoryItems;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No categories available')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Parent Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF052E44),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text('None'),
                    trailing: _selectedParent == null
                        ? const Icon(Icons.check, color: Color(0xFF2CE07F))
                        : null,
                    onTap: () {
                      setState(() => _selectedParent = null);
                      Navigator.pop(ctx);
                    },
                  );
                }
                final item = items[index - 1];
                final isSelected = _selectedParent?.id == item.id;
                return ListTile(
                  title: Text(item.name),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF2CE07F))
                      : null,
                  onTap: () {
                    setState(() => _selectedParent = item);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pick(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image != null) setState(() => _pickedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }
}
