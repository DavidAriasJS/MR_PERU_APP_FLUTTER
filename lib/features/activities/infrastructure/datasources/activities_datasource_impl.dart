import 'package:crm_app/features/activities/infrastructure/mappers/activity_response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/activities/domain/domain.dart';

import '../errors/activity_errors.dart';
import '../mappers/activity_mapper.dart';

class ActivitiesDatasourceImpl extends ActivitiesDatasource {
  late final Dio dio;
  final String accessToken;

  ActivitiesDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accessToken'}));

  @override
  Future<ActivityResponse> createUpdateActivity(
      Map<dynamic, dynamic> activityLike) async {
    try {
      final String? id = activityLike['ACTI_ID_ACTIVIDAD'];
      final String method = 'POST';
      final String url = '/actividad/create-actividad';

      final response = await dio.request(url,
          data: activityLike, options: Options(method: method));

      print('RESP:${response}');

      final ActivityResponse activityResponse =
          ActivityResponseMapper.jsonToEntity(response.data);

      if (activityResponse.status == true) {
        activityResponse.activity =
            ActivityMapper.jsonToEntity(response.data['data']);
      }

      return activityResponse;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ActivityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Activity> getActivityById(String id) async {
    try {
      final response = await dio.get('/actividad/listar-actividad-by-id/$id');
      final Activity activity =
          ActivityMapper.jsonToEntity(response.data['data']);

      return activity;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ActivityNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Activity>> getActivities() async {
    print('CARGO ACTIVIDADES');
    final response =
        await dio.post('/actividad/listar-actividad-by-id-tipo-gestion');
    final List<Activity> activities = [];
    for (final activity in response.data['data'] ?? []) {
      activities.add(ActivityMapper.jsonToEntity(activity));
    }

    return activities;
  }
}
