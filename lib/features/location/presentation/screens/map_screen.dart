
import '../../../companies/presentation/providers/forms/company_form_provider.dart';
import '../../../companies/presentation/providers/forms/company_local_form_provider.dart';
import '../../../companies/presentation/widgets/show_loading_message.dart';
import '../../domain/domain.dart';
import '../delegates/search_places_delegate.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../providers/selected_map_provider.dart';
import '../search/search_places_provider.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final companyCheckInState = ref.watch(companyCheckInProvider(rucId));

    return const Scaffold(
      body: _MapView(),
    );
  }
}

class _MapView extends ConsumerStatefulWidget {
  const _MapView();

  @override
  _CompanyMapViewState createState() => _CompanyMapViewState();
}

class _CompanyMapViewState extends ConsumerState {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      //final locationNotifier = ref.read(locationProvider.notifier);
      //locationNotifier.startFollowingUser();

      //print('INICIO START FLLOWING');
      final locationNotifier = ref.read(locationProvider.notifier);
      final locationCurrent = await locationNotifier.currentPosition();

      final mapState = ref.watch(mapProvider.notifier);
      mapState.onChangeMapCenter(locationCurrent);
    });
  }

  @override
  void dispose() {
    super.dispose();
    /*WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).stopFollowingUser();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final locationState = ref.watch(locationProvider);
    final mapState = ref.watch(mapProvider.notifier);
    LatLng lastKnownLocation = locationState.lastKnownLocation ?? const LatLng(-12.04318, -77.02824);

    CameraPosition initialCameraPosition =
        CameraPosition(target: lastKnownLocation, zoom: 15);

    return SingleChildScrollView(
      child: Stack(children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: Listener(
            child: GoogleMap(
                initialCameraPosition: initialCameraPosition,
                mapType: MapType.normal,
                /*compassEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,*/
                //polylines: polylines,
                //markers: markers,
                onMapCreated: (controller) => mapState.onInitMap(controller),
                onCameraMove: (position) =>
                    mapState.onChangeMapCenter(position.target)),
          ),
        ),

        //SEARCH
        FadeInDown(
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInLeft(
                    duration: const Duration(milliseconds: 300),
                    child: CircleAvatar(
                      maxRadius: 24,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        //final result = await showSearch(context: context, delegate: SearchDestinationDelegate());

                        //print(result);

                        final searchedPlaces = ref.read(searchedPlacesProvider);
                        final searchQuery = ref.read(searchQueryPlacesProvider);

                        showSearch<Place?>(
                                query: searchQuery,
                                context: context,
                                delegate: SearchPlaceDelegate(
                                    initialPlaces: searchedPlaces,
                                    searchPlaces: ref
                                        .read(searchedPlacesProvider.notifier)
                                        .searchPlacesByQuery))
                            .then((place) {
                          if (place == null) return;

                          LatLng latLng = LatLng(place.location.latitude,
                              place.location.longitude);

                          ref.read(mapProvider.notifier).moveCamera(latLng);

                          ref
                              .read(mapProvider.notifier)
                              .onChangeSelectedPlaceCenter(place);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 5))
                            ]),
                        child: const Text('Buscar dirección',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        //CURSOR MAP
        SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -22),
                    child: BounceInDown(
                        from: 100,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 60,
                          color: Colors.deepOrange,
                        )),
                  ),
                ),
              ],
            )),

        Positioned(
            bottom: 50,
            left: 40,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: MaterialButton(
                minWidth: size.width - 120,
                color: Colors.blueAccent,
                elevation: 0,
                height: 50,
                shape: const StadiumBorder(),
                onPressed: () async {
                  showLoadingMessage(context);

                  LatLng? location = ref.read(mapProvider).mapCenter;
                  Place? placeSearch = ref.read(mapProvider).selectedPlace;

                  await ref
                      .read(selectedMapProvider.notifier)
                      .selectedAddressMap(placeSearch, location!);

                  var stateSelectedMap = ref.read(selectedMapProvider.notifier).state;

                  //ref.read(selectedMapProvider.notifier).onSelectPlace('');
                  ref.read(selectedMapProvider.notifier).onFreeIsUpdateAddress();
                  ref.read(selectedMapProvider.notifier).onChangeStateProcess('updated');

                  var lat = stateSelectedMap.location?.latitude;
                  var lng = stateSelectedMap.location?.longitude;

                  if (stateSelectedMap.module == 'company' && stateSelectedMap.input == 'direction') {
                    ref.watch(companyFormProvider(stateSelectedMap.entity).notifier).onLoadAddressCompanyLocalChanged(
                      stateSelectedMap.address ?? '',
                      '$lat, $lng',
                      '$lat',
                      '$lng',
                      stateSelectedMap.ubigeo ?? '',
                      stateSelectedMap.departament ?? '',
                      stateSelectedMap.province ?? '',
                      stateSelectedMap.district ?? '',
                    );

                  }

                  if (stateSelectedMap.module == 'company' && stateSelectedMap.input == 'direction-local') {
                    ref.watch(companyFormProvider(stateSelectedMap.entity).notifier).onLoadAddressCompanyLocalChanged(
                      stateSelectedMap.address ?? '',
                      '$lat, $lng',
                      '$lat',
                      '$lng',
                      stateSelectedMap.ubigeo ?? '',
                      stateSelectedMap.departament ?? '',
                      stateSelectedMap.province ?? '',
                      stateSelectedMap.district ?? '',
                    );
                  }

                  if (stateSelectedMap.module == 'company-local' && stateSelectedMap.input == 'direction-local') {
                    ref.watch(companyLocalFormProvider(stateSelectedMap.entity).notifier).onLoadAddressChanged(
                      stateSelectedMap.address ?? '',
                      '$lat, $lng',
                      '$lat',
                      '$lng',
                      stateSelectedMap.ubigeo ?? '',
                      stateSelectedMap.departament ?? '',
                      stateSelectedMap.province ?? '',
                      stateSelectedMap.district ?? '',
                    );
                  }


                  //sleep(const Duration(seconds: 10));
                  Navigator.pop(context);
                  Navigator.pop(context);

                },
                child: const Text('Confimar ubicación',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ))
      ]),
    );
  }
}
