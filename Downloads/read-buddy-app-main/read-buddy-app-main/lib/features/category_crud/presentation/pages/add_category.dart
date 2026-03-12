// import 'dart:io';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';

import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/category_list_page.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleContoller = TextEditingController();
  TextEditingController parentCategoryController = TextEditingController();
  TextEditingController categoryDescController = TextEditingController();
  Item? selectedCategory;
  List<XFile?> selectedImages = [];

  @override
  void dispose() {
    titleContoller.dispose();
    parentCategoryController.dispose();
    categoryDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Category",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF052E44)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Title', style: labelStyle),
              MyTextField(
                controller: titleContoller,
                hintText: " Enter Title",
                obscureText: false,
                isContentPadding: true,
                digitsOnly: false,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              Text('Parent Category', style: labelStyle),
              GenericAutocomplete<Item>(
                options: CategoryItems.parentCategoryItems,
                controller: parentCategoryController,
                displayString: (item) => item.name,
                onSelected: (Item item) {
                  selectedCategory = item;
                  parentCategoryController.text =
                      item.name; // update controller with name
                  print('Selected: ID=${item.id}, Name=${item.name}');
                },
                hintText: 'Search Categories',
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
                height: 180, // Same height as cover image
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              "Upload  Images",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(selectedImages[index]!.path),
                                    width: 160,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImages.removeAt(index);
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
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Text('Category Description (Optional)', style: labelStyle),
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
                onPressed: _submitForm,
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

  TextStyle labelStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Color.fromARGB(255, 4, 33, 83),
  );
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image')),
        );
        return;
      }

      final imageFile = File(selectedImages.first!.path);
      print(
          "selected category Id isssssss from add category -->${selectedCategory?.id}");
      // Dispatch BLoC event
      context.read<CategoryBloc>().add(AddCategoryEvent(
            title: titleContoller.text.trim(),
            description: categoryDescController.text.trim(),
            parentCategoryId: selectedCategory?.id,
            image: imageFile,
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
