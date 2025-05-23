import 'dart:developer';

import 'package:crm_app/features/companies/presentation/delegates/search_company_local_active_delegate.dart';
import 'package:crm_app/features/companies/presentation/providers/company_provider.dart';
import 'package:crm_app/features/companies/presentation/search/search_company_locales_active_provider.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';

import '../../../companies/domain/domain.dart';
import '../../../companies/presentation/delegates/search_company_active_delegate.dart';
import '../../../companies/presentation/search/search_companies_active_provider.dart';
import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../../../resource-detail/presentation/providers/resource_details_provider.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';
import '../../../shared/widgets/title_section_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContactScreen extends ConsumerWidget {
  final String contactId;

  const ContactScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactProvider(contactId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${ contactState.contact!.id == 'new' ? 'Crear': 'Editar' } contacto'
          , style: const TextStyle(
            fontWeight: FontWeight.w500
          )),
          /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: contactState.isLoading
            ? const FullScreenLoader()
            :  (contactState.contact != null 
              ? _ContactView(contact: contactState.contact!) 
              : const Center(
                child: Text('No se encontro información del contacto'),
              ) ),
        floatingActionButton:  contactState.contact != null 
        ? FloatingActionButtonCustom(
            isDisabled: contactState.isSaving,
            callOnPressed: () {
              if (contactState.contact == null) return;
              showLoadingMessage(context);
              ref.read(contactProvider(contactId).notifier).isSaving();
              ref
                  .read(contactFormProvider(contactState.contact!).notifier)
                  .onFormSubmit()
                  .then((CreateUpdateContactResponse value) {
                //if ( !value.response ) return;
                if (value.message != '') {
                  showSnackbar(context, value.message);
                  if (value.response) {
                    /// CREATE CONTACT FROM OPPORTUNITY MODULE
                    log("this is the validator ${ref.read(isFromOpportunity)}");
                    if(ref.read(isFromOpportunity)){
                      log('THIS IS CONTACT ID: ${value.id}');
                      ref.read(idCreateFromOP.notifier).state = value.id;
                      context.pop();
                    }else {

                    print('CONTATID: ${value.id}');
                    ref.read(contactsProvider.notifier).loadNextPage(isRefresh: true);
                    ref.read(contactProvider(contactId).notifier).loadContact(contactId);
                    ref.read(companyProvider(value.id!).notifier).loadSecundaryContacts();

                    //Timer(const Duration(seconds: 3), () {
                      //context.replace('/contacts');
                      context.pop();
                    //});
                    }
                  }
                }
                context.pop();
              });
              ref.read(contactProvider(contactId).notifier).isNotSaving();
            },
            iconData: Icons.save)
        : null
      ),
    );
  }
}

class _ContactView extends ConsumerWidget {
  final Contact contact;

  const _ContactView({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        contact != null
            ? _ContactInformationv2(contact: contact)
            : const Center(
                child: Text('No se encontre datos de la empresa'),
              ),
      ],
    );
  }
}

class _ContactInformationv2 extends ConsumerStatefulWidget {
  final Contact contact;

  const _ContactInformationv2({required this.contact});

  @override
  __ContactInformationv2State createState() => __ContactInformationv2State();
}

class __ContactInformationv2State extends ConsumerState<_ContactInformationv2> {
  List<DropdownOption> optionsCargo = [
    DropdownOption(id: '', name: 'Cargando...')
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await ref.read(resourceDetailsProvider.notifier).loadCatalogById(groupId: '07').then((value) => {
        setState(() {
          optionsCargo = value;
        })
      });

      String? idEmpresa = ref.read(uiProvider).idCompanyAct;
      String? nameEmpresa = ref.read(uiProvider).nameCompanyAct;
      
      if (widget.contact.id == "new" && idEmpresa != "") { 
        ref.read(contactFormProvider(widget.contact).notifier).onRucChanged(idEmpresa ?? '');
        ref.read(contactFormProvider(widget.contact).notifier).onRazonChanged(nameEmpresa ?? '');
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    final contactForm = ref.watch(contactFormProvider(widget.contact));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empresa:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: contactForm.ruc.errorMessage != null
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _openSearch(context, ref, contactForm.contactoUsuarioRegistro ?? '');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          //color: Colors.grey,
                          color: contactForm.ruc.errorMessage != null
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            contactForm.ruc.value == ''
                                ? 'Seleccione empresa'
                                : contactForm.razon,
                            //_selectedCompany.isEmpty ? 'Seleccione una empresa' : _selectedCompany,
                            style: TextStyle(
                                fontSize: 16,
                                color: contactForm.ruc.errorMessage != null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearch(context, ref, contactForm.contactoUsuarioRegistro ?? '');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (contactForm.ruc.errorMessage != null)
                  Text(
                    contactForm.ruc.errorMessage ?? 'Requerido',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: contactForm.contactoLocalCodigo.errorMessage != null
                        ? Colors.red
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    if (contactForm.ruc.value == "") {
                      showSnackbar(context, 'Debe seleccionar una empresa');
                      return;
                    }

                    _openSearchCompanyLocales(
                        context, ref, contactForm.ruc.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: contactForm.contactoLocalCodigo.errorMessage !=
                                  null
                              ? Colors.red
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            contactForm.contactoLocalCodigo.value == ''
                                ? 'Seleccione local'
                                : contactForm.contactoLocalNombre ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color: contactForm
                                            .contactoLocalCodigo.errorMessage !=
                                        null
                                    ? Colors.red
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if (contactForm.ruc.value == "") {
                              showSnackbar(
                                  context, 'Debe seleccionar una empresa');
                              return;
                            }

                            _openSearchCompanyLocales(
                                context, ref, contactForm.ruc.value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (contactForm.contactoLocalCodigo.errorMessage != null)
            Text(
              contactForm.contactoLocalCodigo.errorMessage ?? 'Requerido',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          const SizedBox(height: 10),

          CustomCompanyField(
            isTopField: true,
            label: 'Nombre *',
            initialValue: contactForm.contactoDesc.value,
            onChanged:
                ref.read(contactFormProvider(widget.contact).notifier).onNameChanged,
            errorMessage: contactForm.contactoDesc.errorMessage,
          ),
          optionsCargo.length > 1 ? SelectCustomForm(
            label: 'Cargo',
            value: contactForm.contactoIdCargo.value,
            callbackChange: (String? newValue) {
              DropdownOption searchCargo =
                  optionsCargo.where((option) => option.id == newValue!).first;

              ref
                  .read(contactFormProvider(widget.contact).notifier)
                  .onCargoChanged(newValue!);
              ref
                  .read(contactFormProvider(widget.contact).notifier)
                  .onNombreCargoChanged(searchCargo.name);
            },
            items: optionsCargo,
            errorMessage: contactForm.contactoIdCargo.errorMessage,
          ): PlaceholderInput(text: 'Cargando Cargo...'),
          TitleSectionForm(title: 'DATOS DE CONTACTO'),
          
          CustomCompanyField(
            label: 'Celular *',
            keyboardType: TextInputType.phone,
            initialValue: contactForm.contactoTelefonoc.value,
            onChanged: (String? newValue) {
              ref
                  .read(contactFormProvider(widget.contact).notifier)
                  .onTelefonoNocChanged(newValue!);
            },
            errorMessage: contactForm.contactoTelefonoc.errorMessage,
          ),
          // CustomCompanyField(
          //   label: 'Teléfono',
          //   keyboardType: TextInputType.phone,
          //   initialValue: contactForm.contactoTelefonof,
          //   onChanged:
          //       ref.read(contactFormProvider(widget.contact).notifier).onPhoneChanged,
          // ),
          CustomCompanyField(
            label: 'Email *',
            keyboardType: TextInputType.emailAddress,
            initialValue: contactForm.contactoEmail,
            onChanged: (String? newValue) {
              ref
                  .read(contactFormProvider(widget.contact).notifier)
                  .onEmailChanged(newValue!);
            },
          ),
          CustomCompanyField(
            label: 'Comentarios',
            initialValue: contactForm.contactoNotas,
            onChanged: (String? newValue) {
              ref
                  .read(contactFormProvider(widget.contact).notifier)
                  .onComentarioChanged(newValue!);
            },
            maxLines: 2,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, WidgetRef ref, String dni) async {
    final searchedCompanies = ref.read(searchedCompaniesProvider);
    final searchQuery = ref.read(searchQueryCompaniesProvider);

    showSearch<Company?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyDelegate(
                dni: dni,
                initialCompanies: searchedCompanies,
                searchCompanies: ref
                    .read(searchedCompaniesProvider.notifier)
                    .searchCompaniesByQuery,
                resetSearchQuery: () {
                    ref.read(searchQueryCompaniesProvider.notifier).update((state) => '');
                },
            ))
        .then((company) {
      if (company == null) return;

      ref.read(contactFormProvider(widget.contact).notifier).onRucChanged(company.ruc);
      ref
          .read(contactFormProvider(widget.contact).notifier)
          .onRazonChanged(company.razon);
    });
  }

  void _openSearchCompanyLocales(
      BuildContext context, WidgetRef ref, String ruc) async {
    final searchedCompanyLocales = ref.read(searchedCompanyLocalesProvider);
    final searchQuery = ref.read(searchQueryCompanyLocalesProvider);

    showSearch<CompanyLocal?>(
        query: searchQuery,
        context: context,
        delegate: SearchCompanyLocalDelegate(
          ruc: ruc,
          initialCompanyLocales: searchedCompanyLocales,
          searchCompanyLocales: ref
              .read(searchedCompanyLocalesProvider.notifier)
              .searchCompanyLocalesByQuery,
          resetSearchQuery: () {
            ref
                .read(searchQueryCompanyLocalesProvider.notifier)
                .update((state) => '');
          },
        )).then((companyLocal) {
      if (companyLocal == null) return;

      ref
          .read(contactFormProvider(widget.contact).notifier)
          .onLocalChanged(companyLocal.id,
              '${companyLocal.localNombre} ${companyLocal.localDireccion}');
    });
  }
}
