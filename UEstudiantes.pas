unit UEstudiantes;

interface

type
  TEstudiante = record
    legajo: string[10];
    dni: string[10];
    apynom: string[60];
    carrera: string[60];
    anioIngreso: word;
    promedio: real;
    avance: real;
  end;

  TArchivoEstudiantes = file of TEstudiante;

procedure CrearArchivoEstudiantes(var arch: TArchivoEstudiantes);
procedure AltaEstudiante(var arch: TArchivoEstudiantes);
procedure BajaEstudiante(var arch: TArchivoEstudiantes);
procedure ModificacionEstudiante(var arch: TArchivoEstudiantes);
procedure ListarEstudiantes(var arch: TArchivoEstudiantes);
function BuscarEstudiantePorLegajo(var arch: TArchivoEstudiantes; legajoBuscado: string; var est: TEstudiante): boolean;
function BuscarEstudiantePorDNI(var arch: TArchivoEstudiantes; dniBuscado: string): boolean;

implementation

procedure CrearArchivoEstudiantes(var arch: TArchivoEstudiantes);
begin
  Assign(arch, 'estudiantes.dat');
  Reset(arch);
  if IOResult <> 0 then
    Rewrite(arch)
  else
    Close(arch);
end;

function BuscarEstudiantePorLegajo(var arch: TArchivoEstudiantes; legajoBuscado: string; var est: TEstudiante): boolean;
var
  encontrado: boolean;
begin
  encontrado := false;
  Reset(arch);
  while not EOF(arch) and not encontrado do
  begin
    Read(arch, est);
    if est.legajo = legajoBuscado then
      encontrado := true;
  end;
  Close(arch);
  BuscarEstudiantePorLegajo := encontrado;
end;

function BuscarEstudiantePorDNI(var arch: TArchivoEstudiantes; dniBuscado: string): boolean;
var
  est: TEstudiante;
  encontrado: boolean;
begin
  encontrado := false;
  Reset(arch);
  while not EOF(arch) and not encontrado do
  begin
    Read(arch, est);
    if est.dni = dniBuscado then
      encontrado := true;
  end;
  Close(arch);
  BuscarEstudiantePorDNI := encontrado;
end;

procedure AltaEstudiante(var arch: TArchivoEstudiantes);
var
  estNuevo, estAux: TEstudiante;
begin
  Writeln('Alta de estudiante');
  Write('Ingrese Legajo (max 10): ');
  Readln(estNuevo.legajo);
  
  if BuscarEstudiantePorLegajo(arch, estNuevo.legajo, estAux) then
  begin
    Writeln('Ya existe un estudiante con ese Legajo');
    exit;
  end;

  Write('Ingrese DNI (max 10): ');
  Readln(estNuevo.dni);

  if BuscarEstudiantePorDNI(arch, estNuevo.dni) then
  begin
    Writeln('Ya existe un estudiante con ese DNI');
    exit;
  end;

  Write('Ingrese Nombre y Apellido: ');
  Readln(estNuevo.apynom);
  Write('Ingrese Carrera: ');
  Readln(estNuevo.carrera);
  Write('Ingrese Anio de ingreso: ');
  Readln(estNuevo.anioIngreso);
  Write('Ingrese Promedio: ');
  Readln(estNuevo.promedio);
  Write('Ingrese Porcentaje de avance en carrera: ');
  Readln(estNuevo.avance);

  Reset(arch);
  Seek(arch, FileSize(arch));
  Write(arch, estNuevo);
  Close(arch);
  Writeln('Estudiante guardado');
end;

procedure BajaEstudiante(var arch: TArchivoEstudiantes);
var
  legajoBuscado: string[10];
  archTemp: TArchivoEstudiantes;
  est: TEstudiante;
  encontrado: boolean;
begin
  Writeln('Eliminar estudiante');
  Write('Ingrese Legajo del estudiante a eliminar: ');
  Readln(legajoBuscado);

  encontrado := false;
  Assign(archTemp, 'temp_est.dat');
  Rewrite(archTemp);
  Reset(arch);

  while not EOF(arch) do
  begin
    Read(arch, est);
    if est.legajo = legajoBuscado then
      encontrado := true
    else
      Write(archTemp, est);
  end;

  Close(arch);
  Close(archTemp);

  if encontrado then
  begin
    Erase(arch);
    Rename(archTemp, 'estudiantes.dat');
    Writeln('Estudiante eliminado');
  end
  else
  begin
    Erase(archTemp);
    Writeln('No se encontro el estudiante');
  end;
end;

procedure ModificacionEstudiante(var arch: TArchivoEstudiantes);
var
  legajoBuscado: string[10];
  est: TEstudiante;
  encontrado: boolean;
  posicion: longint;
begin
  Writeln('Modificar estudiante');
  Write('Ingrese Legajo del estudiante a modificar: ');
  Readln(legajoBuscado);

  Reset(arch);
  encontrado := false;
  posicion := 0;
  while not EOF(arch) and not encontrado do
  begin
    posicion := FilePos(arch);
    Read(arch, est);
    if est.legajo = legajoBuscado then
      encontrado := true;
  end;

  if encontrado then
  begin
    Writeln('Estudiante encontrado: ', est.apynom);
    Write('Nuevo DNI: '); Readln(est.dni);
    Write('Nuevo Nombre y Apellido: '); Readln(est.apynom);
    Write('Nueva Carrera: '); Readln(est.carrera);
    Write('Nuevo Anio de ingreso: '); Readln(est.anioIngreso);
    Write('Nuevo Promedio: '); Readln(est.promedio);
    Write('Nuevo Porcentaje de avance: '); Readln(est.avance);

    Seek(arch, posicion);
    Write(arch, est);
    Writeln('Modificacion hecha');
  end
  else
    Writeln('Estudiante no encontrado');
  Close(arch);
end;

procedure ListarEstudiantes(var arch: TArchivoEstudiantes);
var
  est: TEstudiante;
begin
  Writeln('Lista de estudiantes');
  Reset(arch);
  if EOF(arch) then
    Writeln('No hay estudiantes registrados')
  else
    while not EOF(arch) do
    begin
      Read(arch, est);
      Writeln('Legajo: ', est.legajo, ' | DNI: ', est.dni, ' | Nombre: ', est.apynom);
      Writeln('Carrera: ', est.carrera, ' | Promedio: ', est.promedio:0:2, ' | Avance: ', est.avance:0:2, '%');
      Writeln;
    end;
  Close(arch);
end;

begin
end.
