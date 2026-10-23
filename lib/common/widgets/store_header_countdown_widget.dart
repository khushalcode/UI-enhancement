import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class StoreHeaderCountdownWidget extends StatefulWidget {
  final Store store;
  const StoreHeaderCountdownWidget({super.key, required this.store});

  @override
  State<StoreHeaderCountdownWidget> createState() => _StoreHeaderCountdownWidgetState();
}

class _StoreHeaderCountdownWidgetState extends State<StoreHeaderCountdownWidget> {
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

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_filled, color: Theme.of(context).colorScheme.error, size: 14),
            const SizedBox(width: 4),
            Text(
              'Closing Soon! ',
              style: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
            ),
            Text(
              '$hours:$minutes:$seconds',
              style: robotoBold.copyWith(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
