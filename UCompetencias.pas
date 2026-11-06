unit UCompetencias;

interface

uses
  UEstudiantes, UHabilidades;

type
  TCompetencia = record
    legajoEstudiante: string[10];
    codigoHabilidad: string[10];
    nivelDominio: byte;
  end;

  TArchivoCompetencias = file of TCompetencia;

procedure CrearArchivoCompetencias(var arch: TArchivoCompetencias);
procedure AltaCompetencia(var arch: TArchivoCompetencias; var archEst: TArchivoEstudiantes; var archHab: TArchivoHabilidades);
procedure BajaCompetencia(var arch: TArchivoCompetencias);
procedure ModificacionCompetencia(var arch: TArchivoCompetencias);
procedure ListarCompetencias(var arch: TArchivoCompetencias);
function ExisteCompetencia(var arch: TArchivoCompetencias; legajo, codigo: string): boolean;

implementation

procedure CrearArchivoCompetencias(var arch: TArchivoCompetencias);
begin
  Assign(arch, 'competencias.dat');
  Reset(arch);
  if IOResult <> 0 then
    Rewrite(arch)
  else
    Close(arch);
end;

function ExisteCompetencia(var arch: TArchivoCompetencias; legajo, codigo: string): boolean;
var
  comp: TCompetencia;
  encontrado: boolean;
begin
  encontrado := false;
  Reset(arch);
  while not EOF(arch) and not encontrado do
  begin
    Read(arch, comp);
    if (comp.legajoEstudiante = legajo) and (comp.codigoHabilidad = codigo) then
      encontrado := true;
  end;
  Close(arch);
  ExisteCompetencia := encontrado;
end;

procedure AltaCompetencia(var arch: TArchivoCompetencias; var archEst: TArchivoEstudiantes; var archHab: TArchivoHabilidades);
var
  comp: TCompetencia;
  estDummy: TEstudiante;
  habDummy: THabilidad;
begin
  Writeln('Asignar Competencia');
  Write('Ingrese Legajo del estudiante: ');
  Readln(comp.legajoEstudiante);

  if not BuscarEstudiantePorLegajo(archEst, comp.legajoEstudiante, estDummy) then
  begin
    Writeln('El estudiante ingresado no existe');
    exit;
  end;

  Write('Ingrese Codigo de habilidad: ');
  Readln(comp.codigoHabilidad);

  if not BuscarHabilidad(archHab, comp.codigoHabilidad, habDummy) then
  begin
    Writeln('La habilidad ingresada no existe');
    exit;
  end;

  if ExisteCompetencia(arch, comp.legajoEstudiante, comp.codigoHabilidad) then
  begin
    Writeln('El estudiante ya tiene registrada esta habilidad');
    exit;
  end;

  repeat
    Write('Ingrese Nivel de dominio (1: Inicial, 2: Basico, 3: Intermedio, 4: Avanzado, 5: Experto): ');
    Readln(comp.nivelDominio);
    if (comp.nivelDominio < 1) or (comp.nivelDominio > 5) then
      Writeln('Nivel invalido');
  until (comp.nivelDominio >= 1) and (comp.nivelDominio <= 5);

  Reset(arch);
  Seek(arch, FileSize(arch));
  Write(arch, comp);
  Close(arch);
end;

procedure BajaCompetencia(var arch: TArchivoCompetencias);
var
  legajoBuscado, codigoBuscado: string[10];
  archTemp: TArchivoCompetencias;
  comp: TCompetencia;
  encontrado: boolean;
begin
  Writeln('Eliminar Competencia');
  Write('Ingrese Legajo del estudiante: ');
  Readln(legajoBuscado);
  Write('Ingrese Codigo de la habilidad: ');
  Readln(codigoBuscado);

  encontrado := false;
  Assign(archTemp, 'temp_comp.dat');
  Rewrite(archTemp);
  Reset(arch);

  while not EOF(arch) do
  begin
    Read(arch, comp);
    if (comp.legajoEstudiante = legajoBuscado) and (comp.codigoHabilidad = codigoBuscado) then
      encontrado := true
    else
      Write(archTemp, comp);
  end;

  Close(arch);
  Close(archTemp);

  if encontrado then
  begin
    Erase(arch);
    Rename(archTemp, 'competencias.dat');
    Writeln('Competencia eliminada correctamente');
  end
  else
  begin
    Erase(archTemp);
    Writeln('No se encontro dicha competencia');
  end;
end;

procedure ModificacionCompetencia(var arch: TArchivoCompetencias);
var
  legajoBuscado, codigoBuscado: string[10];
  comp: TCompetencia;
  encontrado: boolean;
  posicion: longint;
begin
  Writeln('Modificar Competencai');
  Write('Ingrese Legajo del estudiante: ');
  Readln(legajoBuscado);
  Write('Ingrese Codigo de la habilidad: ');
  Readln(codigoBuscado);

  Reset(arch);
  encontrado := false;
  posicion := 0;
  while not EOF(arch) and not encontrado do
  begin
    posicion := FilePos(arch);
    Read(arch, comp);
    if (comp.legajoEstudiante = legajoBuscado) and (comp.codigoHabilidad = codigoBuscado) then
      encontrado := true;
  end;

  if encontrado then
  begin
    Writeln('Competencia encontrada. Nivel: ', comp.nivelDominio);
    repeat
      Write('Ingrese Nuevo Nivel de dominio (1 a 5): ');
      Readln(comp.nivelDominio);
      if (comp.nivelDominio < 1) or (comp.nivelDominio > 5) then
        Writeln('Nivel invalido. Debe ser entre 1 y 5');
    until (comp.nivelDominio >= 1) and (comp.nivelDominio <= 5);

    Seek(arch, posicion);
    Write(arch, comp);
    Writeln('Nivel modificado');
  end
  else
    Writeln('Competencia no encontrada');
  Close(arch);
end;

procedure ListarCompetencias(var arch: TArchivoCompetencias);
var
  comp: TCompetencia;
  textoNivel: string;
begin
  Writeln('Lista de Competencias');
  Reset(arch);
  if EOF(arch) then
    Writeln('No hay competencias registradas')
  else
    while not EOF(arch) do
    begin
      Read(arch, comp);
      case comp.nivelDominio of
        1: textoNivel := 'Inicial';
        2: textoNivel := 'Basico';
        3: textoNivel := 'Intermedio';
        4: textoNivel := 'Avanzado';
        5: textoNivel := 'Experto';
      else
        textoNivel := 'Desconocido';
      end;
      Writeln('Legajo Estudiante: ', comp.legajoEstudiante, ' | Codigo Habilidad: ', comp.codigoHabilidad, ' | Nivel: ', comp.nivelDominio, ' (', textoNivel, ')');
      Writeln;
    end;
  Close(arch);
end;

begin
end.
