import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsa_app/src/features/profile/profile_page.dart';
import 'package:lsa_app/src/features/auth/login_page.dart';
import 'package:lsa_app/src/utils/constants.dart';
import 'package:lsa_app/src/models/conversation.dart';
import 'package:lsa_app/src/models/message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Conversation> _recentConversations = [];
  Conversation? _currentConversation;
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isWaitingForResponse = false;
  String? _username;
  String? _currentlyTypingMessageId;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _loadUsername();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final savedUsername = prefs.getString('username');

    setState(() {
      _username = savedUsername;
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('conversations')
          .select()
          .eq('sender', userId)
          .order('created_at', ascending: false);

      setState(() {
        _recentConversations =
            data.map((map) => Conversation.fromMap(map)).toList();
        _isLoading = false;
      });

      if (_recentConversations.isNotEmpty) {
        _loadConversation(_recentConversations.first);
      } else {
        _startNewChat();
      }
    } catch (error) {
      print('Error loading messages: $error');
      if (mounted) {
        context.showSnackBar(message: 'Error loading messages');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadConversation(Conversation conversation) async {
    setState(() {
      _isLoading = true;
      _currentConversation = conversation;
    });
    try {
      final data = await supabase
          .from('messages')
          .select()
          .eq('convo_id', conversation.id)
          .order('time', ascending: true);

      setState(() {
        _messages = data.map((map) => Message.fromMap(map)).toList();
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Error loading messages');
        print(error);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> deleteConversation(Conversation conversation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase
          .from('conversations')
          .delete()
          .eq('id', conversation.id);

      setState(() {
        _recentConversations.removeWhere((c) => c.id == conversation.id);

        if (_currentConversation?.id == conversation.id) {
          if (_recentConversations.isNotEmpty) {
            _loadConversation(_recentConversations.first);
          } else {
            _currentConversation = null;
            _messages.clear();
          }
        }
      });

      if (mounted) {
        Navigator.pop(context); // Close drawer
        context.showSnackBar(message: 'Conversation deleted');
      }
    } catch (e) {
      print('Delete error: $e');
      if (mounted) {
        context.showSnackBar(message: 'Failed to delete conversation');
      }
    }
  }


  Future<void> _startNewChat() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = supabase.auth.currentUser!.id;
      final newConversation = await supabase
          .from('conversations')
          .insert({'sender': userId})
          .select()
          .single();

      final conversation = Conversation.fromMap(newConversation);

      setState(() {
        _currentConversation = conversation;
        _messages = [
          Message(
            conversationId: conversation.id,
            sender: 'bot',
            content: 'HI THERE, WHAT CAN I HELP YOU\nWITH TODAY',
            time: DateTime.now(),
          )
        ];
        _recentConversations.insert(0, conversation);
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Error starting new chat');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentConversation == null) {
      return;
    }

    final userMessageContent = _messageController.text.trim();
    _messageController.clear();

    final userMessage = Message(
      conversationId: _currentConversation!.id,
      sender: supabase.auth.currentUser!.id,
      content: userMessageContent,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isWaitingForResponse = true;
    });

    _scrollToBottom();

    try {
      await supabase.from('messages').insert(userMessage.toMap());

      final aiResponseContent = await _getAiResponse(userMessageContent);

      final botMessage = Message(
        conversationId: _currentConversation!.id,
        sender: 'bot',
        content: aiResponseContent,
        time: DateTime.now(),
      );

      setState(() {
        _isWaitingForResponse = false;
        _messages.add(botMessage);
        _currentlyTypingMessageId = botMessage.time.millisecondsSinceEpoch.toString();
      });
      
      await supabase.from('messages').insert(botMessage.toMap());
      
      _scrollToBottom();
    } catch (error) {
      print(error);
      setState(() {
        _isWaitingForResponse = false;
      });
      if (mounted) {
        context.showSnackBar(message: 'Error sending message');
      }
    }
  }

  Future<String> _getAiResponse(String message) async {
    const String apiUrl = 'https://zylla.onrender.com/askZylla/text';

    print('Sending message to AI server: $message');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'question': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "Sorry, I couldn't process that due to connectivity or server issues";
      } else {
        print('Server responded with status: ${response.statusCode}');
        return "Sorry, something went wrong with the server.";
      }
    } catch (e) {
      print('HTTP request failed: $e');
      return "Sorry, I couldn't connect to the internet.";
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Error signing out');
      }
    }
  }

  void _onTypewriterComplete(String messageId) {
    if (_currentlyTypingMessageId == messageId) {
      setState(() {
        _currentlyTypingMessageId = null;
      });
    }
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(4, 224, 224, 224),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Zylla is thinking...',
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Preloader());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E5F5),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF9C27B0)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'LSA CHATBOT',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9C27B0),
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.deepPurple,
                backgroundImage: const AssetImage('assets/images/fox.png'),
                child: supabase.auth.currentUser?.userMetadata?['username'] != null
                    ? Text(
                        supabase.auth.currentUser!.userMetadata!['username']
                                .isNotEmpty
                            ? supabase.auth.currentUser!.userMetadata!['username']
                                .substring(0, 1)
                                .toUpperCase()
                            : '',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      )
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF4A148C),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'ZYLLA ',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'v 0.9.6',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _startNewChat();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'New Chat',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _fetchConversations,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recentConversations.length,
                itemBuilder: (context, index) {
                  final conversation = _recentConversations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Card(
                      color: _currentConversation?.id == conversation.id
                          ? const Color(0xFF9C27B0)
                          : const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          'Chat - ${conversation.createdAt.toLocal().toString().split('.')[0]}',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white70),
                          onPressed: () {
                            deleteConversation(conversation);
                          },
                        ),
                        onTap: () {
                          _loadConversation(conversation);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white30),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: Text(
                'Manage Profile',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text(
                'Sign-out',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              onTap: _signOut,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/botHello.png',
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'HI THERE, WHAT CAN I HELP YOU\nWITH TODAY',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length + (_isWaitingForResponse ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isWaitingForResponse) {
                        return _buildLoadingIndicator();
                      }
                      
                      final message = _messages[index];
                      final isUser = message.sender == supabase.auth.currentUser!.id;
                      final messageId = message.time.millisecondsSinceEpoch.toString();
                      final isCurrentlyTyping = _currentlyTypingMessageId == messageId;
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF9C27B0) : const Color.fromARGB(4, 224, 224, 224),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: isUser
                              ? Text(
                                  message.content,
                                  style: GoogleFonts.poppins(color: Colors.white),
                                )
                              : isCurrentlyTyping
                                  ? TypewriterText(
                                      text: message.content,
                                      style: GoogleFonts.poppins(color: Colors.black87),
                                      speed: const Duration(milliseconds: 5),
                                      messageId: messageId,
                                      onComplete: () => _onTypewriterComplete(messageId),
                                    )
                                  : MarkdownBody(
                                      data: message.content,
                                      styleSheet: MarkdownStyleSheet(
                                        p: GoogleFonts.poppins(color: Colors.black87),
                                        strong: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
                                        em: GoogleFonts.poppins(fontStyle: FontStyle.italic, color: Colors.black87),
                                        code: GoogleFonts.poppins(),
                                      ),
                                    ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: const Color(0xFF9C27B0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    style: GoogleFonts.poppins(color: Colors.black87),
                    maxLines: 3,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: Transform.rotate(
                      angle: -0.5,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                    onPressed: _isWaitingForResponse ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Typewriter effect widget for AI messages
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final VoidCallback? onComplete;
  final String messageId;

  const TypewriterText({
    Key? key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 30),
    this.onComplete,
    required this.messageId,
  }) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTypewriter() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayedText,
      styleSheet: MarkdownStyleSheet(
        p: widget.style ?? GoogleFonts.poppins(color: Colors.black87),
        strong: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        em: GoogleFonts.poppins(fontStyle: FontStyle.italic, color: Colors.black87),
        code: GoogleFonts.poppins(),
      ),
    );
  }
}