import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/utils/book_value_items.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/book_textfields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBookPage2 extends StatefulWidget {
  final VoidCallback onBack;
  final BookCrudModel bookCrudModel;

  const AddBookPage2(
      {super.key, required this.onBack, required this.bookCrudModel});

  @override
  State<AddBookPage2> createState() => _AddBookPage2State();
}

class _AddBookPage2State extends State<AddBookPage2> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController conditionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController ownerIdController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController coverImageController = TextEditingController();

  final TextEditingController imagesUploadController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController(); // Added
  final TextEditingController tagController = TextEditingController(); // Added
  UserEntity? selectedUser;
  String? selectedCondition;
  final List<String> _tags = [];
  List<XFile?> selectedImages = [];

  @override
  void initState() {
    print("calling users list");
    context.read<UserCubit>().fetchUsers();
    super.initState();
  }

  @override
  void dispose() {
    conditionController.dispose();
    notesController.dispose();
    ownerIdController.dispose();
    locationController.dispose();
    coverImageController.dispose();
    imagesUploadController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12), // ✅ Uniform padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book Condition',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              const SizedBox(height: 16),

              // MyTextField(
              //   controller: conditionController,
              //   validator: BookFormValidator.validateCondition,
              //   hintText: " Select Condition",
              //   obscureText: false,
              //   keyboardType: TextInputType.text,
              // ),
              DropdownSearch<String>(
                selectedItem: selectedCondition,
                onChanged: (value) {
                  conditionController.text = value!;
                  selectedCondition = value;
                },
                validator: BookFormValidator.validateLanguage,
                decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        hintText: 'Select Condition')),
                items: (f, cs) => [
                  'new',
                  'like_new',
                  'used_good',
                  'used_poor',
                ],
                popupProps: const PopupProps.menu(fit: FlexFit.loose),
              ),
              const SizedBox(height: 16),
              const Text('Additional Notes', style: labelStyle),
              MyTextField(
                controller: notesController,
                validator: BookFormValidator.validateNotes,
                hintText: " Additional condition about book",
                obscureText: false,
                keyboardType: TextInputType.text,
                maxlines: 5,
              ),
              const SizedBox(height: 40),
              const Text(
                'Book Sources Information',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              const SizedBox(height: 16),
              const Text('Owner Name', style: labelStyle),
              GenericAutocomplete<UserEntity>(
                options: BookValueItems.usersList,
                controller: ownerIdController,
                displayString: (user) =>
                    user.name, // ✅ Access instance property
                onSelected: (UserEntity user) {
                  selectedUser = user;
                  ownerIdController.text =
                      user.id; // update controller with name
                  print('Selected: ID=${user.id}, Name=${user.name}');
                }, // ✅ renamed for clarity
                validator: BookFormValidator.validateCategory,
                hintText: 'Search Owner Names',
              ),

              const SizedBox(height: 16),
              const Text('Location', style: labelStyle),
              MyTextField(
                controller: locationController,
                validator: BookFormValidator.validateLocation,
                hintText: " Location",
                obscureText: false,
                keyboardType: TextInputType.text,
                suffixIcon: const Icon(Icons.map),
              ),
              const SizedBox(height: 16),

              const Text('Cover Image Url', style: labelStyle),
              MyTextField(
                controller: coverImageController,
                validator: BookFormValidator.validateImageUrl,
                hintText: " Image URL",
                obscureText: false,
                keyboardType: TextInputType.text,
                suffixIcon: IconButton(
                    onPressed: singleImagePermission, icon: Icon(Icons.upload)),
              ),
              const SizedBox(height: 16),
              const Text('Book Images', style: labelStyle),

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
              if (selectedImages.isNotEmpty)
                SizedBox(
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
              const Text('Book Description', style: labelStyle),
              MyTextField(
                controller: descriptionController, // ✅ Corrected
                validator: BookFormValidator.validateDescription,
                hintText: " Book Description",
                obscureText: false,
                keyboardType: TextInputType.text,
                maxlines: 5,
              ),
              const SizedBox(height: 16),
              const Text('Tag', style: labelStyle),
              MyTextField(
                controller: tagController,
                validator: _tags.isEmpty || _tags == []
                    ? BookFormValidator.validateTags
                    : null,
                hintText: " Enter tags and press space",
                obscureText: false,
                onChanged: (val) {
                  if (val!.endsWith(' ')) {
                    _handleSubmitted(val);
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_tags.isEmpty &&
                      tagController.text.isNotEmpty &&
                      !tagController.text.endsWith(' ')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please press space to add your tag')),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    // Handle submission
                    print("tagssssssss");
                    print("OOOOwwnerr naeme ${selectedCoverImageFile!.path}");
                    final completeBook = widget.bookCrudModel.copyWith(
                      condition: conditionController.text,
                      location: locationController.text,
                      ownerId: selectedUser!.id,
                      coversingleImage: selectedCoverImageFile,
                      additionalImages: selectedImages
                          .map((xfile) => File(xfile!.path))
                          .toList(),
                      //additionalImages: additionalUrls,
                      description: descriptionController.text,
                      notes: notesController.text,
                      tags: _tags,
                      // tags: tagController.text.split(''),
                    );
                    print("Commmmmmmplete Boookk  $selectedCoverImageFile");

                    context
                        .read<BookCrudBloc>()
                        .add(AddBookCrudEvent(completeBook));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submitting form...')),
                    );
                    Navigator.pop(context);
                  }
                },
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmitted(String value) {
    List<String> newTags = value
        .split(' ')
        .map((e) => e.trim())
        .where((tag) => tag.length > 1)
        // .where((tag) => tag.startsWith('#') && tag.length > 1)
        .toList();

    setState(() {
      _tags.addAll(newTags.where((tag) => !_tags.contains(tag)));
      tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
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

  void singleImagePermission() async {
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
                  await onUploadSingleImage(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await onUploadSingleImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  File? selectedCoverImageFile;

  Future<void> onUploadSingleImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final file = File(pickedImage.path);

      setState(() {
        selectedCoverImageFile = file;
        coverImageController.text = file.path.split('/').last;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  static const TextStyle labelStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Color.fromARGB(255, 4, 33, 83),
  );
}
