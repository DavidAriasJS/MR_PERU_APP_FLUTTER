import 'package:crm_app/features/opportunities/domain/domain.dart';


abstract class OpportunitiesRepository {

  Future<List<Opportunity>> getOpportunities(String ruc);
  Future<Opportunity> getOpportunityById(String id);

  Future<OpportunityResponse> createUpdateOpportunity( Map<dynamic,dynamic> opportunityLike );
  
  Future<List<Opportunity>> searchOpportunities(String query);
}

