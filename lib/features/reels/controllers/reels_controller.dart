import 'package:get/get.dart';
import 'package:sixam_mart/features/reels/domain/models/reel_model.dart';
import 'package:sixam_mart/features/reels/domain/repositories/reels_repository.dart';
import 'package:sixam_mart/api/api_checker.dart';

class ReelsController extends GetxController implements GetxService {
  final ReelsRepository reelsRepository;
  ReelsController({required this.reelsRepository});

  List<ReelModel>? _reelsList;
  List<ReelModel>? get reelsList => _reelsList;

  int _offset = 1;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getReelsList(int offset, bool reload) async {
    if (reload) {
      _offset = 1;
      _reelsList = null;
      update();
    }
    
    _isLoading = true;
    update();
    
    Response response = await reelsRepository.getReelsList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _reelsList = [];
      }
      response.body['reels'].forEach((reel) {
        _reelsList!.add(ReelModel.fromJson(reel));
      });
      _offset++;
    } else {
      ApiChecker.checkApi(response);
    }
    
    _isLoading = false;
    update();
  }
}
