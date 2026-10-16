import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ClosingSoonWidget extends StatefulWidget {
  final Store store;
  final bool isAllSideRound;
  final double radius;
  final double? fontSize;
  const ClosingSoonWidget({super.key, required this.store, this.isAllSideRound = true, this.radius = Dimensions.radiusSmall, this.fontSize});

  @override
  State<ClosingSoonWidget> createState() => _ClosingSoonWidgetState();
}

class _ClosingSoonWidgetState extends State<ClosingSoonWidget> {
  Timer? _timer;
  Duration? _timeLeft;
  bool _isClosingSoon = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    if (_isClosingSoon) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          _calculateTimeLeft();
          if (!_isClosingSoon) {
             timer.cancel();
          }
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    if (widget.store.active == false || widget.store.schedules == null) {
      _isClosingSoon = false;
      return;
    }
    int weekday = DateTime.now().weekday;
    if (weekday == 7) weekday = 0;
    
    DateTime currentTime = DateTime.now();
    
    for (var schedule in widget.store.schedules!) {
      if (schedule.day == weekday && DateConverter.isAvailable(schedule.openingTime, schedule.closingTime)) {
        try {
          DateTime end0 = DateFormat('HH:mm').parse(schedule.closingTime!);
          DateTime endTime = DateTime(currentTime.year, currentTime.month, currentTime.day, end0.hour, end0.minute, end0.second);
          
          DateTime start0 = DateFormat('HH:mm').parse(schedule.openingTime!);
          DateTime startTime = DateTime(currentTime.year, currentTime.month, currentTime.day, start0.hour, start0.minute, start0.second);
          
          if(endTime.isBefore(startTime)) {
            if(currentTime.isBefore(startTime) && currentTime.isBefore(endTime)){
              // Do nothing
            }else {
              endTime = endTime.add(const Duration(days: 1));
            }
          }
          
          Duration diff = endTime.difference(currentTime);
          if (diff.inHours < 2 && diff.inSeconds > 0) {
            _isClosingSoon = true;
            _timeLeft = diff;
            return;
          }
        } catch (_) {}
      }
    }
    _isClosingSoon = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isClosingSoon || _timeLeft == null) {
      return const SizedBox();
    }
    
    String hours = _timeLeft!.inHours.toString().padLeft(2, '0');
    String minutes = (_timeLeft!.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft!.inSeconds % 60).toString().padLeft(2, '0');

    double fSize = widget.fontSize ?? Dimensions.fontSizeSmall;
    double tSize = widget.fontSize != null ? widget.fontSize! + 2 : Dimensions.fontSizeLarge;

    return Positioned(
      top: 5, right: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).colorScheme.error, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_filled, color: Colors.white, size: 10),
            const SizedBox(width: 4),
            Text(
              'Closing Soon! ',
              style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
            ),
            Text(
              '$hours:$minutes:$seconds',
              style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
