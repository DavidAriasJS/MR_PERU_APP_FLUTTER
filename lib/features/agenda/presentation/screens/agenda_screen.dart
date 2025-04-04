import 'dart:developer';

import 'package:crm_app/features/agenda/presentation/providers/event_provider.dart';
import 'package:crm_app/features/companies/presentation/providers/companies_provider.dart';
import 'package:crm_app/features/companies/presentation/providers/company_provider.dart';
import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';

import '../../domain/domain.dart';
import '../providers/events_provider.dart';
import '../widgets/item_event.dart';
import '../widgets/table_calendar.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Eventos'),
        /*actions: [
          IconButton(onPressed: () {
            
          }, icon: const Icon(Icons.refresh))
        ],*/
      ),
      body: const _AgendaView(),
      floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.add,
          callOnPressed: () {
            ref.read(uiProvider.notifier).deleteCompanyActivity();

            context.push('/event/new');
          }),
    );
  }
}

class _AgendaView extends ConsumerStatefulWidget {
  const _AgendaView();

  @override
  _AgendaViewState createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState {
  //late final ValueNotifier<List<EventMock>> _selectedEvents;
  //final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  late PageController _pageController;
  //DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    //_selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(eventsProvider.notifier).loadNextPage();
      ref.read(eventsProvider.notifier).onSelectedEvents(DateTime.now());
    });
  }

  @override
  void dispose() {
    //_focusedDay.dispose();
    //_selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    //if (!isSameDay(eventState, selectedDay)) {
    /*setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });*/

    ref.read(eventsProvider.notifier).onChangeSelectedDay(selectedDay);
    ref.read(eventsProvider.notifier).onChangeFocusedDay(focusedDay);
    ref.read(eventsProvider.notifier).onSelectedEvents(selectedDay);
    //}
  }

  Future<void> _onRefresh() async {
    await ref.read(eventsProvider.notifier).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return Center(
      child: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: ValueNotifier(eventsState.focusedDay),
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedDay: value,
                onRefresh: () {
                  ref.read(eventsProvider.notifier).loadNextPage();
                },
                onTodayButtonTap: () {
                  //setState(() => _focusedDay.value = DateTime.now());
                  ref
                      .read(eventsProvider.notifier)
                      .onChangeFocusedDay(DateTime.now());
                },
                onLeftArrowTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                onRightArrowTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              );
            },
          ),
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: ValueNotifier(eventsState.focusedDay).value,
            //focusedDay: _focusedDay.value,
            locale: 'es_ES',
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            selectedDayPredicate: (day) {
              return isSameDay(eventsState.selectedDay, day);
            },
            calendarFormat: CalendarFormat.week,
            //eventLoader: _getEventsForDay,
            eventLoader: (day) {
              return eventsState
                      .linkedEvents[DateTime(day.year, day.month, day.day)] ??
                  [];
            },
            onDaySelected: _onDaySelected,
            onCalendarCreated: (controller) => _pageController = controller,
            onPageChanged: (focusedDay) {
              //_focusedDay.value = focusedDay;
              ref.read(eventsProvider.notifier).onChangeFocusedDay(focusedDay);
            },
            calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                markersMaxCount: 4,
                markerSize: 6,
                selectedDecoration: const BoxDecoration(
                  color: Colors.blueGrey, // Cambia el color a tu gusto
                  shape: BoxShape.circle,
                )),
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              //valueListenable: _selectedEvents,
              valueListenable: ValueNotifier(eventsState.selectedEvents),
              builder: (context, value, _) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: value.isNotEmpty
                      ? ListView.separated(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            final event = value[index];

                            return ItemEvent(
                                event: event,
                                callbackOnTap: () {
                                  context.push(
                                    '/event_detail/${value[index].id}',
                                  );
                                },
                                callbackChekIn: () async {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const Dialog(
                                          backgroundColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white38,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        );
                                      });
                                  ref.read(isFromEventProvider.notifier).state =
                                      true;
                                  ref.read(eventProvider(event.id));

                                  ref.read(
                                      companyProvider(event.evntRuc ?? ''));
                                  await ref
                                      .read(companyProvider(event.evntRuc ?? '')
                                          .notifier)
                                      .loadCompany();
                                  String idCheck = '01';
                                  ref.read(stateRucProvider.notifier).state =
                                      event.evntRuc ?? '';

                                  var localesOld = ref
                                      .read(
                                        companyProvider(event.evntRuc ?? ''),
                                      )
                                      .companyLocales;
                                  log(localesOld[0].id.toString());
                                  final localCodigo = ref
                                          .read(eventProvider(event.id))
                                          .event
                                          ?.evntLocalCodigo ??
                                      '';
                                  final locales = localesOld
                                      .where((v) => (v.id == localCodigo))
                                      .toList();
                                  log(ref
                                          .read(eventProvider(event.id))
                                          .event
                                          ?.evntLocalCodigo ??
                                      'KK');

                                  log(locales.toString());
                                  final totalLocales = locales.length;
                                  String idLocal = '-';
                                  String nombreLocal = '-';
                                  String latLocal = '0.0';
                                  String lngLocal = '0.0';
                                  if (totalLocales == 1) {
                                    idLocal = locales[0].id;
                                    nombreLocal =
                                        '${locales[0].localNombre} ${locales[0].localDireccion}';
                                    latLocal = locales[0].coordenadasLatitud!;
                                    lngLocal = locales[0].coordenadasLongitud!;
                                  }
                                  String ruc = event.evntRuc ?? '';
                                  String ids =
                                      '$idCheck*$ruc*$idLocal*$nombreLocal*$latLocal*$lngLocal';
                                  log(ids);
                                  await ref
                                      .read(companiesProvider.notifier)
                                      .validateCheckIn(
                                        ruc: ruc,
                                      );
                                  ref.read(idEventFromAgenda.notifier).state =
                                      event.id;
                                  context.pop();
                                  if (ref
                                      .watch(companiesProvider)
                                      .isValidateCheckIn) {
                                    log(ids);

                                    context
                                        .push('/company_check_in/$ids')
                                        .then((value) async {
                                      ref
                                          .read(isFromEventProvider.notifier)
                                          .state = false;
                                      await ref
                                          .read(eventsProvider.notifier)
                                          .loadNextPage();
                                    });
                                    return;
                                  } else {
                                    log(ref
                                        .read(companiesProvider)
                                        .validationCheckinMessage);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        elevation: 3,
                                        backgroundColor: Colors.grey,
                                        content: Text(
                                          ref
                                              .watch(companiesProvider)
                                              .validationCheckinMessage,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                });
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              height: 0,
                            );
                          },
                        )
                      : ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Sin eventos',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
    /*return DefaultTabController(
      length: 2, // Cambia este valor al número de pestañas que desees
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'POR MES'),
              Tab(text: 'POR DÍA'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMonthView(),
                _buildCalendarView(CalendarView.week),
              ],
            ),
          ),
        ],
      ),
    );*/
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onRefresh;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onRefresh,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
