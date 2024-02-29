import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';

import 'opportunities_repository_provider.dart';

final opportunityProvider = StateNotifierProvider.autoDispose
    .family<OpportunityNotifier, OpportunityState, String>((ref, id) {
  final opportunitiesRepository = ref.watch(opportunitiesRepositoryProvider);

  return OpportunityNotifier(opportunitiesRepository: opportunitiesRepository, id: id);
});

class OpportunityNotifier extends StateNotifier<OpportunityState> {
  final OpportunitiesRepository opportunitiesRepository;

  OpportunityNotifier({
    required this.opportunitiesRepository,
    required String id,
  }) : super(OpportunityState(id: id)) {
    loadOpportunity();
  }

  Opportunity newEmptyOpportunity() {
    return Opportunity(
      id: 'new',
      oprtEntorno: 'MR PERU',
      oprtIdEstadoOportunidad: '',
      oprtNombre: '',
      oprtComentario: '',
      oprtFechaPrevistaVenta: '',
      oprtIdOportunidadIn: '',
      oprtIdUsuarioRegistro: '',
      oprtIdValor: '01',
      oprtNobbreEstadoOportunidad: '',
      oprtNombreValor: '',
      oprtProbabilidad: 0,
      oprtRuc: '',
      oprtRucIntermediario01: '',
      oprtRucIntermediario02: '',
      opt: '',
    );
  }

  Future<void> loadOpportunity() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          opportunity: newEmptyOpportunity(),
        );

        return;
      }

      final opportunity = await opportunitiesRepository.getOpportunityById(state.id);

      state = state.copyWith(isLoading: false, opportunity: opportunity);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class OpportunityState {
  final String id;
  final Opportunity? opportunity;
  final bool isLoading;
  final bool isSaving;

  OpportunityState({
    required this.id,
    this.opportunity,
    this.isLoading = true,
    this.isSaving = false,
  });

  OpportunityState copyWith({
    String? id,
    Opportunity? opportunity,
    bool? isLoading,
    bool? isSaving,
  }) =>
      OpportunityState(
        id: id ?? this.id,
        opportunity: opportunity ?? this.opportunity,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}
