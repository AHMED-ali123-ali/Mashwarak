import 'dart:ui';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];
  bool showWelcomeText = true;

  // قائمة أسئلة موسعة ومنظمة
  final Map<String, Map<String, dynamic>> quickActions = {
    "عن خدماتنا": {
      "response": "تطبيق Mashwarak يقدم خدمات توصيل سريعة وآمنة لجميع العملاء مع إمكانية حجز الرحلات بسهولة ومتابعة حالة الطلب مباشرة من التطبيق",
      "icon": Icons.auto_awesome,
      "color": Colors.blueAccent
    },
    "مواعيد العمل": {
      "response": "متاح طوال الأسبوع وطول اليوم  يمكنك حجز رحلاتك أو طلب التوصيل في أي وقت، والدعم الفني متاح دائمًا داخل التطبيق",
      "icon": Icons.history_toggle_off,
      "color": Colors.deepOrange
    },
    "موقعنا الجغرافي": {
      "response": "تشرفنا بزيارتك في فرعنا الرئيسي بمصر الجديدةالقاهرة",
      "icon": Icons.map,
      "color": Colors.redAccent
    },
    "الدعم الفني": {
      "response": "إذا واجهت أي مشكلة يمكنك وصفها الآن وسيقوم خدمه العملاء بالرد عليك فوراً.️",
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
      "color": Colors.orange
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
      messages.add({"type": "user", "text": text});
      showWelcomeText = false; // إخفاء النص الترحيبي
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      String response = isManual
          ? "شكراً لرسالتك! لقد استلمنا استفسارك وسيتم الرد عليك في أقرب وقت ممكن من قبل فريقنا"
          : (autoReply ?? "سيتم الرد عليك قريباً.");

      setState(() {
        messages.add({"type": "bot", "text": response});
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
                ),
              ),
            ],
          ),
          // قائمة الأسئلة (تختفي عند البدء لترك مساحة للشات)
          Positioned(
            bottom: 140, // مسافة أعلى من حقل الإدخال
            left: 0,
            right: 0,
            child: messages.length < 4 ? _buildScrollableQuickMenu() : const SizedBox.shrink(),
          ),
          _buildBottomInputArea(),
        ],
      ),
    );
  }

  Widget _buildScrollableQuickMenu() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final entry = quickActions.entries.elementAt(index);
          return GestureDetector(
            onTap: () => handleResponse(entry.key, isManual: false, autoReply: entry.value["response"]),
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
                    radius: 45, // حجم الأيقونة
                    backgroundColor: entry.value["color"].withOpacity(0.12),
                    child: Icon(entry.value["icon"], color: entry.value["color"], size: 42),
                  ),
                  const SizedBox(height: 12), // مسافة بين الأيقونة والنص
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
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message["type"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF000000) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(22),
          ),

        ),
        child: Text(
          message["text"]!,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.grey.shade900,
            fontSize: 22,
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: "... اسألنا أي شيء",
                  hintStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onSubmitted: (_) => handleResponse(_controller.text, isManual: true),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 30),
                onPressed: () => handleResponse(_controller.text, isManual: true),
                splashRadius: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}