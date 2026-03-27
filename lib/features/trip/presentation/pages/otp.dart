import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'trip_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String tripId;

  const OTPScreen({super.key, required this.phone, required this.tripId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isVerifying = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _resendTimer = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) return;

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (otp == "1234") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TripScreen(tripId: widget.tripId)),
            (route) => false,
      );
    } else {
      setState(() => _isVerifying = false);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            content: const Text(
              "الكود غير صحيح",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Maswarak',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 34),),
        centerTitle:true,
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 3,
            shadowColor: Colors.black26,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 23),
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "التحقق من الكود",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          text: "أدخل الرمز المرسل إلى رقم الهاتف\n",
                          style: TextStyle(fontSize: 30, color: Colors.black54, height: 1.5),
                          children: [
                            TextSpan(
                              text: widget.phone,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) => _buildOtpBox(index)),
                      ),

                      const SizedBox(height: 32),

                      _resendTimer > 0
                          ? Text(
                              "إعادة إرسال الكود خلال $_resendTimer ثانية",
                              style: TextStyle(color: Colors.black, fontSize: 22,fontWeight: FontWeight.bold),
                            )
                          : TextButton(
                              onPressed: _startTimer,
                              child: const Text(
                                "إعادة إرسال الكود",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 23),
                              ),
                            ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("تأكيد", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
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
  Widget _buildOtpBox(int index) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color:Colors.grey[350], // رمادي فاتح جداً هادئ
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? Colors.black : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
          onChanged: (value) {
            setState(() {}); // لتحديث لون الإطار فوراً عند التركيز أو الكتابة
            if (value.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            if (_controllers.every((c) => c.text.isNotEmpty)) _verifyOTP();
          },
        ),
      ),
    );
  }
}