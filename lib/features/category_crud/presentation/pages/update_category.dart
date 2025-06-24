import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/book_textfields.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

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
      appBar: AppBar(title: const Text("Update Category")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
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
            const Text('Image', style: _labelStyle),
            InkWell(
              onTap: dialogpermission,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, color: Colors.grey),
                      SizedBox(height: 4),
                      Text("Upload Images",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            Images.isNotEmpty
                ? SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.network(
                                  Images[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  height: 30,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            Images.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(selectedImages[index]!.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
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
              onPressed: Images.isEmpty ? _submitForm : _submitFormwithoutImage,
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
            category: parentController.text,

            image: imageFile, // or use FilePicker/ImagePicker if needed
          ));
      Navigator.pop(context);
    }
  }

  void _submitFormwithoutImage() {
    if (_formKey.currentState!.validate()) {
      // if (selectedImages.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please upload at least one image')),
      //   );
      //   return;
      // }

      //final imageFile = File(selectedImages.first!.path);

      // Dispatch BLoC event
      context.read<CategoryBloc>().add(UpdateCategoryEvent(
            id: widget.category.id,
            title: titleController.text,
            category: parentController.text,

            image: null, // or use FilePicker/ImagePicker if needed
          ));
      Navigator.pop(context);
    }
  }

  void dialogpermission() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const Text('Choose a Profile Photo',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await onUploadTap(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await onUploadTap(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onUploadTap(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await ImagePickerHelper.pickMultipleImages();
        if (images != null && images.isNotEmpty) {
          setState(() => selectedImages = images);
        }
      } else {
        final image = await ImagePicker().pickImage(source: source);
        if (image != null) {
          setState(() => selectedImages = [image]);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image(s): $e')),
      );
    }
  }
}

const TextStyle _labelStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 18,
  color: Color.fromARGB(255, 4, 33, 83),
);
