import 'dart:async';

import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/route-planner/domain/entities/create_event_planner_response.dart';
import 'package:crm_app/features/route-planner/presentation/providers/forms/event_planner_form_provider.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:crm_app/features/route-planner/presentation/widgets/route_card.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/domain/entities/dropdown_option.dart';

import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RegisterRoutePlannerScreen extends ConsumerWidget {

  const RegisterRoutePlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title:
                const Text('Planificador de rutas',
                style: TextStyle(
                  fontWeight: FontWeight.w600
                ),),
            /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
          ),
          body: const _EventView(),
          floatingActionButton: FloatingActionButtonCustom(
            callOnPressed:() {

              showLoadingMessage(context);

              ref
                  .read(eventPlannerFormProvider.notifier)
                  .onFormSubmit()
                  .then((CreateEventPlannerResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);

                  if (value.response) {
                    //Timer(const Duration(seconds: 3), () {
                    //TODO: LIMPIAR LOS SELECT ITEMS Y TODO EL FORMULARIO
                    ref.read(routePlannerProvider.notifier).clearSelectedLocales();
                    
                    context.replace('/route_planner');
                    //});
                  }
                }

                Navigator.pop(context);

              });

            }, 
            iconData: Icons.check),
      )
    );
  }
}

class _EventView extends ConsumerWidget {

  const _EventView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: const [
        SizedBox(height: 10),
        _EventInformation(),
      ],
    );
  }
}

class _EventInformation extends ConsumerWidget {
  const _EventInformation();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownOption> optionsTipoGestion = [
      DropdownOption(id: '', name: 'Selecciona'),
      DropdownOption(id: '04', name: 'Visita'),
    ];

    List<DropdownOption> optionsRecordatorio = [
      //DropdownOption(id: '', name: 'Selecciona'),
      DropdownOption(id: '1', name: '5 MINUTOS ANTES'),
      DropdownOption(id: '2', name: '15 MINUTOS ANTES'),
      DropdownOption(id: '3', name: '30 MINUTOS ANTES'),
      DropdownOption(id: '4', name: '1 DIA ANTES'),
      DropdownOption(id: '5', name: '1 SEMANA ANTES'),
    ];

    final evenPlannertForm = ref.watch(eventPlannerFormProvider);
     
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SelectCustomForm(
            label: 'Tipo de gestión',
            value: evenPlannertForm.evntIdTipoGestion.value.trim(),
            callbackChange: (String? newValue) {
              DropdownOption searchTipoGestion = optionsTipoGestion
                  .where((option) => option.id == newValue!)
                  .first;
              ref
                  .read(eventPlannerFormProvider.notifier)
                  .onTipoGestionChanged(newValue ?? '', searchTipoGestion.name);
            },
            items: optionsTipoGestion,
            errorMessage: evenPlannertForm.evntIdTipoGestion.errorMessage,
          ),
          
          const SizedBox(height: 10),
          const Text(
            'Fecha',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Center(
            child: GestureDetector(
              onTap: () => _selectDate(context, ref),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd-MM-yyyy').format(evenPlannertForm.evntFechaInicioEvento ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Hora',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
                  onTap: () => _selectTime(context, ref, 'inicio'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(evenPlannertForm.evntHoraInicioEvento != null
                                  ? DateFormat('HH:mm:ss').parse(
                                      evenPlannertForm.evntHoraInicioEvento ?? '')
                                  : DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
    
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Tiempo entre reuniones',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: evenPlannertForm.evntIdRecordatorio.toString(),
                      onChanged: (String? newValue) {
                        DropdownOption searchRecordatorio = optionsRecordatorio
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(eventPlannerFormProvider.notifier)
                            .onTiempoReunionesChanged(int.parse(newValue!), searchRecordatorio.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsRecordatorio.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Responsable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(
                        label: Text('${evenPlannertForm.evntNombreUsuarioResponsable}',
                    ))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          RouteCard(),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    //print(picked);

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      ref.read(eventPlannerFormProvider.notifier).onFechaChanged(picked);
    }
  }

  Future<void> _selectTime(
      BuildContext context, WidgetRef ref, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      String formattedTime = '${picked.toString().substring(10, 15)}:00';

      //if (type == 'inicio') {
        ref
            .read(eventPlannerFormProvider.notifier)
            .onHoraInicioChanged(formattedTime);
      //}

     
    }
  }

}
