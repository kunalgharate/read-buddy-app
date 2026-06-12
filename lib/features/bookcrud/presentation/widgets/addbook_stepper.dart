import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
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
  bool _isSubmitting = false;

  void nextStep(BookCrudModel modelFromPage1) {
    setState(() {
      bookModel = modelFromPage1;
      currentStep = 1;
    });
  }

  void _onSubmit(BookCrudModel completedModel) {
    setState(() {
      bookModel = completedModel;
      _isSubmitting = true;
    });
    context.read<BookCrudBloc>().add(AddBookCrudEvent(completedModel));
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
      ),
      body: BlocListener<BookCrudBloc, BookCrudState>(
        listener: (context, state) {
          if (!_isSubmitting) return;

          if (state is BookCrudListLoaded) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Book added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else if (state is BookCrudError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Stepper(
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
                          onContinue: _onSubmit,
                        ),
                ),
              ],
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
