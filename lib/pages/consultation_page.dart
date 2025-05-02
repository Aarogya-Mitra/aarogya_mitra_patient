import 'package:arogya_mitra_patient/database/firebase_db.dart';
import 'package:arogya_mitra_patient/models/consultation.dart';
import 'package:arogya_mitra_patient/models/patient_profile.dart';
import 'package:arogya_mitra_patient/pages/call_page.dart';
import 'package:arogya_mitra_patient/pages/consultation_via_voice.dart';
import 'package:arogya_mitra_patient/pages/home_page.dart';
import 'package:arogya_mitra_patient/services/gemini_service.dart';
import 'package:arogya_mitra_patient/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool isWaitingForResponse = false;
  String? lastQuestion;

  @override
  void initState() {
    super.initState();
    // Start with the first question
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage("What brings you in today?");
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isMe: true, time: DateTime.now()),
      );
      isWaitingForResponse = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get next question from Gemini
      final nextQuestion = await _geminiService.getNextQuestion(
        userMessage,
        lastQuestion: lastQuestion,
      );

      lastQuestion = nextQuestion;

      // Check if the conversation has ended
      if (nextQuestion.contains("Thank you for providing your information")) {
        _addBotMessage(nextQuestion);
        _showSummaryDialog();
      } else {
        _addBotMessage(nextQuestion);
      }
    } catch (e) {
      print("Error getting next question: $e");
      _addBotMessage(
        "I apologize, but I'm having trouble processing your response. Could you please rephrase that?",
      );
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: false, time: DateTime.now()));
      isWaitingForResponse = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showSummaryDialog() {
    final List<Map<String, String>> summary = [];
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].isMe) {
        summary.add({
          "Question": i > 0 ? _messages[i - 1].text : "N/A",
          "Response": _messages[i].text,
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Your Responses"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: summary.length,
              itemBuilder: (context, index) {
                final item = summary[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q: ${item['Question']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("A: ${item['Response']}"),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAppointmentSummary();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Book Your Appointment"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewConsultation(String patientComplaintSummary) async {
    final now = DateTime.now();

    try {
      CustomDialog.showLoadingDialog(
        context,
        message: "Creating Consultation...",
      );
      // Get current user's profile to fetch the name
      final PatientProfile? userProfile = await FirebaseDb.getPatientProfile(
        FirebaseDb.auth.currentUser!.uid,
      );
      final patientName = userProfile?.name ?? 'Unknown Patient';

      final consultation = Consultation(
        id: '', // This will be assigned by Firestore
        patientId: FirebaseDb.auth.currentUser!.uid,
        doctorId: null, // Will be assigned when a doctor accepts
        title: patientName,
        status: 'open',
        createdAt: now,
        updatedAt: now,
        patientComplaint: patientComplaintSummary,
        patientName: patientName, // Add patient name
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      final consultationId = await FirebaseDb.createConsultation(consultation);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Consultation created successfully! A doctor will review it soon.",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back to patient home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating consultation: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAppointmentSummary() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate summary from Gemini
      final summary = await _geminiService.generateSummary();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show summary dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: const Text("Appointment Summary"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    "Your Appointment is registered. Join video consultation room.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Close all screens and navigate back to welcome screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _createNewConsultation(summary);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder:
                  //         (context) => VideoCallScreen(
                  //           channelName: authService.currentUser!.uid,
                  //           token: AppConstants.token,
                  //           appId: AppConstants.appId,
                  //           isPatient: true,
                  //         ),
                  //   ),
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CallPage(
                            roomID: FirebaseDb.auth.currentUser!.uid,
                          ),
                    ),
                  );
                },
                child: const Text("Join In"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to generate summary: $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100]),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          if (isWaitingForResponse)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Doctor is typing...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.time),
              style: TextStyle(
                color: message.isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: isWaitingForResponse ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsultationViaVoice(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}
