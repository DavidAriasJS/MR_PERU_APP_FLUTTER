import 'package:crm_app/features/contacts/domain/domain.dart';

abstract class ContactsDatasource {

  Future<List<Contact>> getContacts();
  Future<Contact> getContactById(String id);

  Future<ContactResponse> createUpdateContact( Map<dynamic,dynamic> contactLike );

}

