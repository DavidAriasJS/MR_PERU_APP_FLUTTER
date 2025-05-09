import 'dart:async';
import 'dart:developer';

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/location/presentation/providers/providers.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/domain/entities/coordenada.dart';
import 'package:crm_app/features/route-planner/presentation/providers/forms/event_planner_form_provider.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/route-planner/presentation/widgets/filter_route_planner_bottom_sheet.dart';
import 'package:crm_app/features/route-planner/presentation/widgets/item_route_planner_local.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../shared/widgets/loading_modal.dart';
import '../../../shared/widgets/no_exist_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

import '../widgets/tags_filter.dart';

class RoutePlannerScreen extends ConsumerWidget {
  const RoutePlannerScreen({super.key});

  bool existeHorarioTrabajo(List<FilterOption> options) {
    if (options.isNotEmpty) {
      return options.any((option) => option.type == "HRTR_ID_HORARIO_TRABAJO");
    } else {
      return false;
    }
  }

  FilterOption searchHorarioTrabajo(List<FilterOption> options) {
    var resultado = options.firstWhere(
      (item) => item.type == "HRTR_ID_HORARIO_TRABAJO",
    );
    return resultado;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final List<FilterOption> listFiltersSuccess =
        ref.watch(routePlannerProvider).filtersSuccess;
    final List<CompanyLocalRoutePlanner> listSelectedItems =
        ref.watch(routePlannerProvider).selectedItems;

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Planificador de rutas',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => FilterBottomRouterPlannerSheet(),
              );
            },
            icon: Icon(
              Icons.filter_alt,
              color:
                  listFiltersSuccess.isNotEmpty ? primaryColor : Colors.black,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const _SearchComponent(),
          listFiltersSuccess.isNotEmpty
              ? TagRowRoutePlanner()
              : const SizedBox(),
          const Expanded(child: _RoutePlannerView()),
        ],
      ),
      floatingActionButton: listSelectedItems.isNotEmpty
          ? Stack(
              alignment:
                  Alignment.center, // Alineación central del FAB ey el contador
              children: [
                SizedBox(
                  width: 46 + 9.0 * 2,
                  height: 46 + 9.0 * 2,
                  child: FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: () async {
                      var filterSuccess =
                          ref.read(routePlannerProvider).filtersSuccess;
                      var filter = ref.read(routePlannerProvider).filters;
                      bool existFilter = existeHorarioTrabajo(filterSuccess);
                      if (!existFilter) {
                        mostrarModalMensaje(context, 'AVISO',
                            'Debes seleccionar el filtro de Horario de trabajo.',
                            () {
                          Navigator.of(context).pop();
                        });
                        return;
                      } else {
                        var horario = searchHorarioTrabajo(filterSuccess);
                        var idHorario = horario.id;
                        log("dasdas${filter.map((e) => e.name)}");
                        var idResponsable = "";
                        var idResponsableName = "";
                        if (filter.isNotEmpty) {
                          idResponsable = filter
                                  .where((v) =>
                                      (v.type == "ID_USUARIO_RESPONSABLE"))
                                  .firstOrNull
                                  ?.id ??
                              '';
                          idResponsableName = filter
                                  .where((v) =>
                                      (v.type == "ID_USUARIO_RESPONSABLE"))
                                  .firstOrNull
                                  ?.name ??
                              '';
                        }
                        showLoadingMessage(context);

                        var validatePlanner = await ref
                            .read(routePlannerProvider.notifier)
                            .validatePlanner(idHorario, idResponsable);

                        if (validatePlanner.status == false) {
                          Navigator.pop(context);

                          mostrarModalMensaje(
                              context, 'AVISO', validatePlanner.message, () {
                            Navigator.of(context).pop();
                          });
                          //Navigator.pop(context);
                          return;
                        } else {
                          Navigator.pop(context);

                          ref
                              .read(routePlannerProvider.notifier)
                              .updateFechasRegister(
                                validatePlanner.data?.fechaIni ?? '',
                                validatePlanner.data?.fechaFin ?? '',
                              );

                          /*final gpsState = ref.read(gpsProvider.notifier).state;

                    if (!gpsState.isAllGranted) {
                      if (!gpsState.isGpsEnabled) {
                        showSnackbar(context, 'Debe de habilitar el GPS');
                      } else {
                        showSnackbar(context, 'Es necesario el acceso a GPS');
                        ref.read(gpsProvider.notifier).askGpsAccess();
                      }
                      //Navigator.pop(context);

                      return;
                    }*/

                          showLoadingMessage(context);

                          Coordenada coorsLocal = await ref
                              .read(routePlannerProvider.notifier)
                              .cargarCoordena();

                          //LatLng location = await ref.watch(locationProvider.notifier).currentPosition();

                          LatLng location = LatLng(
                              double.parse(coorsLocal.latitud),
                              double.parse(coorsLocal.longitud));

                          List<CompanyLocalRoutePlanner> orderSelectedItems =
                              await ref
                                  .read(mapProvider.notifier)
                                  .sortLocalesByDistance(
                                      location, listSelectedItems);

                          await ref
                              .read(routePlannerProvider.notifier)
                              .setSelectedItemsOrder(orderSelectedItems);
                          await ref
                              .read(routePlannerProvider.notifier)
                              .initialOrderkey();

                          ref
                              .watch(eventPlannerFormProvider.notifier)
                              .setInitialForm();
                          await ref
                              .read(eventPlannerFormProvider.notifier)
                              .setLocalesArray(orderSelectedItems);

                          ref.read(mapProvider.notifier).setLocation(location);

                          //final mapState = ref.watch(mapProvider.notifier);

                          ref.watch(mapProvider.notifier).addMarkersAndLocation(
                              listSelectedItems, location);

                          /// [set id responsable]
                          ref
                              .read(eventPlannerFormProvider.notifier)
                              .onUpdateUserPlannerSelector(idResponsable);
                          ref
                              .read(eventPlannerFormProvider.notifier)
                              .onUpdatePlrtNameUserResponsable(
                                  idResponsableName);
                          Navigator.pop(context);

                          context.push('/register_route_planner');
                        }
                      }
                    },
                    shape: const CircleBorder(),
                    child: const Icon(Icons.map, size: 32, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(
                      minWidth: 25,
                      minHeight: 25,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${listSelectedItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

class _RoutePlannerView extends ConsumerStatefulWidget {
  const _RoutePlannerView();

  @override
  _RoutePlannerViewState createState() => _RoutePlannerViewState();
}

class _RoutePlannerViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        print('CARGANDO MAS');
        ref.read(routePlannerProvider.notifier).loadNextPage(isRefresh: false);
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      //await ref.read(routePlannerProvider.notifier).onDeleteAllFilter();
      //await ref.read(routePlannerProvider.notifier).loadFilterHorario();
      //await ref.read(routePlannerProvider.notifier).onChangeNotIsActiveSearchSinRefresh();
      //await ref.read(routePlannerProvider.notifier).loadNextPage(isRefresh: true);

      ref.read(routePlannerProvider.notifier).initialPlannerLoad();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.read(routePlannerProvider.notifier).loadNextPage(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final routePlannerState = ref.watch(routePlannerProvider);
    final isReload = routePlannerState.isReload;

    if (routePlannerState.isLoading) {
      return const LoadingModal();
    }

    return routePlannerState.locales.isNotEmpty
        ? _ListLocales(
            locales: routePlannerState.locales,
            onRefreshCallback: _refresh,
            isReload: isReload,
            scrollController: scrollController,
          )
        : NoExistData(
            textCenter: 'No hay locales registradas',
            onRefreshCallback: _refresh,
            icon: Icons.business);
  }
}

class _ListLocales extends ConsumerStatefulWidget {
  final List<CompanyLocalRoutePlanner> locales;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;
  final bool isReload;

  const _ListLocales(
      {required this.locales,
      required this.onRefreshCallback,
      required this.scrollController,
      required this.isReload});

  @override
  _ListLocalesState createState() => _ListLocalesState();
}

class _ListLocalesState extends ConsumerState<_ListLocales> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return widget.locales.isEmpty
        ? Center(
            child: RefreshIndicator(
                onRefresh: widget.onRefreshCallback,
                key: refreshIndicatorKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onRefreshCallback,
                        child: const Text('Recargar'),
                      ),
                      const Center(
                        child: Text('No hay registros'),
                      ),
                    ],
                  ),
                )),
          )
        : NotificationListener(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels + 400 ==
                  scrollInfo.metrics.maxScrollExtent) {
                ref
                    .read(routePlannerProvider.notifier)
                    .loadNextPage(isRefresh: false);
              }
              return false;
            },
            child: RefreshIndicator(
                notificationPredicate: defaultScrollNotificationPredicate,
                onRefresh: widget.onRefreshCallback,
                //key: _refreshIndicatorKey,
                child: ListView.separated(
                  itemCount: widget.locales.length,
                  controller: widget.scrollController,
                  //physics: const BouncingScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (context, index) {
                    final local = widget.locales[index];

                    if (index + 1 == widget.locales.length) {
                      if (widget.isReload) {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }

                    return ItemRoutePlannerLocal(
                        local: local,
                        callbackOnTap: () {
                          //context.push('/company_detail/${local.ruc}');
                        });
                  },
                )),
          );
  }
}

class _SearchComponent extends ConsumerStatefulWidget {
  const _SearchComponent();

  @override
  _SearchComponentState createState() => _SearchComponentState();
}

class _SearchComponentState extends ConsumerState<_SearchComponent> {
  TextEditingController searchController = TextEditingController(
      //text: ref.read(routePlannerProvider).textSearch
      );

  @override
  Widget build(BuildContext context) {
    Timer? debounce;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            style: const TextStyle(fontSize: 14.0),
            controller: searchController,
            onChanged: (String value) {
              if (debounce?.isActive ?? false) debounce?.cancel();
              debounce = Timer(const Duration(seconds: 1), () {
                //ref.read(companiesProvider.notifier).loadNextPage(value);
                ref
                    .read(routePlannerProvider.notifier)
                    .onChangeTextSearch(value);
              });
            },
            onFieldSubmitted: (value) {
              ref.read(routePlannerProvider.notifier).onChangeTextSearch(value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar locales...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 18.0),
              hintStyle: const TextStyle(fontSize: 14.0, color: Colors.black38),
            ),
          ),
          if (ref.watch(routePlannerProvider).textSearch != "")
            IconButton(
              onPressed: () {
                ref
                    .read(routePlannerProvider.notifier)
                    .onChangeNotIsActiveSearch();
                searchController.text = '';
              },
              icon: const Icon(Icons.clear, size: 18.0),
            ),
        ],
      ),
    );
  }
}
