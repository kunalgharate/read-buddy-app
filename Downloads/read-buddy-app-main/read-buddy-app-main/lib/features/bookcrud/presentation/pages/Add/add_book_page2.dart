import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';

import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/location_cubit.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';

class AddBookPage2 extends StatefulWidget {
  final VoidCallback onBack;
  final BookCrudModel bookCrudModel;

  const AddBookPage2({
    super.key,
    required this.onBack,
    required this.bookCrudModel,
  });

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
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  UserEntity? selectedUser;
  String? selectedCondition;
  Timer? _debounce;
  final List<String> _tags = [];
  List<XFile?> selectedImages = [];

  File? selectedCoverImageFile;

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();
  }

  @override
  void dispose() {
    conditionController.dispose();
    notesController.dispose();
    ownerIdController.dispose();
    locationController.dispose();
    coverImageController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Book Condition',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromARGB(255, 4, 33, 83))),
              const SizedBox(height: 16),

              /// ✅ Book Condition Dropdown
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
                        hintText: 'Select Condition')),
                items: (f, cs) => ['new', 'like_new', 'used_good', 'used_poor'],
                popupProps: const PopupProps.menu(fit: FlexFit.loose),
              ),
              const SizedBox(height: 16),

              const Text('Additional Notes', style: TextStyles.labelStyle),
              MyTextField(
                controller: notesController,
                validator: BookFormValidator.validateNotes,
                hintText: "Additional condition about book",
                obscureText: false,
                keyboardType: TextInputType.text,
                maxlines: 5,
              ),
              const SizedBox(height: 40),

              const Text('Book Sources Information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromARGB(255, 4, 33, 83))),
              const SizedBox(height: 16),

              /// ✅ Owner Name
              const Text('Owner Name', style: TextStyles.labelStyle),
              GenericAutocomplete<UserEntity>(
                options: BookValueItems.usersList,
                controller: ownerIdController,
                displayString: (user) => user.name,
                onSelected: (UserEntity user) {
                  selectedUser = user;
                  ownerIdController.text = user.id;
                },
                hintText: 'Search Owner Names',
              ),
              const SizedBox(height: 16),

              /// ✅ Location + Suggestions
              const Text('Location', style: TextStyles.labelStyle),
              MyTextField(
                controller: locationController,
                validator: BookFormValidator.validateLocation,
                hintText: "Location",
                maxlines: locationController.text.isNotEmpty ? 3 : 1,
                onChanged: (String? value) {
                  _onSearchChanged();
                  return null;
                },
                obscureText: false,
                keyboardType: TextInputType.text,
                suffixIcon: const Icon(Icons.map),
              ),
              if (BookValueItems.locationsuggestions.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: BookValueItems.locationsuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(BookValueItems
                            .locationsuggestions[index].description),
                        onTap: () {
                          locationController.text = BookValueItems
                              .locationsuggestions[index].description;
                          setState(
                              () => BookValueItems.locationsuggestions.clear());
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              /// ✅ Cover Image Upload
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cover Image', style: TextStyles.labelStyle),
                  IconButton(
                    onPressed: singleImagePermission,
                    icon: const Icon(Icons.cloud_upload),
                  ),
                ],
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: selectedCoverImageFile != null
                      ? _buildSelectedCoverImage()
                      : const Center(
                          child: Text(
                            "Upload Cover Image",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              /// ✅ Multiple Book Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Book Images', style: TextStyles.labelStyle),
                  IconButton(
                    onPressed: () {
                      if (selectedImages.length >= 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Maximum 5 images allowed')),
                        );
                      } else {
                        dialogpermission();
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                  ),
                ],
              ),
              Container(
                height: selectedImages.isEmpty ? 150 : 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImages.isEmpty
                    ? const Center(
                        child: Text(
                          "Upload Book Images",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
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
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 14,
                                right: 15,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
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

              /// ✅ Book Description
              const Text('Book Description', style: TextStyles.labelStyle),
              MyTextField(
                controller: descriptionController,
                validator: BookFormValidator.validateDescription,
                hintText: "Book Description",
                obscureText: false,
                keyboardType: TextInputType.text,
                maxlines: 5,
              ),
              const SizedBox(height: 16),

              /// ✅ Tags
              const Text('Tag', style: TextStyles.labelStyle),
              MyTextField(
                controller: tagController,
                keyboardType: TextInputType.text,
                validator:
                    _tags.isEmpty ? BookFormValidator.validateTags : null,
                hintText: "Enter tags and press space",
                obscureText: false,
                onChanged: (val) {
                  if (val!.endsWith(' ')) _handleSubmitted(val);
                  return null;
                },
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

              /// ✅ Submit Button
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Done",
                    style: TextStyle(color: Color.fromARGB(255, 4, 33, 83))),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCoverImage() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(selectedCoverImageFile!.path),
              width: double.infinity,
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
              setState(() => selectedCoverImageFile = null);
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
  }

  /// ✅ Submit Handler
  void _onSubmit() {
    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an owner name")),
      );
      return;
    }
    if (_tags.isEmpty &&
        tagController.text.isNotEmpty &&
        !tagController.text.endsWith(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press space to add your tag')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final completeBook = widget.bookCrudModel.copyWith(
        condition: conditionController.text,
        location: locationController.text,
        ownerId: selectedUser!.id,
        coversingleImage: selectedCoverImageFile,
        additionalImages:
            selectedImages.map((xfile) => File(xfile!.path)).toList(),
        description: descriptionController.text,
        notes: notesController.text,
        tags: _tags,
      );
      context.read<BookCrudBloc>().add(AddBookCrudEvent(completeBook));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding the Book')),
      );
      Navigator.pop(context);
    }
  }

  /// ✅ Tag Handlers
  void _handleSubmitted(String value) {
    List<String> newTags = value
        .split(' ')
        .map((e) => e.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    setState(() {
      _tags.addAll(newTags.where((tag) => !_tags.contains(tag)));
      tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  /// ✅ Location Search Debounce
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = locationController.text.trim();
      if (query.length >= 3 && mounted) {
        context.read<LocationCubit>().fetchlocations(query);
        setState(() {});
      } else {
        BookValueItems.locationsuggestions.clear();
        setState(() {});
      }
    });
  }

  /// ✅ Multiple Images Picker
  void dialogpermission() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
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
        );
      },
    );
  }

  Future<void> onUploadTap(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await ImagePickerHelper.pickMultipleImages();
        if (images != null && images.isNotEmpty) {
          setState(() {
            int available = 5 - selectedImages.length;
            if (available > 0) {
              selectedImages.addAll(images.take(available));
            }
            if (selectedImages.length >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maximum 5 images allowed')),
              );
            }
          });
        }
      } else {
        final image = await ImagePicker().pickImage(source: source);
        if (image != null) {
          setState(() {
            if (selectedImages.length < 5) {
              selectedImages.add(image);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maximum 5 images allowed')),
              );
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image(s): $e')),
      );
    }
  }

  /// ✅ Single Image Picker
  void singleImagePermission() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
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
        );
      },
    );
  }

  Future<void> onUploadSingleImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        final file = File(pickedImage.path);
        setState(() {
          selectedCoverImageFile = file;
          coverImageController.text = file.path.split('/').last;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }
}
