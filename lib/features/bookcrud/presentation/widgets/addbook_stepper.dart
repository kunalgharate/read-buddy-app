import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/Add/add_book_page.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/Add/add_book_page2.dart';

class BookStepper extends StatefulWidget {
  const BookStepper({super.key});

  @override
  State<BookStepper> createState() => _BookStepperState();
}

class _BookStepperState extends State<BookStepper> {
  int currentStep = 0;
  BookCrudModel? bookModel;

  void nextStep(BookCrudModel modelFromPage1) {
    setState(() {
      bookModel = modelFromPage1;
      currentStep = 1;
    });
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Book Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 3, 38, 98),
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(context,
        //             MaterialPageRoute(builder: (context) => BooksListPage()));
        //       },
        //       icon: Icon(Icons.list_alt))
        // ],
      ),
      body: Stepper(
        elevation: 0,
        type: StepperType.horizontal,
        currentStep: currentStep,
        controlsBuilder: (_, __) => const SizedBox.shrink(),
        steps: [
          Step(
            title: const Text("1"),
            isActive: currentStep == 0,
            state: currentStep == 0 ? StepState.editing : StepState.complete,
            content: AddBookPage(onContinue: nextStep),
          ),
          Step(
            title: const Text("2"),
            isActive: currentStep == 1,
            state: currentStep == 1 ? StepState.editing : StepState.indexed,
            content: bookModel == null
                ? const Center(
                    child: Text(
                      "Error: Book data not found. Please go back and re-enter.",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : AddBookPage2(
                    onBack: previousStep,
                    bookCrudModel: bookModel!,
                  ),
          ),
        ],
      ),
    );
  }
}
