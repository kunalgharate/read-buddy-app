import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/core/theme/text_styles.dart';
import 'package:read_buddy_app/core/widgets/my_buttons.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';

class AddBanner extends StatefulWidget {
  const AddBanner({super.key});

  @override
  State<AddBanner> createState() => _AddBannerState();
}

class _AddBannerState extends State<AddBanner> {
  List<XFile?> selectedImages = [];
  String? BannerType;
  TextEditingController BannerTypeController = TextEditingController();
  TextEditingController BannerTitleController = TextEditingController();
  TextEditingController BannerDescriptionController = TextEditingController();
  TextEditingController BannerlinkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    BannerTypeController.dispose();
    BannerTitleController.dispose();
    BannerDescriptionController.dispose();
    BannerlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Banner Image', style: TextStyles.labelStyle),
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
                  child: selectedImages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                "Upload Images",
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
                                      width: 160, // ✅ Matches previous style
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
                        ),
                ),
                const SizedBox(height: 16),
                DropdownSearch<String>(
                  selectedItem: BannerType,
                  onChanged: (value) {
                    BannerTypeController.text = value!;
                    BannerType = value;
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
                const Text('Banner Title', style: TextStyles.labelStyle),
                MyTextField(
                  controller: BannerTitleController,
                  validator: BookFormValidator.validateBannerTitle,
                  hintText: "Banner Title",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                const Text('Banner Description', style: TextStyles.labelStyle),
                MyTextField(
                  controller: BannerDescriptionController,
                  //validator: BookFormValidator.validateBannerDescription,
                  hintText: "Banner Description",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  maxlines: 5,
                ),
                const SizedBox(height: 16),
                const Text('Banner Link', style: TextStyles.labelStyle),
                MyTextField(
                  controller: BannerlinkController,
                  validator: BookFormValidator.validateBannerLink,
                  hintText: "Banner link",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  maxlines: 1,
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(
                  text: 'Submit',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedImages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please upload at least one image')),
                        );
                        return;
                      }
                      final url = BannerlinkController.text.trim();

                      final isDomain =
                          await BookFormValidator.isDomainReachable(url);

                      if (!isDomain) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("The URL domain is not reachable")),
                        );
                        return; // stop execution if not reachable
                      }

                      context.read<BannerBloc>().add(CreateBannerEvent(
                            title: BannerTitleController.text,
                            link: BannerlinkController.text.isNotEmpty
                                ? BannerlinkController.text
                                : null,
                            description: BannerDescriptionController.text,
                            // BannerDescriptionController.text.isNotEmpty
                            //     ? BannerDescriptionController.text
                            //     : null,
                            bannerType: BannerTypeController.text,
                            bannerImage: File(selectedImages[0]!.path),
                          ));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Banner submitted successfully!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
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
