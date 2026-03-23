import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/usecases/add_question.dart' as QuestionCrudUseCases;
import '../../domain/usecases/update_question.dart' as QuestionCrudUseCases;

class AddEditQuestionPage extends StatefulWidget {
  final QuestionEntity? question;

  const AddEditQuestionPage({super.key, this.question});

  @override
  State<AddEditQuestionPage> createState() => _AddEditQuestionPageState();
}

class _AddEditQuestionPageState extends State<AddEditQuestionPage> {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [];
  
  String selectedType = 'single';
  bool _isLoading = false;

  late final QuestionCrudUseCases.AddQuestion _addQuestionUseCase;
  late final QuestionCrudUseCases.UpdateQuestion _updateQuestionUseCase;

  @override
  void initState() {
    super.initState();
    _addQuestionUseCase = GetIt.instance<QuestionCrudUseCases.AddQuestion>();
    _updateQuestionUseCase = GetIt.instance<QuestionCrudUseCases.UpdateQuestion>();
    
    if (widget.question != null) {
      questionController.text = widget.question!.question;
      selectedType = widget.question!.type == QuestionType.single ? 'single' : 'multiple';
      
      for (var option in widget.question!.options) {
        TextEditingController controller = TextEditingController(text: option);
        optionControllers.add(controller);
      }
    } else {
      optionControllers.add(TextEditingController());
      optionControllers.add(TextEditingController());
    }
  }

  void addOption() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      setState(() {
        optionControllers[index].dispose();
        optionControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum 2 options required')),
      );
    }
  }

  Future<void> saveQuestion() async {
    if (questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter question')),
      );
      return;
    }

    List<String> options = [];
    for (var controller in optionControllers) {
      if (controller.text.isNotEmpty) {
        options.add(controller.text);
      }
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least 2 options')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuestionEntity newQuestion = QuestionEntity(
        id: widget.question?.id ?? '',
        question: questionController.text,
        options: options,
        type: selectedType == 'single' ? QuestionType.single : QuestionType.multiple,
      );

      if (widget.question == null) {
        await _addQuestionUseCase.call(newQuestion);
      } else {
        await _updateQuestionUseCase.call(newQuestion);
      }

      // ✅ P1 Fix: Check mounted before navigation after async operation
      if (!mounted) return;

      Navigator.pop(context, newQuestion);
    } catch (e) {
      // ✅ P1 Fix: Check mounted before using context in catch
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving question: $e')),
      );
    } finally {
      // ✅ P1 Fix: Check mounted before setState in finally block
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.question == null ? 'Add Question' : 'Edit Question',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: questionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter your question here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 12),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'single';
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedType == 'single' 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedType == 'single' 
                                  ? Colors.green
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'single',
                                groupValue: selectedType,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    selectedType = value.toString();
                                  });
                                },
                              ),
                              Text('Single Choice'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'multiple';
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedType == 'multiple' 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedType == 'multiple' 
                                  ? Colors.green
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'multiple',
                                groupValue: selectedType,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    selectedType = value.toString();
                                  });
                                },
                              ),
                              Text('Multiple Choice'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Answer Options',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                      ),
                      ElevatedButton.icon(
                        onPressed: addOption,
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  for (int i = 0; i < optionControllers.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: optionControllers[i],
                              decoration: InputDecoration(
                                hintText: 'Enter option ${i + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (optionControllers.length > 2)
                            IconButton(
                              onPressed: () => removeOption(i),
                              icon: Icon(Icons.delete, color: Colors.red[600]),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : saveQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.question == null ? 'Create Question' : 'Update Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}