import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UpdateCategoryPage extends StatefulWidget {
  final CategoryEntity category;

  const UpdateCategoryPage({super.key, required this.category});

  @override
  State<UpdateCategoryPage> createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController parentController;
  TextEditingController categoryDescController = TextEditingController();

  List<String> Images = [];

  List<XFile?> selectedImages = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.category.title);
    parentController =
        TextEditingController(text: widget.category.parentCategory);
    Images.add(widget.category.imageUrl);
  }

  @override
  void dispose() {
    titleController.dispose();
    parentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Update Category")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              const Text('Title', style: _labelStyle),
              MyTextField(
                controller: titleController,
                hintText: " Enter Title",
                obscureText: false,
                isContentPadding: true,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Parent Category', style: _labelStyle),
              MyTextField(
                controller: parentController,
                hintText: " Parent Category",
                obscureText: false,
                isContentPadding: true,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Image', style: TextStyles.labelStyle),
                  IconButton(
                    onPressed: dialogpermission,
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
                child: (Images.isNotEmpty || selectedImages.isNotEmpty)
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: Images.isNotEmpty
                            ? Images.length
                            : selectedImages.length,
                        itemBuilder: (context, index) {
                          final isNetworkImage = Images.isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  // ✅ Show Network or Local Image
                                  isNetworkImage
                                      ? CachedNetworkImage(
                                          imageUrl: Images[index],
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        )
                                      : Image.file(
                                          File(selectedImages[index]!.path),
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                        ),

                                  // ✅ Close Button
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isNetworkImage) {
                                            Images.removeAt(index);
                                          } else {
                                            selectedImages.removeAt(index);
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 3,
                                              offset: Offset(1, 1),
                                            )
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 18,
                                        ),
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
              const Text('Category Description (Optional)', style: _labelStyle),
              MyTextField(
                controller: categoryDescController,
                hintText: "Category description",
                obscureText: false,
                isContentPadding: true,
                keyboardType: TextInputType.text,
                maxlines: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    Images.isEmpty ? _submitForm : _submitFormwithoutImage,
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
            ]),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image')),
        );
        return;
      }

      final imageFile = File(selectedImages.first!.path);

      // Dispatch BLoC event
      context.read<CategoryBloc>().add(UpdateCategoryEvent(
            id: widget.category.id,
            title: titleController.text,
            description: categoryDescController.text.trim(),

            image: imageFile, // or use FilePicker/ImagePicker if needed
          ));
      Navigator.pop(context);
    }
  }

  void _submitFormwithoutImage() {
    if (_formKey.currentState!.validate()) {
      if (Images.isEmpty && selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image')),
        );
        return;
      }

      //final imageFile = File(selectedImages.first!.path);

      // Dispatch BLoC event
      context.read<CategoryBloc>().add(UpdateCategoryEvent(
            id: widget.category.id,
            title: titleController.text,
            description: categoryDescController.text.trim(),

            image: selectedImages.isNotEmpty
                ? File(selectedImages.first!.path)
                : File(Images.first), // or use FilePicker/ImagePicker if needed
          ));
      Navigator.pop(context);
    }
  }

  void dialogpermission() async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // 👈 Important: makes it wrap content
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await onUploadTap(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await onUploadTap(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onUploadTap(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        setState(() => selectedImages = [image]); // Always single image
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
}

const TextStyle _labelStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 18,
  color: Color.fromARGB(255, 4, 33, 83),
);
