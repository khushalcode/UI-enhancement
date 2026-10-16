import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class VoiceSearchWidget extends StatefulWidget {
  const VoiceSearchWidget({super.key});

  @override
  State<VoiceSearchWidget> createState() => _VoiceSearchWidgetState();
}

class _VoiceSearchWidgetState extends State<VoiceSearchWidget> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'listening'.tr;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(_controller);
    _initSpeech();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if(mounted) setState(() => _isListening = false);
            if (_text.isNotEmpty && _text != 'listening'.tr) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if(mounted && !_isListening) {
                  Get.back(result: _text);
                }
              });
            }
          }
        },
        onError: (val) => print('Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      Get.back();
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('permission_denied'.tr),
        content: Text('microphone_permission_required_for_voice_search'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
        ],
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('listening for search'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: 30),
          ScaleTransition(
            scale: _animation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            _text,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: _isListening ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text('cancel'.tr),
            )),
            if(_text.isNotEmpty && _text != 'listening'.tr) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: ElevatedButton(
                onPressed: () => Get.back(result: _text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                ),
                child: Text('search now'.tr),
              )),
            ],
          ]),
        ],
      ),
    );
  }
}
