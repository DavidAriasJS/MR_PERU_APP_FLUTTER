import 'package:crm_app/features/shared/shared.dart';

import '../../domain/entities/send_indicators_response.dart';
import '../../domain/repositories/indicators_repository.dart';
import 'indicators_repository_provider.dart';
import '../../../kpis/domain/entities/array_user.dart';
import '../../../users/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final indicatorsProvider =
    StateNotifierProvider<IndicatorsNotifier, IndicatorsState>((ref) {
  final indicatorsRepository = ref.watch(indicatorsRepositoryProvider);
  return IndicatorsNotifier(indicatorsRepository: indicatorsRepository);
});

class IndicatorsNotifier extends StateNotifier<IndicatorsState> {
  final IndicatorsRepository indicatorsRepository;

  IndicatorsNotifier({required this.indicatorsRepository})
      : super(IndicatorsState()) {
    //loadNextPage();
  }

  void onDateInitialChanged(DateTime fecha) {
    state = state.copyWith(dateInitial: fecha);
  }

  void onPeriodicidadChanged(String id, String name) {
    state = state.copyWith(idPeriodicidad: id, nombrePeriodicidad: name);
  }

  void onDateEndChanged(DateTime fecha) {
    state = state.copyWith(dateEnd: fecha);
  }

  void onUsersChanged(UserMaster usuario) {
    bool objExist = state.arrayresponsables!.any(
        (objeto) => objeto.idUsuarioResponsable == usuario.code);

    if (!objExist) {
      ArrayUser array = ArrayUser();
      array.idResponsable = usuario.code;
      array.cresIdUsuarioResponsable = usuario.code;
      array.userreportName = usuario.name;
      array.nombreResponsable = usuario.name;
      array.oresIdUsuarioResponsable = usuario.code;
      array.idUsuarioResponsable = usuario.code;

      List<ArrayUser> arrayUsuarios = [...state.arrayresponsables ?? [], array];

      state = state.copyWith(arrayresponsables: arrayUsuarios);
    } else {
      state = state;
    }
  }

  void onDeleteUserChanged(ArrayUser item) {
    List<ArrayUser> arrayUsuarios = state.arrayresponsables!
        .where(
            (user) => user.idUsuarioResponsable != item.idUsuarioResponsable)
        .toList();
    state = state.copyWith(arrayresponsables: arrayUsuarios);
  }

  void resetForm() {
    state = state.copyWith(
        dateEnd: DateTime.now(),
        dateInitial: DateTime.now(),
        arrayresponsables: []);
  }

  Future<SendIndicatorsResponse> onFormSubmit() async {
    state = state.copyWith(isLoading: true);

    final params = {
      /*"DATE_INI":
          "${state.dateInitial?.year.toString().padLeft(4, '0')}-${state.dateInitial?.month.toString().padLeft(2, '0')}-${state.dateInitial?.day.toString().padLeft(2, '0')}",
      "DATE_FIN":
          "${state.dateEnd?.year.toString().padLeft(4, '0')}-${state.dateEnd?.month.toString().padLeft(2, '0')}-${state.dateEnd?.day.toString().padLeft(2, '0')}",*/
      "ID_PERIODICIDAD": state.idPeriodicidad,
      "TIPO_ENVIO": "MANUAL", 
      "USUARIOS_RESPONSABLE": state.arrayresponsables != null
          ? List<dynamic>.from(state.arrayresponsables!.map((x) => x.toJson()))
          : [],
    };
    

    try {
      state = state.copyWith(isLoading: false);
      return await sendIndicators(params);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return SendIndicatorsResponse(response: false, message: '');
    }
  }

  Future<SendIndicatorsResponse> sendIndicators(
      Map<dynamic, dynamic> params) async {
    try {
      final indicatorsResponse =
          await indicatorsRepository.sendIndicators(params);

      final message = indicatorsResponse.message;

      if (indicatorsResponse.status) {
        return SendIndicatorsResponse(response: true, message: message);
      }

      return SendIndicatorsResponse(response: false, message: message);
    } catch (e) {
      return SendIndicatorsResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }
}

class IndicatorsState {
  final DateTime? dateInitial;
  final DateTime? dateEnd;
  final String? tipoEnvio;
  final String idPeriodicidad;
  final String? nombrePeriodicidad;
  final List<ArrayUser>? arrayresponsables;
  final bool isSend;
  final bool isLoading;

  IndicatorsState(
      {this.dateInitial,
      this.dateEnd,
      this.tipoEnvio,
      this.idPeriodicidad = '',
      this.nombrePeriodicidad = '',
      this.arrayresponsables = const [],
      this.isSend = false,
      this.isLoading = false});

  IndicatorsState copyWith({
    DateTime? dateInitial,
    DateTime? dateEnd,
    List<ArrayUser>? arrayresponsables,
    String? tipoEnvio,
    String? idPeriodicidad,
    String? nombrePeriodicidad,
    bool? isSend,
    bool? isLoading,
  }) =>
      IndicatorsState(
        dateInitial: dateInitial ?? this.dateInitial,
        dateEnd: dateEnd ?? this.dateEnd,
        tipoEnvio: tipoEnvio ?? this.tipoEnvio,
        idPeriodicidad: idPeriodicidad ?? this.idPeriodicidad,
        arrayresponsables: arrayresponsables ?? this.arrayresponsables,
        isSend: isSend ?? this.isSend,
        isLoading: isLoading ?? this.isLoading,
      );
}
