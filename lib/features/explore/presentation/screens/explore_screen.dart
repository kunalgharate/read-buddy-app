import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:read_buddy_app/features/explore/presentation/bloc/explore_event.dart';
import 'package:read_buddy_app/features/explore/presentation/bloc/explore_state.dart';
import 'package:read_buddy_app/features/explore/presentation/widgets/explore_widgets.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExploreBloc>()..add(LoadExploreData()),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: BlocBuilder<ExploreBloc, ExploreState>(
          builder: (context, state) {
            if (state is ExploreLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ExploreError) {
              return Center(child: Text(state.message));
            }

            if (state is ExploreLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ExploreSearchBar(),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: FilterChips(),
                  ),
                  const SizedBox(height: 24),
                  
                  if (state.selectedCategoryId != null) ...[
                    // Selected Category View
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.read<ExploreBloc>().add(const SelectCategory(null)),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF03405B)),
                        ),
                        const Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF03405B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.sections.firstWhere((s) => s.category.id == state.selectedCategoryId).books.length,
                        itemBuilder: (context, index) {
                          final section = state.sections.firstWhere((s) => s.category.id == state.selectedCategoryId);
                          return ExploreBookCard(book: section.books[index]);
                        },
                      ),
                    ),
                  ] else ...[
                    // Sections View
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Popular Genres',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF03405B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 35,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.parentCategories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final category = state.parentCategories[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      category.title,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...state.sections.map((section) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: section.category.title,
                                  onSeeAll: () {
                                    context.read<ExploreBloc>().add(SelectCategory(section.category.id));
                                  },
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: section.books.length,
                                    itemBuilder: (context, index) => ExploreBookCard(book: section.books[index]),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            )),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
