import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/variant/variant_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/add_book_variants_section.dart';

class ManageBookVariantsPage extends StatelessWidget {
  final BookCrudModel bookCrudModel;

  const ManageBookVariantsPage({
    super.key,
    required this.bookCrudModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VariantBloc>(
      create: (_) => getIt<VariantBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Manage Book Variants",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF042153),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AddBookVariantsSection(
            bookCrudModel: bookCrudModel,
            onBack: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
