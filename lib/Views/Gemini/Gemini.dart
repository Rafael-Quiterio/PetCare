import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/Services/tasks_Store.dart';
import 'package:animalapp/UI/styled_text.dart';
import 'package:animalapp/UI/theme.dart';
import 'package:animalapp/providers/gemini_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeminiPage extends StatelessWidget {
  const GeminiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GeminiProvider(),
      child: const GeminiChatScreen(),
    );
  }
}

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

@override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GeminiProvider>(context, listen: false);
      final animalStore = Provider.of<AnimalStore>(context, listen: false);
      final taskStore = Provider.of<TasksStore>(context, listen: false);

      // Atualizar dados
      provider.updateAnimals(animalStore.animals);
      provider.updateTasks(taskStore.tasks);
      
      // dispara a mensagem de "Olá")
      if (!provider.isInitialized) {
         provider.connectToGemini();
      }
    });
  }

  void _sendMessage() {
    final provider = Provider.of<GeminiProvider>(context, listen: false);
    
    // Check if AI is initialized
    if (!provider.isInitialized) {
      print('Provider not initialized');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI is initializing... Please wait.')),
      );
      return;
    }

    final text = _controller.text.trim();
    print('Text to send: "$text"');
    if (text.isEmpty) {
      print('Text is empty, returning');
      return;
    }

    print('Sending message...');
    provider.sendMessage(text);
    _controller.clear();
    print('Field cleared');

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('GeminiChatScreen build() called');
    final provider = Provider.of<GeminiProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Header inside card
          Card(
            color: AppColors.secondaryAccent.withValues(alpha: 0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  StyledHeading('AI Assistant'),
                  SizedBox(height: 4),
                  StyledText(
                    'Ask about care, food, health, and tips for your pets.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chat messages
          Expanded(
            child: Card(
              color: AppColors.secondaryAccent.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: provider.messages.isEmpty
                  ? Center(
                      child: Text(
                        'Start chatting with AI',
                        style: TextStyle(color: AppColors.textColor.withValues(alpha: 0.5)),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        final msg = provider.messages[index];
                        final isUser = msg.sender == 'user';
                        print('Building message $index: ${msg.sender} - ${msg.message}');

                        return Align(
                          alignment:
                              isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.primaryColor
                                  : AppColors.secondaryAccent,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft:
                                    Radius.circular(isUser ? 12 : 0),
                                bottomRight:
                                    Radius.circular(isUser ? 0 : 12),
                              ),
                              border: Border.all(
                                color: isUser
                                    ? Colors.transparent
                                    : AppColors.primaryAccent.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              msg.message,
                              style: TextStyle(
                                fontSize: 15,
                                color: isUser
                                    ? AppColors.secondaryColor
                                    : AppColors.textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Input field with send button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle:
                        TextStyle(color: AppColors.textColor.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppColors.secondaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}