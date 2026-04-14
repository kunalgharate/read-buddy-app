import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
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
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  UserEntity? selectedUser;
  final List<String> _tags = [];
  String? cover_image;
  List<String> Images = [];
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
    ownerIdController.text = book.ownerName ?? "hhoo";
    cover_image = book.coverImageUrl;
    print("coverImageUrl is $cover_image");
    Images.addAll(book.additionalImageUrls ?? []);
    // Tags
    _tags.clear();
    _tags.addAll(book.tags);

    // // Owner ID
    final matchedUser = BookValueItems.usersList.firstWhere(
      (user) => user.id == book.ownerId,
      orElse: () => UserEntity(
          id: book.ownerId,
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
                      user.id; // update controller with name
                  print('Selected: ID=${user.id}, Name=${user.name}');
                }, // ✅ renamed for clarity

                hintText: 'Search Owner Names',
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
                height: 200, // Increased height to match image size
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: selectedCoverImageFile != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(selectedCoverImageFile!.path),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCoverImageFile = null;
                                  });
                                },
                                child: _buildCloseButton(),
                              ),
                            ),
                          ],
                        )
                      : (cover_image != null && cover_image!.isNotEmpty)
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: cover_image!,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        cover_image = null;
                                      });
                                    },
                                    child: _buildCloseButton(),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Text(
                                "Upload Cover Image",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Book Images', style: _labelStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Book Images', style: TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () {
                      if (Images.length + selectedImages.length >= 5) {
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
                height: (Images.isEmpty && selectedImages.isEmpty) ? 150 : 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: (Images.isEmpty && selectedImages.isEmpty)
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, color: Colors.grey),
                            SizedBox(height: 4),
                            Text(
                              "Upload Book Images",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          ...List.generate(Images.length, (index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: Images[index],
                                      width: double.infinity,
                                      height: 180,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        Images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
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
                          }),

                          // ✅ Local Selected Images (Vertical List)
                          ...List.generate(selectedImages.length, (index) {
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
                                  top: 10,
                                  right: 10,
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 3,
                                            offset: Offset(1, 1),
                                          )
                                        ],
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
                          }),
                        ],
                      ),
              ),
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
                      const SnackBar(
                          content: Text('Please press space to add your tag')),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    if (Images.isEmpty && selectedImages.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please upload an image')),
                      );
                      return;
                    }

                    // final imageFile = File(selectedImages.first!.path);

                    print("tagssssssss");
                    print(_tags.length);
                    final completeBook = widget.bookCrudModel.copyWith(
                      condition: conditionController.text,
                      location: locationController.text,
                      ownerId: selectedUser!.id,
                      // coversingleImage: selectedCoverImageFile,
                      additionalImages: selectedImages.isNotEmpty
                          ? selectedImages
                              .map((xfile) => File(xfile!.path))
                              .toList()
                          : Images.isNotEmpty
                              ? Images.map((imgPath) => File(imgPath)).toList()
                              : null,
                      description: descriptionController.text,
                      notes: notesController.text,
                      tags: _tags,
                    );
                    print("Commmmmmmplete Boookk");

                    context
                        .read<BookCrudBloc>()
                        .add(AddBookCrudEvent(completeBook));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('updating form...')),
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
      shape: const RoundedRectangleBorder(
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

  void singleImagePermission() async {
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
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
}

Widget _buildCloseButton() {
  return Container(
    decoration: const BoxDecoration(
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
    padding: const EdgeInsets.all(5),
    child: const Icon(
      Icons.close,
      color: Colors.red,
      size: 20,
    ),
  );
}

const TextStyle _labelStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 18,
  color: Color.fromARGB(255, 4, 33, 83),
);
