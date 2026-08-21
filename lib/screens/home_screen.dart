import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zishu_ai/providers/assistant_provider.dart';
import 'package:zishu_ai/providers/settings_provider.dart';
import 'package:zishu_ai/providers/notification_provider.dart';
import 'package:zishu_ai/widgets/orb_widget.dart';
import 'package:zishu_ai/widgets/chat_bubble.dart';
import 'package:zishu_ai/widgets/proactive_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final assistantProvider = Provider.of<AssistantProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zishu AI'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Wake Word Toggle
          IconButton(
            icon: Icon(
              assistantProvider.isWakeWordEnabled
                  ? Icons.hearing
                  : Icons.hearing_disabled,
              color: assistantProvider.isWakeWordEnabled
                  ? Colors.green
                  : Colors.grey,
            ),
            tooltip: 'Wake Word: "Zishu"',
            onPressed: () {
              assistantProvider.toggleWakeWord();
            },
          ),
          // Always Listening Toggle
          IconButton(
            icon: Icon(
              assistantProvider.isAlwaysListening
                  ? Icons.mic_off
                  : Icons.mic,
              color: assistantProvider.isAlwaysListening
                  ? Colors.green
                  : Colors.grey,
            ),
            tooltip: assistantProvider.isAlwaysListening
                ? 'Always Listening ON'
                : 'Always Listening OFF',
            onPressed: () {
              assistantProvider.toggleAlwaysListening();
            },
          ),
          // Theme Toggle
          IconButton(
            icon: Icon(
              settingsProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              settingsProvider.toggleTheme();
            },
          ),
          // Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
                case 'about':
                  Navigator.pushNamed(context, '/about');
                  break;
                case 'support':
                  Navigator.pushNamed(context, '/support');
                  break;
                case 'clear':
                  assistantProvider.clearChatHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
              const PopupMenuItem(
                value: 'support',
                child: Text('Support'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear History'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Orb Widget
          OrbWidget(
            isListening: assistantProvider.isListening,
            isSpeaking: assistantProvider.isSpeaking,
            isProcessing: assistantProvider.isProcessing,
          ),
          
          // Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIcon(assistantProvider),
                const SizedBox(width: 8),
                _buildStatusText(assistantProvider),
                if (assistantProvider.isAlwaysListening)
                  _buildAlwaysListeningBadge(),
                if (assistantProvider.isWakeWordEnabled)
                  _buildWakeWordBadge(),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: assistantProvider.messages.length,
              itemBuilder: (context, index) {
                final message = assistantProvider.messages[index];
                if (message.type == MessageType.system ||
                    message.type == MessageType.proactive) {
                  return ProactiveMessage(text: message.text);
                }
                return ChatBubble(message: message);
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: assistantProvider.isAlwaysListening
                          ? 'Always listening... Say "Zishu" or tap mic'
                          : 'Type or tap mic...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            assistantProvider.processCommand(
                              _textController.text.trim()
                            );
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        assistantProvider.processCommand(text.trim());
                        _textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {
                      if (assistantProvider.isListening) {
                        assistantProvider._stopListening();
                      } else {
                        assistantProvider._startListening();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (assistantProvider.isListening) {
            assistantProvider._stopListening();
          } else {
            assistantProvider._startListening();
          }
        },
        child: Icon(
          assistantProvider.isListening ? Icons.stop : Icons.mic,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(AssistantProvider provider) {
    if (provider.isListening) {
      return const Icon(Icons.mic, color: Colors.red, size: 16);
    } else if (provider.isSpeaking) {
      return const Icon(Icons.volume_up, color: Colors.blue, size: 16);
    } else if (provider.isProcessing) {
      return const Icon(Icons.hourglass_empty, color: Colors.orange, size: 16);
    }
    return const Icon(Icons.circle, color: Colors.grey, size: 16);
  }

  Widget _buildStatusText(AssistantProvider provider) {
    String status = 'Idle';
    if (provider.isListening) status = 'Listening...';
    else if (provider.isSpeaking) status = 'Speaking...';
    else if (provider.isProcessing) status = 'Thinking...';
    
    return Text(
      status,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildAlwaysListeningBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Always On',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWakeWordBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Wake Word',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
