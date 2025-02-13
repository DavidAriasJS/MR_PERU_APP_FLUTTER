// ignore_for_file: prefer_is_empty

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/activities/presentation/widgets/item_activity.dart';
import 'package:crm_app/features/dashboard/presentation/providers/home_notificaciones_provider.dart';
import 'package:crm_app/features/dashboard/presentation/screens/notification_screen.dart';
import 'package:crm_app/features/dashboard/presentation/widgets/widgets.dart';
import 'package:crm_app/features/location/presentation/providers/gps_provider.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/item_opportunity.dart';
import 'package:crm_app/features/shared/presentation/providers/notifications_provider.dart';
import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';

import '../../../activities/domain/domain.dart';
import '../../../activities/presentation/providers/activities_provider.dart';
import '../../../agenda/domain/domain.dart';
import '../../../agenda/presentation/providers/events_provider.dart';
import '../../../agenda/presentation/widgets/item_event_small.dart';
import '../../../kpis/domain/domain.dart';
import '../../../kpis/presentation/providers/kpis_provider.dart';
import '../../../opportunities/domain/domain.dart';
import '../../../opportunities/presentation/providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:floating_action_bubble_custom/floating_action_bubble_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _animationController,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(listNotifyProvider.notifier).readCounterNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        toolbarHeight: 70,
        // backgroundColor: Colors.red,
        actions: [
          Center(
            child: InkWell(
              onTap: () async {
                final count = ref.read(listNotifyProvider);
                FlutterAppBadge.count(
                  int.parse(
                    count.counterNotification,
                  ),
                );
                ref.read(listNotifyProvider.notifier).listAllNotification();
                context.push(
                  NofiticationScreen.name,
                );
                // await FlutterDynamicIcon.setApplicationIconBadgeNumber(int.parse(count.counterNotification));
              },
              child: NotificationBell(
                notificationCount: int.parse(
                  ref.watch(listNotifyProvider).counterNotification,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 30,
          )
        ],
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: const _DashboardView(),
      ),
      floatingActionButton: FloatingActionBubble(
        animation: _animation,
        onPressed: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.white,
        iconData: Icons.add,
        shape: const CircleBorder(),
        backgroundColor: primaryColor,
        items: <Widget>[
          /*BubbleMenu(
            title: 'Nueva tarea',
            iconColor: Colors.white,
            bubbleColor: const Color.fromRGBO(33, 150, 243, 1),
            icon: Icons.task,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              context.push('/task');
              _animationController.reverse();
            },
          ),*/
          BubbleMenu(
            title: 'Nueva Empresa',
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.account_balance_rounded,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              ref.read(uiProvider.notifier).deleteCompanyActivity();
              context.push('/company/new');
              //context.go('/company/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nuevo Contacto',
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.perm_contact_cal,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              ref.read(uiProvider.notifier).deleteCompanyActivity();
              context.push('/contact/new');
              //context.go('/contact/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Oportunidad',
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.work,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              ref.read(uiProvider.notifier).deleteCompanyActivity();
              context.push('/opportunity/new');
              //context.go('/opportunity/no-id');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Actividad',
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.local_activity_outlined,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              ref.read(uiProvider.notifier).deleteCompanyActivity();
              //context.go('/activity/no-id');
              context.push('/activity/new');
              _animationController.reverse();
            },
          ),
          BubbleMenu(
            title: 'Nueva Evento',
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.event,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            onPressed: () {
              //context.go('/event/new');
              ref.read(uiProvider.notifier).deleteCompanyActivity();
              context.push('/event/new');
              _animationController.reverse();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Put here the operations you want to execute when refreshing
    await Future.wait([
      ref.read(kpisProvider.notifier).loadNextPage(),
      ref.read(eventsProvider.notifier).loadNextPage(),
      ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: true),
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true),
      ref.read(opportunitiesProvider.notifier).loadStatusOpportunity(),
    ]);
  }
}

class _DashboardView extends ConsumerStatefulWidget {
  const _DashboardView();

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(kpisProvider.notifier).loadNextPage();
      ref.read(eventsProvider.notifier).loadNextPage();
      ref.read(activitiesProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(opportunitiesProvider.notifier).loadNextPage(isRefresh: true);
      ref.read(opportunitiesProvider.notifier).loadStatusOpportunity();
      ref.read(notificationsProvider.notifier).requestPermission();
    });

    final isGpsPermissionGranted =
        ref.read(gpsProvider.notifier).state.isGpsPermissionGranted;

    if (!isGpsPermissionGranted) {
      ref.read(gpsProvider.notifier).askGpsAccess();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kpisState = ref.watch(kpisProvider);

    final activitiesState = ref.watch(activitiesProvider);
    final opportunitiesState = ref.watch(opportunitiesProvider);
    final eventsState = ref.watch(eventsProvider);

    DateTime date = DateTime.now();
    String dateCurrent = DateFormat.yMMMMEEEEd('es').format(date);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Text(
              dateCurrent,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(
              height: 4,
            ),
            kpisState.isLoading
                ? const PlaceholderSection()
                : _ContainerDashboardKpis(kpis: kpisState.kpis),
            opportunitiesState.isLoading
                ? const PlaceholderSection()
                : _ContainerDashboardOpportunities(
                    opportunities: opportunitiesState.opportunities),
            activitiesState.isLoading
                ? const PlaceholderSection()
                : _ContainerDashboardActivities(
                    activities: activitiesState.activities),
            eventsState.isLoading
                ? const PlaceholderSection()
                : _ContainerDashboardEvents(
                    linkedEventsList: eventsState.linkedEventsList),

            /*_ContainerDashboardOpportunities(
                statusOpportunities: opportunitiesState.statusOpportunity),*/

            const SizedBox(
              height: 68,
            )
          ],
        ),
      ),
    );
  }
}

/*
class _ContainerDashboardOpportunitiesStatus extends StatelessWidget {
  List<StatusOpportunity> statusOpportunities;

  _ContainerDashboardOpportunitiesStatus(
      {super.key, required this.statusOpportunities});

  @override
  Widget build(BuildContext context) {
    double h1 = statusOpportunities.length * 80;
    double h2 = statusOpportunities.length * 70;

    if (statusOpportunities.length == 0) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      height: h1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Text(
                  'Oportunidades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: h2,
            child: ListView.builder(
              itemCount: statusOpportunities.length,
              itemBuilder: (context, index) {
                final status = statusOpportunities[index];

                Color color;

                if (status.recdNombre == '1. Contactado') {
                  color = Colors.red;
                } else if (status.recdNombre == '2. Primera visista') {
                  color = Colors.green;
                } else if (status.recdNombre == '3. Oferta enviada') {
                  color = Colors.blue;
                } else if (status.recdNombre == '4. Esperando pedido') {
                  color = Colors.yellow;
                } else if (status.recdNombre == '5. Vendido') {
                  color = Colors.cyanAccent;
                } else if (status.recdNombre == '6. Perdido') {
                  color = Colors.indigoAccent;
                } else {
                  color = Colors.brown;
                }

                return _ItemOpportunity(
                    title: status.recdNombre ?? '',
                    colorCustom: color,
                    porcentaje: status.totalPorcentaje ?? '');
              },
            ),
          )
        ],
      ),
    );
  }
}
*/

class _ContainerDashboardKpis extends StatelessWidget {
  List<Kpi> kpis;

  _ContainerDashboardKpis({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return kpis.isNotEmpty
        ? Center(
            child: Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //for (var kpi in kpisState.kpis)
                        for (var i = 0; i < 3 && i < kpis.length; i++)
                          progressKpi(
                              percentage: (kpis[i].porcentaje ?? 0).toDouble(),
                              title: kpis[i].objrNombre ?? '',
                              category: kpis[i].objrNombreCategoria ?? '',
                              subTitle: kpis[i].objrNombrePeriodicidad ?? '',
                              subSubTitle: kpis[i].objrNombreAsignacion ?? '',
                              advance: kpis[i].totalRegistro.toString(),
                              total: convertTypeCategory(kpis[i]) ?? '0'),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12, // Color de fondo del botón
                        borderRadius: BorderRadius.circular(
                            4), // Bordes redondeados del botón
                      ),
                      child: TextButton(
                        onPressed: () {
                          context.go('/kpis');
                          // Aquí puedes implementar la lógica para "Mostrar Todo"
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Mostrar Todo',
                              style: TextStyle(
                                color: Colors.blue, // Color del texto del botón
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor, // Color del círculo
                              ),
                              padding: const EdgeInsets.all(
                                  8), // Espacio interior alrededor del número
                              child: Text(
                                (kpis.length).toString(),
                                style: const TextStyle(
                                  color: Colors.white, // Color del número
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          )
        : Container();
  }

  convertTypeCategory(Kpi kpi) {
    String res = kpi.objrCantidad ?? '';
    if (kpi.objrIdCategoria == '05') {
      res = ' ${res}K';
    } else {
      res = (double.parse(res).toInt()).toString();
    }
    return res;
  }
}

class _ContainerDashboardActivities extends StatelessWidget {
  List<Activity> activities;

  _ContainerDashboardActivities({required this.activities});

  @override
  Widget build(BuildContext context) {
    double h1 = activities.length >= 2 ? 300 : 180;
    double h2 = activities.length >= 2 ? 220 : 100;

    if (activities.isEmpty) {
      return const SizedBox();
    }

    if (activities.length >= 0) {
      return Container(
        width: double.infinity,
        //margin: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
        height: h1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    'Actividades',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/activities');
                      // Acción cuando se presiona el botón
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: h2,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 2),
                  itemCount: activities.length > 5 ? 5 : activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];

                    return ItemActivity(
                      activity: activity,
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class _ContainerDashboardOpportunities extends StatelessWidget {
  List<Opportunity> opportunities;

  _ContainerDashboardOpportunities({required this.opportunities});

  @override
  Widget build(BuildContext context) {
    double h1 = opportunities.length >= 2 ? 270 : 160;
    double h2 = opportunities.length >= 2 ? 200 : 80;

    /*if (opportunities.length == 0) {
      return const SizedBox();
    }*/

    if (opportunities.length > 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
        height: h1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    'Oportunidades',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/opportunities');
                      // Acción cuando se presiona el botón
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: h2,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 2),
                  itemCount:
                      opportunities.length > 5 ? 5 : opportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = opportunities[index];

                    return ItemOpportunity(
                      opportunity: opportunity,
                      callbackOnTap: () {},
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class _ContainerDashboardEvents extends StatelessWidget {
  List<Event> linkedEventsList;

  _ContainerDashboardEvents({required this.linkedEventsList});

  @override
  Widget build(BuildContext context) {
    if (linkedEventsList.isEmpty) {
      return const SizedBox();
    }

    double h1 = linkedEventsList.length >= 2 ? 300 : 180;
    double h2 = linkedEventsList.length >= 2 ? 220 : 100;

    if (linkedEventsList.length >= 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
        height: h1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    'Eventos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/agenda');
                      // Acción cuando se presiona el botón
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: h2,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 2),
                  itemCount:
                      linkedEventsList.length > 5 ? 5 : linkedEventsList.length,
                  itemBuilder: (context, index) {
                    final event = linkedEventsList[index];

                    return ItemEventSmall(
                      event: event,
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class _ItemOpportunity extends StatelessWidget {
  String title;
  Color colorCustom;
  String porcentaje;

  _ItemOpportunity(
      {required this.title,
      required this.colorCustom,
      required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorCustom.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      value: ((int.parse(porcentaje)) / 100).toDouble(),
                      valueColor: AlwaysStoppedAnimation<Color>(colorCustom),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$porcentaje %',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
              child: Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(
                height: 6,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'NO. OPPT',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Text(
                        '10',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('TOTAL',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text(
                        '101 \$',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('PONDERADO',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text(
                        '0 \$',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )),
        ],
      ),
    );
  }
}

class progressKpi extends StatelessWidget {
  double percentage;
  String title;
  String category;
  String subTitle;
  String subSubTitle;
  String advance;
  String total;

  progressKpi({
    super.key,
    required this.percentage,
    required this.title,
    required this.category,
    required this.subTitle,
    required this.subSubTitle,
    required this.advance,
    required this.total,
  });

  Color isColorIndicator(double porc) {
    Color returnColors = Colors.blue;

    if (porc >= 0 && porc <= 33) {
      returnColors = Colors.red;
    }

    if (porc >= 34 && porc <= 66) {
      returnColors = Colors.yellow;
    }

    if (porc >= 67 && porc <= 100) {
      returnColors = Colors.green;
    }

    print('PORCENTAJE: ${porc}');
    return returnColors;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black45,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 10,
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 86,
                height: 86,
                child: CircularProgressIndicator(
                  strokeWidth: 7,
                  value: ((percentage) / 100).toDouble(),
                  valueColor: AlwaysStoppedAnimation<Color>(isColorIndicator(
                      percentage)), // Color cuando está marcado
                  backgroundColor: Colors.grey,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    advance,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.black38,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            subTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            subSubTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
