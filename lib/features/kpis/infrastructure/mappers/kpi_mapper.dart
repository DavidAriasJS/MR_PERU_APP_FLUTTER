import '../../domain/domain.dart';
import '../../domain/entities/array_user.dart';
import '../../domain/entities/periodicidad.dart';


class KpiMapper {

  static jsonToEntity( Map<dynamic, dynamic> json ) => Kpi(
    id: json['OBJR_ID_OBJETIVO'] ?? '',
    objrNombre: json['OBJR_NOMBRE'] ?? '',
    objrIdUsuarioResponsable: json['OBJR_ID_USUARIO_RESPONSABLE'] ?? '',
    objrIdAsignacion: json["OBJR_ID_ASIGNACION"] ?? '',
    objrIdTipo: json['OBJR_ID_TIPO'] ?? '',
    objrIdPeriodicidad: json['OBJR_ID_PERIODICIDAD'] ?? '',
    objrObservaciones: json['OBJR_OBSERVACIONES'] ?? '',
    objrIdUsuarioRegistro: json['OBJR_ID_USUARIO_REGISTRO'] ?? '',
    objrIdCategoria: json['OBJR_ID_CATEGORIA'] ?? '',
    orden: json['OBJR_ORDEN'] ?? '',
    objrNombreAsignacion: json['OBJR_NOMBRE_ASIGNACION'] ?? '',
    objrNombreCategoria: json['OBJR_NOMBRE_CATEGORIA'] ?? '',
    objrNombreTipo: json['OBJR_NOMNRE_TIPO'] ?? '',
    objrNombrePeriodicidad: json['OBJR_NOMBRE_PERIODICIDAD'] ?? '',
    totalRegistro: json['TOTAL_REGISTRO'] ?? 0,
    porcentaje: (json['PORCENTAJE']?? 0.00).toDouble() ,
    objrCantidad: json['OBJR_CANTIDAD'] ?? '0',
    objrValorDifMes: json['OBJR_VALOR_DIFERENTE'] ?? '0',
    userreportNameResponsable: json['USERREPORT_NAME_RESPONSABLE'] ?? '',
    usuariosAsignados: json["USUARIOS_ASIGNADOS"] != null ? List<UsuarioAsignado>.from(json["USUARIOS_ASIGNADOS"].map((x) => UsuarioAsignado.fromJson(x))) : [],
    arrayuserasignacion: json["USUARIOS_ASIGNADOS"] != null ? List<ArrayUser>.from(json["USUARIOS_ASIGNADOS"].map((x) => ArrayUser.fromJson(x))) : [],
    peobIdPeriodicidad: json["OBJETIVO_PERIODICIDAD_CALENDARIO"] != null ? List<Periodicidad>.from(json["OBJETIVO_PERIODICIDAD_CALENDARIO"].map((x) => Periodicidad.fromJson(x))) : [],
  );

}
