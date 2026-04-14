import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/core/widgets/my_buttons.dart';
import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';

class UpdateBanner extends StatefulWidget {
  final BannerEntity banner;
  const UpdateBanner({super.key, required this.banner});

  @override
  State<UpdateBanner> createState() => _UpdateBannerPageState();
}

class _UpdateBannerPageState extends State<UpdateBanner> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController linkController;
  late TextEditingController descriptionController;
  late TextEditingController bannerTypeController;

  List<String> Images = [];

  List<XFile?> selectedImages = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.banner.title);
    linkController = TextEditingController(text: widget.banner.link ?? "");
    descriptionController =
        TextEditingController(text: widget.banner.description ?? "");
    bannerTypeController =
        TextEditingController(text: widget.banner.bannerType);
    Images.add(widget.banner.bannerImage);
  }

  @override
  void dispose() {
    titleController.dispose();
    linkController.dispose();
    descriptionController.dispose();
    bannerTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Banner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title', style: TextStyles.labelStyle),
              MyTextField(
                controller: titleController,
                hintText: "Enter Banner Title",
                obscureText: false,
                isContentPadding: true,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Banner Type', style: TextStyles.labelStyle),
              DropdownSearch<String>(
                selectedItem: bannerTypeController.text,
                onChanged: (value) {
                  bannerTypeController.text = value!;
                },
                validator: BookFormValidator.validateBannerTypes,
                decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        hintText: 'Select Banner Type')),
                items: (f, cs) => ["Ads", "Banner", "Donation", "Info"],
                popupProps: const PopupProps.menu(fit: FlexFit.loose),
              ),
              const SizedBox(height: 16),
              const Text('Banner Description (Optional)',
                  style: TextStyles.labelStyle),
              MyTextField(
                controller: descriptionController,
                hintText: "Enter Banner Description",
                obscureText: false,
                isContentPadding: true,
                maxlines: 5,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              const Text('Banner Link (Optional)',
                  style: TextStyles.labelStyle),
              MyTextField(
                controller: linkController,
                hintText: "Enter Banner Link",
                obscureText: false,
                isContentPadding: true,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              const Text('Image', style: TextStyles.labelStyle),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: (Images.isNotEmpty || selectedImages.isNotEmpty)
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: Images.isNotEmpty
                            ? Images.length
                            : selectedImages.length,
                        itemBuilder: (context, index) {
                          final isNetworkImage = Images.isNotEmpty;

                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: isNetworkImage
                                      ? CachedNetworkImage(
                                          imageUrl: Images[index],
                                          width: 160,
                                          height: 180,
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
                                      if (isNetworkImage) {
                                        Images.removeAt(index);
                                      } else {
                                        selectedImages.removeAt(index);
                                      }
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
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, color: Colors.grey),
                            SizedBox(height: 4),
                            Text(
                              "Upload Images",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Update Banner',
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (Images.isEmpty && selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image')),
        );
        return;
      }
      // if(selectedImages.isNotEmpty){
      //   final imageFile = File(selectedImages.first!.path);
      // }

      context.read<BannerBloc>().add(UpdateBannerEvent(
            id: widget.banner.id ?? "",
            title: titleController.text,
            link: linkController.text.isNotEmpty ? linkController.text : "",
            description: descriptionController.text,
            bannerType: bannerTypeController.text,
            bannerImage: selectedImages.isNotEmpty
                ? File(selectedImages.first!.path)
                : File(Images.first),
          ));

      Navigator.pop(context);
    }
  }

  void dialogPermission() async {
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
                  await pickImage(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
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
