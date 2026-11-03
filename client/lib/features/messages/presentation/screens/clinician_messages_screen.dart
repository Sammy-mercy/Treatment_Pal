// features/messages/presentation/screens/clinician_messages_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MessageItem {
  final String text;
  final bool fromMe;
  final String time;

  const MessageItem({
    required this.text,
    required this.fromMe,
    required this.time,
  });
}

class ClinicianMessagesScreen extends StatefulWidget {
  const ClinicianMessagesScreen({super.key});

  @override
  State<ClinicianMessagesScreen> createState() => _ClinicianMessagesScreenState();
}

class _ClinicianMessagesScreenState extends State<ClinicianMessagesScreen> {
  final _messageController = TextEditingController();

  int _selectedPatientIndex = 0;

  final List<Map<String, dynamic>> _threads = [
    {
      'id': 'p1',
      'name': 'Alex Rivera',
      'initials': 'AR',
      'regimen': 'Ibuprofen · Ankle Exercises',
      'lastMessage': 'Can I take my evening dose an hour later?',
      'time': '09:24 AM',
      'unread': 1,
    },
    {
      'id': 'p2',
      'name': 'Maya Chen',
      'initials': 'MC',
      'regimen': 'Lisinopril 10 mg',
      'lastMessage': 'Blood pressure has been steady this week.',
      'time': 'Yesterday',
      'unread': 0,
    },
    {
      'id': 'p3',
      'name': 'Jordan Blake',
      'initials': 'JB',
      'regimen': 'Physical Therapy (Shoulder)',
      'lastMessage': 'Should I continue the resistance band reps?',
      'time': 'Sep 27',
      'unread': 0,
    },
  ];

  late final Map<String, List<MessageItem>> _conversations = {
    'p1': [
      const MessageItem(
        text: 'Hello Dr. Carter, I completed the morning ankle exercise set.',
        fromMe: false,
        time: '08:45 AM',
      ),
      const MessageItem(
        text: 'Great job Alex! How was the range of motion during the circles?',
        fromMe: true,
        time: '09:05 AM',
      ),
      const MessageItem(
        text: 'Much better! Quick question: Can I take my evening dose an hour later? I have a late meeting today.',
        fromMe: false,
        time: '09:24 AM',
      ),
    ],
    'p2': [
      const MessageItem(
        text: 'Good morning Dr. Carter, my readings have stabilized around 122/80.',
        fromMe: false,
        time: 'Yesterday',
      ),
      const MessageItem(
        text: 'That is wonderful news Maya. Keep taking it with your breakfast consistently.',
        fromMe: true,
        time: 'Yesterday',
      ),
    ],
    'p3': [
      const MessageItem(
        text: 'Hello doctor, slight soreness after the new shoulder resistance reps.',
        fromMe: false,
        time: 'Sep 27',
      ),
    ],
  };

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentPatientId = _threads[_selectedPatientIndex]['id'] as String;
    setState(() {
      _conversations[currentPatientId]?.add(
        MessageItem(
          text: text,
          fromMe: true,
          time: 'Just now',
        ),
      );
      _threads[_selectedPatientIndex]['lastMessage'] = text;
      _threads[_selectedPatientIndex]['time'] = 'Just now';
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: const Text('Clinical Inquiries & Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 320,
                  child: _buildThreadsList(),
                ),
                const VerticalDivider(width: 1, color: AppColors.line),
                Expanded(
                  child: _buildActiveChat(),
                ),
              ],
            );
          }

          return _buildMobileView();
        },
      ),
    );
  }

  Widget _buildThreadsList() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Patient Conversations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _threads.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
              itemBuilder: (context, index) {
                final thread = _threads[index];
                final isSelected = index == _selectedPatientIndex;
                final unread = (thread['unread'] as int?) ?? 0;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryLight,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF3E8E5A).withValues(alpha: 0.15),
                    child: Text(
                      thread['initials'] as String,
                      style: const TextStyle(
                        color: Color(0xFF3E8E5A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        thread['time'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: unread > 0 ? const Color(0xFF3E8E5A) : AppColors.muted,
                          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    thread['lastMessage'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: unread > 0 ? AppColors.ink : AppColors.muted,
                      fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedPatientIndex = index;
                      _threads[index]['unread'] = 0;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChat() {
    final thread = _threads[_selectedPatientIndex];
    final patientId = thread['id'] as String;
    final messages = _conversations[patientId] ?? [];

    return Container(
      color: AppColors.ground,
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF3E8E5A),
                  radius: 18,
                  child: Text(
                    thread['initials'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        thread['regimen'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),

          // Message Bubbles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // Compose Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Write a response to ${thread['name']}...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
                      filled: true,
                      fillColor: AppColors.ground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8E5A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageItem msg) {
    return Align(
      alignment: msg.fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.fromMe ? const Color(0xFF3E8E5A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.fromMe ? 16 : 4),
            bottomRight: Radius.circular(msg.fromMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.fromMe ? Colors.white : AppColors.ink,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: TextStyle(
                color: msg.fromMe ? Colors.white70 : AppColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _threads.length,
            itemBuilder: (context, index) {
              final thread = _threads[index];
              final isSelected = index == _selectedPatientIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  selectedColor: const Color(0xFFE9F6F1),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFF3E8E5A),
                        child: Text(
                          thread['initials'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(thread['name'] as String),
                    ],
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedPatientIndex = index;
                      _threads[index]['unread'] = 0;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildActiveChat()),
      ],
    );
  }
}
