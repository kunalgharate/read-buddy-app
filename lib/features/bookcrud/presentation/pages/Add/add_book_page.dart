import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/utils/auto_complete.dart';
import 'package:read_buddy_app/core/utils/book_validators.dart';
import 'package:read_buddy_app/core/utils/book_value_items.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/core/widgets/my_textfields.dart';

class AddBookPage extends StatefulWidget {
  final Function onContinue;
  const AddBookPage({super.key, required this.onContinue});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();

  Item? selectedCategory;
  String? selectedGenre;
  String? selectedLanguage;
  String? selectedFormat;
  TextEditingController bookTitleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController pagesController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController isbnController = TextEditingController();
  TextEditingController publisherController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    selectedFormat = BookValueItems().bookFormats[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Book Title',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              MyTextField(
                controller: bookTitleController,
                hintText: " Enter book title",
                validator: BookFormValidator.validateTitle,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              const Text(
                'Author Name',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              MyTextField(
                controller: authorController,
                hintText: " Enter author name",
                validator: BookFormValidator.validateAuthor,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              const Text(
                'Categories',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              GenericAutocomplete<Item>(
                options: BookValueItems.bookCategories,
                controller: categoryController,
                displayString: (item) => item.name,
                onSelected: (Item item) {
                  selectedCategory = item;
                  categoryController.text =
                      item.name; // update controller with name
                  print('Selected: ID=${item.id}, Name=${item.name}');
                },
                validator: BookFormValidator.validateCategory,
                hintText: 'Search Categories',
              ),
              const SizedBox(height: 16),
              const Text(
                'Genre',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              DropdownSearch<String>(
                selectedItem: selectedGenre,
                onChanged: (value) {
                  selectedGenre = value;
                },
                validator: BookFormValidator.validateGenre,
                decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        hintText: 'Seacrch Genre')),
                items: (f, cs) => BookValueItems().bookGenres,
                popupProps: PopupProps.menu(fit: FlexFit.loose),
              ),
              const SizedBox(height: 16),
              const Text(
                'Number of Pages',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              MyTextField(
                controller: pagesController,
                validator: BookFormValidator.validatePages,
                hintText: " Enter pages",
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'ISBN',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              MyTextField(
                controller: isbnController,
                validator: BookFormValidator.validateISBN,
                hintText: " Enter ISBN",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Publisher',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color.fromARGB(255, 4, 33, 83)),
                        ),
                        MyTextField(
                          controller: publisherController,
                          validator: BookFormValidator.validatePublisher,
                          hintText: " Publisher",
                          obscureText: false,
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Year',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color.fromARGB(255, 4, 33, 83)),
                        ),
                        MyTextField(
                          controller: yearController,
                          validator: BookFormValidator.validateYear,
                          digitsOnly: true,
                          hintText: " Year",
                          obscureText: false,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Book Format',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              Wrap(
                spacing: 16, // space between items horizontally
                runSpacing: 8, // space between rows
                children: BookValueItems().bookFormats.map((format) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 70) /
                        2, // two items per row with padding
                    child: Row(
                      children: [
                        Radio<String>(
                          value: format,
                          groupValue: selectedFormat,
                          onChanged: (value) {
                            setState(() {
                              selectedFormat = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            format,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Language',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color.fromARGB(255, 4, 33, 83)),
              ),
              DropdownSearch<String>(
                selectedItem: selectedLanguage,
                onChanged: (value) {
                  selectedLanguage = value;
                },
                validator: BookFormValidator.validateLanguage,
                decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        hintText: 'Select Language')),
                items: (f, cs) => ["Tamil", 'English', 'Hindi', 'Malayalam'],
                popupProps: const PopupProps.menu(fit: FlexFit.loose),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // All fields are valid, proceed to next page or submit

                      final book = BookCrudModel(
                        title: bookTitleController.text,
                        author: authorController.text,
                        category: selectedCategory!.id,
                        genre: selectedGenre ?? '',
                        format: selectedFormat ?? '',
                        language: selectedLanguage ?? '',
                        isbn: isbnController.text,
                        publisher: publisherController.text,
                        publicationYear: int.tryParse(yearController.text) ?? 0,
                        numberOfCopies: int.tryParse(pagesController.text) ?? 1,
                        isAvailable: true,
                        status: "available",
                        edition: '',
                        condition: '',
                        tags: [],
                        location: '',
                        ownerId: '',
                        coverImageUrl: '',
                        additionalImages: [],
                        description: '',
                        notes: '',
                        additionalImageUrls: [],
                        pages: null,
                      );
                      widget.onContinue(book);
                    } else {
                      // One or more fields are invalid, show errors
                    }
                  },
                  // onPressed: () {

                  //   // Navigator.push(
                  //   //     context,
                  //   //     MaterialPageRoute(
                  //   //         builder: (context) => AddBookPage2(
                  //   //               onBack: () {},
                  //   //             )));
                  // },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value as needed
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  )),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
