import '../../domain/domain.dart';
import '../../../contacts/domain/domain.dart';


class ActivityMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Activity(
    id: json['ACTI_ID_ACTIVIDAD'] ?? '',
    actiComentario: json['ACTI_COMENTARIO'] ?? '',
    actiEstadoReg: json['ACTI_ESTADO_REG'] ?? '',
    actiFechaActividad: DateTime.parse(json["ACTI_FECHA_ACTIVIDAD"]),
    actiHoraActividad: json['ACTI_HORA_ACTIVIDAD'] ?? '',
    actiIdContacto: json['ACTI_ID_CONTACTO'] ?? '',
    actiIdOportunidad: json['ACTI_ID_OPORTUNIDAD'] ?? '',
    actiIdTipoGestion: json['ACTI_ID_TIPO_GESTION'] ?? '',
    actiIdUsuarioRegistro: json['ACTI_ID_USUARIO_REGISTRO'] ?? '',
    actiIdUsuarioResponsable: json['ACTI_ID_USUARIO_RESPONSABLE'] ?? '',
    actiNombreArchivo: json['ACTI_NOMBRE_ARCHIVO'] ?? '',
    actiNombreOportunidad: json['ACTI_NOMBRE_OPORTUNIDAD'] ?? '',
    actiNombreTipoGestion: json['ACTI_NOMBRE_TIPO_GESTION'] ?? '',
    actiTiempoGestion: json['ACTI_TIEMPO_GESTION'] ?? '',
    cchkComentarioCheckIn: json['CCHK_COMENTARIO_CHECK_IN'] ?? '',
    cchkComentarioCheckOut: json['CCHK_COMENTARIO_CHECK_OUT'] ?? '',
    actiRuc: json['ACTI_RUC'] ?? '',
    actiRazon: json['ACTI_RAZON'] ?? '',
    contactoDesc: json['CONTACTO_DESC'] ?? '',
    actiNombreResponsable: json['ACTI_NOMBRE_RESPONSABLE'] ?? '',
    cchkFechaRegistroCheckIn: json['CCHK_FECHA_REGISTRO_CHECK_IN'] ?? '',
    cchkFechaRegistroCheckOut: json['CCHK_FECHA_REGISTRO_CHECK_OUT'] ?? '',
    actiIdUsuarioActualizacion: json['ACTI_ID_USUARIO_ACTUALIZACION'] ?? '',
    actiIdActividadIn: json['ACTI_ID_ACTIVIDAD_IN'] ?? '',
    actiIdTipoRegistro: json['ACTI_ID_TIPO_REGISTRO'] ?? '',
    actividadesContacto: json["ACTIVIDADES_CONTACTO"] != null ? List<ContactArray>.from(json["ACTIVIDADES_CONTACTO"].map((x) => ContactArray.fromJson(x))) : [],
    actividadesContactoEliminar: json["ACTIVIDADES_CONTACTO_ELIMINAR"] != null ? List<ContactArray>.from(json["ACTIVIDADES_CONTACTO_ELIMINAR"].map((x) => ContactArray.fromJson(x))) : [],
    opt: json['OPT'] ?? '',
    coordenadaLongitud: json['COORDENADA_LONGITUD'] ?? '',
    coordenadalatitud: json['COORDENADA_LATITUD'] ?? '',
    localNombre: json['LOCAL_NOMBRE'] ?? '',
  );

}
