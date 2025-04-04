import '../../domain/domain.dart';


class CompanyLocalMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => CompanyLocal(
    id: json['LOCAL_CODIGO'] ?? '',
    localNombre: json['LOCAL_NOMBRE'] ?? '',
    localDireccion: json['LOCAL_DIRECCION'] ?? '',
    localDepartamento: json['LOCAL_DEPARTAMENTO'] ?? '',
    localProvincia: json['LOCAL_PROVINCIA'] ?? '',
    localDistrito: json['LOCAL_DISTRITO'] ?? '',
    localTipo: json['LOCAL_TIPO'] ?? '',
    localCodigoPostal: json['LOCAL_CODIGO_POSTAL'] ?? '',
    coordenadasGeo: json['COORDENADAS_GEO'] ?? '',
    coordenadasLongitud: json['COORDENADAS_LONGITUD'] ?? '',
    coordenadasLatitud: json['COORDENADAS_LATITUD'] ?? '',
    departamento: json['DEPARTAMENTO'] ?? '',
    provincia: json['PROVINCIA'] ?? '',
    localTipoDescripcion: json['LOCAL_TIPO_DESCRIPCION'] ?? '',
    distrito: json['DISTRITO'] ?? '', 
    localCoordenadasGeo: json['LOCAL_COORDENADAS_GEO'] ?? '', 
    localCoordenadasLatitud: json['LOCAL_COORDENADAS_LATITUD'] ?? '', 
    localCoordenadasLongitud: json['LOCAL_COORDENADAS_LONGITUD'] ?? '', 
    localDepartamentoDesc: json['LOCAL_DEPARTAMENTO_DESC'] ?? '',
    localProvinciaDesc: json['LOCAL_PROVINCIA_DESC'] ?? '',
    localDistritoDesc: json['LOCAL_DISTRITO_DESC'] ?? '',
    ruc: json['RUC'] ?? '',
  );

}
