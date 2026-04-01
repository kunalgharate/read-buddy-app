import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

class CategoryFormWidget extends StatefulWidget {
  final String initialTitle;
  final Item? initialCategory;
  final String initialImageUrl;
  final Function(String title, Item? category, File? image) onSubmit;

  const CategoryFormWidget({
    super.key,
    this.initialTitle = '',
    this.initialCategory,
    this.initialImageUrl = '',
    required this.onSubmit,
  });

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;

  List<Item> _categoryOptions = [];
  Item? selectedCategory;
  List<String> networkImages = [];
  List<XFile?> selectedImages = [];

  final TextStyle _labelStyle = const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Color.fromARGB(255, 4, 33, 83),
  );

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    selectedCategory = widget.initialCategory;
    if (widget.initialImageUrl.isNotEmpty) {
      networkImages.add(widget.initialImageUrl);
    }
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          setState(() {
            _categoryOptions = state.categories
                .map((e) => Item(id: e.id, name: e.title))
                .toList();

            // pre-fill selected category for update
            if (widget.initialCategory != null) {
              try {
                selectedCategory = _categoryOptions.firstWhere(
                  (item) => item.name == widget.initialCategory!.name,
                );
              } catch (_) {
                selectedCategory = null;
              }
            }
          });
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title', style: _labelStyle),
                MyTextField(
                  controller: titleController,
                  hintText: " Enter Title",
                  obscureText: false,
                  isContentPadding: true,
                  digitsOnly: false,
                  keyboardType: TextInputType.text,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 16),
                Text('Parent Category', style: _labelStyle),
                DropdownButtonFormField<Item>(
                  initialValue: selectedCategory,
                  hint: const Text('Select Parent Category'),
                  items: _categoryOptions.map((item) {
                    return DropdownMenuItem<Item>(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (Item? item) {
                    setState(() => selectedCategory = item);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Image', style: TextStyles.labelStyle),
                    IconButton(
                      onPressed: _dialogPermission,
                      icon: const Icon(Icons.cloud_upload),
                    ),
                  ],
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: (networkImages.isNotEmpty || selectedImages.isNotEmpty)
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: networkImages.isNotEmpty
                              ? networkImages.length
                              : selectedImages.length,
                          itemBuilder: (context, index) {
                            final isNetwork = networkImages.isNotEmpty;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    isNetwork
                                        ? CachedNetworkImage(
                                            imageUrl: networkImages[index],
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          )
                                        : Image.file(
                                            File(selectedImages[index]!.path),
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.cover,
                                          ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isNetwork) {
                                              networkImages.removeAt(index);
                                            } else {
                                              selectedImages.removeAt(index);
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.close,
                                              color: Colors.red, size: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "Upload Images",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Color.fromARGB(255, 4, 33, 83)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (networkImages.isEmpty && selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image')),
        );
        return;
      }

      final File? imageFile =
          selectedImages.isNotEmpty ? File(selectedImages.first!.path) : null;

      widget.onSubmit(titleController.text.trim(), selectedCategory, imageFile);
      Navigator.pop(context);
    }
  }

  void _dialogPermission() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _onUploadTap(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _onUploadTap(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onUploadTap(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        setState(() => selectedImages = [image]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
}
