import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../question_crud/domain/usecases/get_questions.dart' as QuestionCrudUseCases;
import '../widgets/dashboard_box_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _questionCount = 0;
  bool _isLoadingQuestions = true;
  
  late final QuestionCrudUseCases.GetQuestions _getQuestionsUseCase;

  @override
  void initState() {
    super.initState();
    _getQuestionsUseCase = getIt<QuestionCrudUseCases.GetQuestions>();
    _loadQuestionCount();
  }

  Future<void> _loadQuestionCount() async {
    try {
      final questions = await _getQuestionsUseCase.call();
      if (mounted) {
        setState(() {
          _questionCount = questions.length;
          _isLoadingQuestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _questionCount = 0;
          _isLoadingQuestions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        actions: [
          //logout action
          IconButton(
            onPressed: () {
              final secureStorage = getIt<SecureStorageUtil>();
              secureStorage.clearAll();
              Navigator.pushReplacementNamed(context, '/signin');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage books, categories and users',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardBoxWidget(
                    title: 'Books Donated',
                    count: 5,
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'Books Request',
                    count: 8,
                    color: Colors.redAccent,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'New Users',
                    count: 5,
                    color: Colors.lightBlue,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.85, // Adjust this to give enough height
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  DashboardBoxWidget(
                    title: 'Categories',
                    count: 12,
                    icon: Icons.category,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/category');
                    },
                  ),
                  DashboardBoxWidget(
                      title: 'Books',
                      count: 236,
                      icon: Icons.book,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/books');
                      }),
                  DashboardBoxWidget(
                    title: 'Donations',
                    count: 318,
                    icon: Icons.card_giftcard,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/donation');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Request',
                    count: 12,
                    icon: Icons.list_alt,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'Users',
                    count: 12,
                    icon: Icons.people,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'Banner',
                    count: 12,
                    icon: Icons.people,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/banner');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Questions',
                    count: _isLoadingQuestions ? 0 : _questionCount,
                    icon: Icons.quiz,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/questions');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
