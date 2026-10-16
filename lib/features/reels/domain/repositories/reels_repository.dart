import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/reels/domain/models/reel_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ReelsRepository {
  final ApiClient apiClient;

  ReelsRepository({required this.apiClient});

  Future<Response> getReelsList(int offset) async {
    return await apiClient.getData('/api/v1/product-reels?offset=$offset&limit=10');
  }
}
