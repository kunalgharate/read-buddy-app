import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/usecases/get_questions.dart' as QuestionCrudUseCases;
import '../../domain/usecases/delete_question.dart' as QuestionCrudUseCases;
import 'add_edit_question_page.dart';

class QuestionListPage extends StatefulWidget {
  const QuestionListPage({super.key});

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  List<QuestionEntity> _questions = [];
  bool _isLoading = true;

  late final QuestionCrudUseCases.GetQuestions _getQuestionsUseCase;
  late final QuestionCrudUseCases.DeleteQuestion _deleteQuestionUseCase;

  @override
  void initState() {
    super.initState();
    _getQuestionsUseCase = GetIt.instance<QuestionCrudUseCases.GetQuestions>();
    _deleteQuestionUseCase = GetIt.instance<QuestionCrudUseCases.DeleteQuestion>();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final questions = await _getQuestionsUseCase.call();

      if (!mounted) return;
      
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void addQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuestionPage(),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      await loadQuestions();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added')),
      );
    }
  }

  void editQuestion(QuestionEntity question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuestionPage(question: question),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      await loadQuestions();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question updated')),
      );
    }
  }

  Future<void> deleteQuestion(String id) async {
    try {
      await _deleteQuestionUseCase.call(id);

      if (!mounted) return;
      
      await loadQuestions();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting question: $e')),
      );
    }
  }

  void showDeleteDialog(QuestionEntity question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Question?'),
        content: Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteQuestion(question.id);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Questions Management', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Icon(Icons.quiz, color: Colors.green, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Total Questions: ${_questions.length}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      QuestionEntity question = _questions[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      question.question,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      question.type == QuestionType.single ? 'Single' : 'Multiple',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        editQuestion(question);
                                      } else if (value == 'delete') {
                                        showDeleteDialog(question);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 18, color: Colors.red[600]),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text('Options:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
                              SizedBox(height: 8),
                              for (int i = 0; i < question.options.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          question.options[i],
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addQuestion,
        backgroundColor: Colors.green,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Question', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
