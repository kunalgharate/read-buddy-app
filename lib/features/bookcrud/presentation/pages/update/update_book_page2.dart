import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/utils/book_value_items.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/book_textfields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateBookPage2 extends StatefulWidget {
  final VoidCallback onBack;
  final BookCrudModel bookCrudModel;
  final String id;

  const UpdateBookPage2(
      {super.key,
      required this.onBack,
      required this.bookCrudModel,
      required this.id});

  @override
  State<UpdateBookPage2> createState() => _UpdateBookPage2State();
}

class _UpdateBookPage2State extends State<UpdateBookPage2> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController conditionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController ownerIdController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final TextEditingController imagesUploadController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController(); // Added
  final TextEditingController tagController = TextEditingController(); // Added
  UserEntity? selectedUser;
  final List<String> _tags = [];
  List<File> Images = [];
  List<XFile?> selectedImages = [];

  @override
  void initState() {
    context.read<UserCubit>().fetchUsers();
    context.read<BookCrudBloc>().add(LoadBookCrudById(id: widget.id));
    super.initState();
  }

  @override
  void dispose() {
    conditionController.dispose();
    notesController.dispose();
    ownerIdController.dispose();
    locationController.dispose();

    imagesUploadController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookCrudBloc, BookCrudState>(
      builder: (context, state) {
        if (state is BookCrudLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookCrudDetailLoaded) {
          context.read<BookCrudBloc>().add(LoadBookCrudList());
          _setFormData(state.book);
        } else if (state is BookCrudError) {
          context.read<BookCrudBloc>().add(LoadBookCrudList());
          return Center(child: Text(" ${state.message}"));
        }

        return builtform(context); // your existing Form widget
      },
    );
  }

  bool _isFormInitialized = false;

  void _setFormData(BookCrudEntity book) {
    if (_isFormInitialized) return;

    // Basic details
    conditionController.text = book.condition;
    notesController.text = book.notes;
    locationController.text = book.location;
    descriptionController.text = book.description;

    // Tags
    _tags.clear();
    _tags.addAll(book.tags ?? []);

    // // Owner ID
    final matchedUser = BookValueItems.usersList.firstWhere(
      (user) => user.id == book.ownerId,
      orElse: () => UserEntity(
          id: book.ownerId ?? '',
          name: book.ownerName ?? "unkonwnn",
          userRole: '',
          isEmailVerified: true,
          email: '',
          authType: '',
          socialId: '',
          phone: '',
          pincode: '',
          city: '',
          isPrime: false,
          membershipExpires: null,
          finesDue: 0,
          badges: []),
    );
    selectedUser = matchedUser;
    ownerIdController.text = matchedUser.name;

    Images = book.additionalImages ?? [];

    // If you want to show selected images as preview, you would need to
    // write those base64 strings to temporary files.

    _isFormInitialized = true;
  }

  Material builtform(BuildContext context) {
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

              MyTextField(
                controller: conditionController,
                validator: BookFormValidator.validateCondition,
                hintText: " Select Condition",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              const Text('Additional Notes', style: _labelStyle),
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
              const Text('Owner Name', style: _labelStyle),
              GenericAutocomplete<UserEntity>(
                options: BookValueItems.usersList,
                controller: ownerIdController,
                displayString: (user) =>
                    user.name, // ✅ Access instance property
                onSelected: (UserEntity user) {
                  selectedUser = user;
                  ownerIdController.text =
                      user.name; // update controller with name
                  print('Selected: ID=${user.id}, Name=${user.name}');
                }, // ✅ renamed for clarity
                validator: BookFormValidator.validateCategory,
                hintText: 'Search Categories',
              ),

              const SizedBox(height: 16),
              const Text('Location', style: _labelStyle),
              MyTextField(
                controller: locationController,
                validator: BookFormValidator.validateLocation,
                hintText: " Location",
                obscureText: false,
                keyboardType: TextInputType.text,
                suffixIcon: const Icon(Icons.map),
              ),
              const SizedBox(height: 16),

              const Text('Book Images', style: _labelStyle),

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
                                  // if (Images[index] != null &&
                                  //     Images[index].isNotEmpty)
                                  //   Image.network(
                                  //     Images[index],
                                  //     width: 100,
                                  //     height: 100,
                                  //     fit: BoxFit.cover,
                                  //     errorBuilder:
                                  //         (context, error, stackTrace) =>
                                  //             const Icon(Icons.broken_image,
                                  //                 size: 60, color: Colors.grey),
                                  //   )
                                  // else
                                  //   const Icon(Icons.broken_image,
                                  //       size: 100, color: Colors.grey),
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

              // if (selectedImages.isNotEmpty)
              //   SizedBox(
              //     height: 100,
              //     child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: selectedImages.length,
              //       itemBuilder: (context, index) {
              //         return Padding(
              //           padding: const EdgeInsets.only(right: 8.0, top: 10),
              //           child: ClipRRect(
              //             borderRadius: BorderRadius.circular(8),
              //             child: Image.file(
              //               File(selectedImages[index]!.path),
              //               width: 100,
              //               height: 100,
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),

              const SizedBox(height: 16),
              const Text('Book Description', style: _labelStyle),
              MyTextField(
                controller: descriptionController, // ✅ Corrected
                validator: BookFormValidator.validateDescription,
                hintText: " Book Description",
                obscureText: false,
                keyboardType: TextInputType.text,
                maxlines: 5,
              ),
              const SizedBox(height: 16),
              const Text('Tag', style: _labelStyle),
              MyTextField(
                controller: tagController, // ✅ Corrected
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
                  print("Oweenerr id${selectedUser!.id}");
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
                    final imageFile = File(selectedImages.first!.path);

                    print("tagssssssss");
                    print(_tags.length);
                    final completeBook = widget.bookCrudModel.copyWith(
                      condition: conditionController.text,
                      location: locationController.text,
                      ownerId: selectedUser!.id,
                      coverImageUrl: '',
                      // additionalImages: base64Images,
                      //additionalImages: additionalUrls,
                      description: descriptionController.text,
                      notes: notesController.text,
                      tags: _tags,
                      // tags: tagController.text.split(''),
                    );
                    print("Commmmmmmplete Boookk");

                    context
                        .read<BookCrudBloc>()
                        .add(AddBookCrudEvent(completeBook));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('updating form...')),
                    );
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
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   child: const Text(
              //     "No Change",
              //     style: TextStyle(
              //         color: Color.fromARGB(255, 4, 33, 83),
              //         fontWeight: FontWeight.bold),
              //   ),
              // ),
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
}

const TextStyle _labelStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 18,
  color: Color.fromARGB(255, 4, 33, 83),
);
