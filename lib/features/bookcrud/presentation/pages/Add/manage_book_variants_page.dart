import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/variant/variant_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/add_book_variants_section.dart';
import 'package:read_buddy_app/core/utils/access_control.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';

class ManageBookVariantsPage extends StatelessWidget {
  final BookCrudModel bookCrudModel;

  const ManageBookVariantsPage({
    super.key,
    required this.bookCrudModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileInitial || profileState is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final canManage = profileState is ProfileLoaded &&
            AccessControl.canManageBooks(profileState.user.role);

        if (!canManage) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Access Restricted",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF042153),
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: Color(0xFF042153),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You do not have permission to manage books.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
      },
    );
  }
}
