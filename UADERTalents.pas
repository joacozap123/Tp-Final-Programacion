program UADERTalents;

uses
  UEstudiantes, UHabilidades, UCompetencias;

const
  MAX = 100;

type
  THabilidadEstudiante = record
    codigoHab: string[10];
    nombreHab: string[40];
    nivel: byte;
  end;

  TEstudiantePromedio = record
    est: TEstudiante;
    nivel: byte;
  end;

var
  archivoEstudiantes: TArchivoEstudiantes;
  archivoHabilidades: TArchivoHabilidades;
  archivoCompetencias: TArchivoCompetencias;
  opcion, opcionsec: integer;

procedure ConsultarEstudiantePorLegajo(var archEst: TArchivoEstudiantes; var archHab: TArchivoHabilidades; var archComp: TArchivoCompetencias);
var
  legajoBuscado: string[10];
  estEncontrado: TEstudiante;
  comp: TCompetencia;
  hab: THabilidad;
  vectorHabilidades: array[1..MAX] of THabilidadEstudiante;
  cantHabilidades, i, j: integer;
  auxHabilidad: THabilidadEstudiante;
  textoNivel: string;
begin
  Writeln();
  Write('Ingrese Legajo del estudiante: ');
  Readln(legajoBuscado);

  if not BuscarEstudiantePorLegajo(archEst, legajoBuscado, estEncontrado) then
  begin
    Writeln('No se encontro un estudiante con ese Legajo');
    exit;
  end;

  Writeln;
  Writeln('Datos:');
  Writeln('Legajo: ', estEncontrado.legajo, ' | DNI: ', estEncontrado.dni);
  Writeln('Nombre y Apellido: ', estEncontrado.apynom);
  Writeln('Carrera: ', estEncontrado.carrera);
  Writeln('Promedio: ', estEncontrado.promedio:0:2, ' | Avance: ', estEncontrado.avance:0:2, '%');
  Writeln;

  cantHabilidades := 0;
  Reset(archComp);
  while not EOF(archComp) do
  begin
    Read(archComp, comp);
    if comp.legajoEstudiante = legajoBuscado then
    begin
      if BuscarHabilidad(archHab, comp.codigoHabilidad, hab) then
      begin
        cantHabilidades := cantHabilidades + 1;
        vectorHabilidades[cantHabilidades].codigoHab := hab.codigo;
        vectorHabilidades[cantHabilidades].nombreHab := hab.nombre;
        vectorHabilidades[cantHabilidades].nivel := comp.nivelDominio;
      end;
    end;
  end;
  Close(archComp);

  if cantHabilidades = 0 then
  begin
    Writeln('El estudiante no tiene habilidades registradas');
    exit;
  end;

  for i := 1 to cantHabilidades - 1 do
    for j := i + 1 to cantHabilidades do
    begin
      if (vectorHabilidades[i].codigoHab > vectorHabilidades[j].codigoHab) or
         ((vectorHabilidades[i].codigoHab = vectorHabilidades[j].codigoHab) and (vectorHabilidades[i].nivel > vectorHabilidades[j].nivel)) then
      begin
        auxHabilidad := vectorHabilidades[i];
        vectorHabilidades[i] := vectorHabilidades[j];
        vectorHabilidades[j] := auxHabilidad;
      end;
    end;

  Writeln('Habilidades:');
  for i := 1 to cantHabilidades do
  begin
    case vectorHabilidades[i].nivel of
      1: textoNivel := 'Inicial';
      2: textoNivel := 'Basico';
      3: textoNivel := 'Intermedio';
      4: textoNivel := 'Avanzado';
      5: textoNivel := 'Experto';
    end;
    Writeln(' Codigo: ', vectorHabilidades[i].codigoHab, ' | Habilidad: ', vectorHabilidades[i].nombreHab, ' | Nivel: ', vectorHabilidades[i].nivel, ' (', textoNivel, ')');
  end;
end;

procedure ConsultarEstudiantesPorHabilidadMinima(var archEst: TArchivoEstudiantes; var archHab: TArchivoHabilidades; var archComp: TArchivoCompetencias);
var
  codigoBuscado: string[10];
  nivelMinimo: byte;
  habEncontrada: THabilidad;
  comp: TCompetencia;
  est: TEstudiante;
  vectorResultados: array[1..MAX] of TEstudiantePromedio;
  cantResultados, i, j: integer;
  auxResultado: TEstudiantePromedio;
  textoNivel: string;
begin
  Writeln('Buscar estudiantes por habilidad y nivel minimo');
  Write('Ingrese Codigo de habilidad requerido: ');
  Readln(codigoBuscado);

  if not BuscarHabilidad(archHab, codigoBuscado, habEncontrada) then
  begin
    Writeln('La habilidad ingresada no existe');
    exit;
  end;

  repeat
    Write('Ingrese Nivel minimo de dominio (1 a 5): ');
    Readln(nivelMinimo);
  until (nivelMinimo >= 1) and (nivelMinimo <= 5);

  cantResultados := 0;
  Reset(archComp);
  while not EOF(archComp) do
  begin
    Read(archComp, comp);
    if (comp.codigoHabilidad = codigoBuscado) and (comp.nivelDominio >= nivelMinimo) then
    begin
      if BuscarEstudiantePorLegajo(archEst, comp.legajoEstudiante, est) then
      begin
        cantResultados := cantResultados + 1;
        vectorResultados[cantResultados].est := est;
        vectorResultados[cantResultados].nivel := comp.nivelDominio;
      end;
    end;
  end;
  Close(archComp);

  if cantResultados = 0 then
  begin
    Writeln('No se encontraron estudiantes');
    exit;
  end;

  for i := 1 to cantResultados - 1 do
    for j := i + 1 to cantResultados do
    begin
      if (vectorResultados[i].est.promedio < vectorResultados[j].est.promedio) or
         ((vectorResultados[i].est.promedio = vectorResultados[j].est.promedio) and (vectorResultados[i].est.apynom > vectorResultados[j].est.apynom)) then
      begin
        auxResultado := vectorResultados[i];
        vectorResultados[i] := vectorResultados[j];
        vectorResultados[j] := auxResultado;
      end;
    end;

  Writeln;
  Writeln('Estudiantes Encontrados:');

  for i := 1 to cantResultados do
  begin
    case vectorResultados[i].nivel of
      1: textoNivel := 'Inicial';
      2: textoNivel := 'Basico';
      3: textoNivel := 'Intermedio';
      4: textoNivel := 'Avanzado';
      5: textoNivel := 'Experto';
    else
      textoNivel := 'Desconocido';
    end;
    Writeln('Nombre: ', vectorResultados[i].est.apynom, ' | Legajo: ', vectorResultados[i].est.legajo);
    Writeln('Carrera: ', vectorResultados[i].est.carrera);
    Writeln('Promedio: ', vectorResultados[i].est.promedio:0:2, ' | Avance: ', vectorResultados[i].est.avance:0:2, '%');
    Writeln('Nivel en "', habEncontrada.nombre, '": ', vectorResultados[i].nivel, ' (', textoNivel, ')');
    Writeln;
  end;
end;

begin
  CrearArchivoEstudiantes(archivoEstudiantes);
  CrearArchivoHabilidades(archivoHabilidades);
  CrearArchivoCompetencias(archivoCompetencias);

  repeat
    Writeln;
    Writeln;
    Writeln('UADER talents');

    Writeln('1. Administrar Estudiantes');
    Writeln('2. Administrar Habilidades');
    Writeln('3. Administrar Competencias');
    Writeln('4. Buscar Estudiante por Legajo');
    Writeln('5. Listar Estudiantes por Habilidad y Nivel Minimo');
    Writeln('0. Salir');
    Write('Seleccione una opcion: ');
    Readln(opcion);

    case opcion of
      1: begin
           Writeln;
           Writeln('Menu de Estudiantes');
           Writeln('1. Alta | 2. Baja | 3. Modificacion | 4. Listar');
           Readln(opcionsec);
           case opcionsec of
             1: AltaEstudiante(archivoEstudiantes);
             2: BajaEstudiante(archivoEstudiantes);
             3: ModificacionEstudiante(archivoEstudiantes);
             4: ListarEstudiantes(archivoEstudiantes);
           end;
         end;
      2: begin
           Writeln;
           Writeln('Menu de Habilidades');
           Writeln('1. Alta | 2. Baja | 3. Modificacion | 4. Listar');
           Readln(opcionsec);
           case opcionsec of
             1: AltaHabilidad(archivoHabilidades);
             2: BajaHabilidad(archivoHabilidades);
             3: ModificacionHabilidad(archivoHabilidades);
             4: ListarHabilidades(archivoHabilidades);
           end;
         end;
      3: begin
           Writeln;
           Writeln('Menu de Competenciaas');
           Writeln('1. Alta | 2. Baja | 3. Modificacion | 4. Listar');
           Readln(opcionsec);
           case opcionsec of
             1: AltaCompetencia(archivoCompetencias, archivoEstudiantes, archivoHabilidades);
             2: BajaCompetencia(archivoCompetencias);
             3: ModificacionCompetencia(archivoCompetencias);
             4: ListarCompetencias(archivoCompetencias);
           end;
         end;
      4: ConsultarEstudiantePorLegajo(archivoEstudiantes, archivoHabilidades, archivoCompetencias);
      5: ConsultarEstudiantesPorHabilidadMinima(archivoEstudiantes, archivoHabilidades, archivoCompetencias);
    end;
  until opcion = 0;

end.
