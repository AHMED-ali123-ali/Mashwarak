import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  late AnimationController _icon3dController;
  late Animation<double> _icon3dAnimation;
  int _tappedQuickActionIndex = -1;
  PageController? _quickMenuPageController;
  int _quickMenuCurrentPage = 0;
  Timer? _quickMenuAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    // 3D tap effect controller
    _icon3dController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
      value: 0,
    );
    _icon3dAnimation = Tween<double>(begin: 0, end: 0.28).animate(
      CurvedAnimation(parent: _icon3dController, curve: Curves.easeOut),
    );

    // QuickMenu PageController and auto-scroll
    _quickMenuPageController = PageController(
      initialPage: 0,
      viewportFraction: 0.42, // ~140/330 for typical device width
    );
    _quickMenuCurrentPage = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuickMenuAutoScroll();
    });
  }

  @override
  void dispose() {
    _icon3dController.dispose();
    _quickMenuAutoScrollTimer?.cancel();
    _quickMenuPageController?.dispose();
    super.dispose();
  }
  void _startQuickMenuAutoScroll() {
    _quickMenuAutoScrollTimer?.cancel();
    if (_quickMenuPageController == null) return;
    final int itemCount = quickActions.length;
    _quickMenuAutoScrollTimer = Timer.periodic(const Duration(milliseconds: 1700), (timer) {
      if (_quickMenuPageController == null || !_quickMenuPageController!.hasClients) return;
      int nextPage = _quickMenuCurrentPage + 1;
      if (nextPage >= itemCount) {
        nextPage = 0;
      }
      _quickMenuCurrentPage = nextPage;
      _quickMenuPageController!.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];
  bool showWelcomeText = true;
  bool isTyping = false;
  bool _pulse = false;

  // قائمة أسئلة موسعة ومنظمة
  final Map<String, Map<String, dynamic>> quickActions = {
    "عن خدماتنا": {
      "response": "تطبيق Mashwarak يقدم خدمات توصيل سريعة وآمنة لجميع العملاء مع إمكانية حجز الرحلات بسهولة ومتابعة حالة الطلب مباشرة من التطبيق",
      "icon": Icons.auto_awesome,
      "color": Colors.blue
    },
    "الخط الساخن": {
      "response": "الخط الساخن لخدمة عملاء Mashwarak متاح على مدار الساعة  19000 أو 01234567890 لأي استفسار أو بلاغ عاجل",
      "icon": Icons.phone,
      "color": Colors.redAccent
    },
    "مواعيد العمل": {
      "response": "متاح طوال الأسبوع وطول اليوم  يمكنك حجز رحلاتك أو طلب التوصيل في أي وقت، والدعم الفني متاح دائمًا داخل التطبيق",
      "icon": Icons.history_toggle_off,
      "color": Colors.deepOrange
    },
    "موقعنا الجغرافي": {
      "response": "تشرفنا بزيارتك في فرعنا الرئيسي بمصر الجديدةالقاهرة",
      "icon": Icons.map,
      "color": Colors.green
    },
    "الدعم الفني": {
      "response": "إذا واجهت أي مشكلة يمكنك وصفها الآن وسيقوم خدمه العملاء بالرد عليك فوراً️",
      "icon": Icons.handyman,
      "color": Colors.blueGrey
    },
    // أسئلة جاهزة للتوكتوك كوسيلة مواصلات
    "ما هي تكلفة التوكتوك؟": {
      "response": "تكلفة التوكتوك تعتمد على المسافة والوقت لكنها عادة تكون أقل من سيارات الأجرة التقليدية",
      "icon": Icons.local_taxi,
      "color": Colors.deepOrangeAccent
    },

    "كيف أجد توكتوك بالقرب مني؟": {
      "response": "يمكنك استخدام التطبيق في اي مكان وسوف ياتي التوكتوك في اقرب وقت في المكان المحدد ",
      "icon": Icons.location_on,
      "color": Colors.green
    },
    "هل يمكنني مشاركة التوكتوك مع آخرين؟": {
      "response": "نعم بعض التوك توك توفر خدمة المشاركة لتقليل التكلفة وزيادة الفعالية",
      "icon": Icons.group,
      "color": Colors.yellow.shade700
    },
    "هل يوجد توكتوك كهربائي؟": {
      "response": "نعم بدأت بعض المناطق في استخدام التوكتوك الكهربائية الصديقة للبيئة",
      "icon": Icons.electric_scooter,
      "color": Colors.indigo.shade900
    },
  };

  void handleResponse(String text, {bool isManual = false, String? autoReply}) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "type": "user",
        "text": text,
        "time": TimeOfDay.now().format(context)
      });
      showWelcomeText = false; // إخفاء النص الترحيبي
    });
    _controller.clear();
    _scrollToBottom();
    setState(() {
      isTyping = true;
    });

    Future.delayed(const Duration(seconds: 4), () {
      String response = isManual
          ? "شكراً لرسالتك! لقد استلمنا استفسارك وسيتم الرد عليك في أقرب وقت ممكن من قبل فريقنا"
          : (autoReply ?? "سيتم الرد عليك قريباً.");

      SystemSound.play(SystemSoundType.click);
      setState(() {
        isTyping = false;
        messages.add({
          "type": "bot",
          "text": response,
          "time": TimeOfDay.now().format(context)
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text("خدمه العملاء",style: TextStyle(fontSize:32,fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // خلفية رمادي فاتح ثابت
          Container(
            color: Colors.grey[200],
          ),
          // خلفية الـ Pattern
          Opacity(
            opacity: 0.03,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/carbon-fibre.png',
              repeat: ImageRepeat.repeat,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Column(
            children: [
              if (showWelcomeText)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // زيادة الـ padding
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // تكبير المساحة الداخلية
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              " Mashwarak تطبيق ",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Flexible(
                          child: Text(
                            "يقدم خدمات توصيل آمنة وسريعة ويتيح لك حجز رحلات بسهولة",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                              color: Colors.black,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(messages[index]);
                  },
                ),
              ),
            ],
          ),
          // قائمة الأسئلة (تختفي عند البدء لترك مساحة للشات)
          Positioned(
            bottom: 140, // مسافة أعلى من حقل الإدخال
            left: 0,
            right: 0,
            child: messages.length < 4
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildScrollableQuickMenu(),
                      const SizedBox(height: 30),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          _buildBottomInputArea(),
        ],
      ),
    );
  }

  Widget _buildScrollableQuickMenu() {
    // Use PageView for horizontal looping animation
    final int itemCount = quickActions.length;
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _quickMenuPageController,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        reverse: true,
        itemBuilder: (context, index) {
          final entry = quickActions.entries.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _tappedQuickActionIndex = index;
                });
                _icon3dController.forward();
              },
              onTapUp: (_) {
                _icon3dController.reverse().then((_) {
                  setState(() {
                    _tappedQuickActionIndex = -1;
                  });
                  handleResponse(entry.key, isManual: false, autoReply: entry.value["response"]);
                });
              },
              onTapCancel: () {
                _icon3dController.reverse();
                setState(() {
                  _tappedQuickActionIndex = -1;
                });
              },
              child: AnimatedBuilder(
                animation: _icon3dAnimation,
                builder: (context, child) {
                  final bool isTapped = _tappedQuickActionIndex == index;
                  final double angle = isTapped ? _icon3dAnimation.value : 0.0;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(angle),
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: entry.value["color"].withOpacity(0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      )
                    ],
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: entry.value["color"].withOpacity(0.12),
                        child: Icon(entry.value["icon"], color: entry.value["color"], size: 42),
                      ),
                      const SizedBox(height: 15),
                      Flexible(
                        child: Text(
                          entry.key,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message["type"] == "user";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // أيقونة البوت
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),

          if (!isUser) const SizedBox(width: 8),

          // الرسالة
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF000000) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight:
                    isUser ? Radius.zero : const Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message["text"]!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message["time"] ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: isUser ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          if (isUser) const SizedBox(width: 8),

          // أيقونة المستخدم
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white, size: 19),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _pulse = !_pulse;
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                AnimatedOpacity(
                  opacity: _pulse ? 1 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: const Text("•", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 4),
                AnimatedOpacity(
                  opacity: !_pulse ? 1 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: const Text("•", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 4),
                AnimatedOpacity(
                  opacity: _pulse ? 1 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: const Text("•", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: "... اسألنا أي شيء",
                  hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: GestureDetector(
                    onTap: () {
                      print("Camera icon tapped");
                    },
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 33),
                  ),
                ),
                onFieldSubmitted: (_) {
                  SystemSound.play(SystemSoundType.click);
                  handleResponse(_controller.text, isManual: true);
                },
              ),
            ),
            const SizedBox(width: 24),
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 30),
                onPressed: () {
                  SystemSound.play(SystemSoundType.click);
                  handleResponse(_controller.text, isManual: true);
                },
                splashRadius: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}