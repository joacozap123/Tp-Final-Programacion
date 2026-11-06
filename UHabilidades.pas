unit UHabilidades;

interface

type
  THabilidad = record
    codigo: string[10];
    nombre: string[40];
    categoria: string[30];
  end;

  TArchivoHabilidades = file of THabilidad;

procedure CrearArchivoHabilidades(var arch: TArchivoHabilidades);
procedure AltaHabilidad(var arch: TArchivoHabilidades);
procedure BajaHabilidad(var arch: TArchivoHabilidades);
procedure ModificacionHabilidad(var arch: TArchivoHabilidades);
procedure ListarHabilidades(var arch: TArchivoHabilidades);
function BuscarHabilidad(var arch: TArchivoHabilidades; codigoBuscado: string; var hab: THabilidad): boolean;

implementation

procedure CrearArchivoHabilidades(var arch: TArchivoHabilidades);
begin
  Assign(arch, 'habilidades.dat');
  Reset(arch);
  if IOResult <> 0 then
    Rewrite(arch)
  else
    Close(arch);
end;

function BuscarHabilidad(var arch: TArchivoHabilidades; codigoBuscado: string; var hab: THabilidad): boolean;
var
  encontrado: boolean;
begin
  encontrado := false;
  Reset(arch);
  while not EOF(arch) and not encontrado do
  begin
    Read(arch, hab);
    if hab.codigo = codigoBuscado then
      encontrado := true;
  end;
  Close(arch);
  BuscarHabilidad := encontrado;
end;

procedure AltaHabilidad(var arch: TArchivoHabilidades);
var
  habNueva, habAux: THabilidad;
begin
  Writeln('Alta de habilidad');
  Write('Ingrese Codigo de habilidad (max 10): ');
  Readln(habNueva.codigo);

  if BuscarHabilidad(arch, habNueva.codigo, habAux) then
  begin
    Writeln('Ya existe una habilidad con ese codigo');
    exit;
  end;

  Write('Ingrese Nombre de la habilidad: ');
  Readln(habNueva.nombre);
  Write('Ingrese Categoria: ');
  Readln(habNueva.categoria);

  Reset(arch);
  Seek(arch, FileSize(arch));
  Write(arch, habNueva);
  Close(arch);
  Writeln('Habilidad registrada');
end;

procedure BajaHabilidad(var arch: TArchivoHabilidades);
var
  codigoBuscado: string[10];
  archTemp: TArchivoHabilidades;
  hab: THabilidad;
  encontrado: boolean;
begin
  Writeln('Eliminar habilidd');
  Write('Ingrese Codigo de la habilidad a eliminar: ');
  Readln(codigoBuscado);

  encontrado := false;
  Assign(archTemp, 'temp_hab.dat');
  Rewrite(archTemp);
  Reset(arch);

  while not EOF(arch) do
  begin
    Read(arch, hab);
    if hab.codigo = codigoBuscado then
      encontrado := true
    else
      Write(archTemp, hab);
  end;

  Close(arch);
  Close(archTemp);

  if encontrado then
  begin
    Erase(arch);
    Rename(archTemp, 'habilidades.dat');
    Writeln('Habilidad eliminada');
  end
  else
  begin
    Erase(archTemp);
    Writeln('Habilidad no encontrada');
  end;
end;

procedure ModificacionHabilidad(var arch: TArchivoHabilidades);
var
  codigoBuscado: string[10];
  hab: THabilidad;
  encontrado: boolean;
  posicion: longint;
begin
  Writeln('Modificar habilidad');
  Write('Ingrese Codigo de la habilidad a modificar: ');
  Readln(codigoBuscado);

  Reset(arch);
  encontrado := false;
  posicion := 0;
  while not EOF(arch) and not encontrado do
  begin
    posicion := FilePos(arch);
    Read(arch, hab);
    if hab.codigo = codigoBuscado then
      encontrado := true;
  end;

  if encontrado then
  begin
    Writeln('Habilidad encontrada: ', hab.nombre);
    Write('Nuevo Nombre: '); Readln(hab.nombre);
    Write('Nueva Categoria: '); Readln(hab.categoria);

    Seek(arch, posicion);
    Write(arch, hab);
    Writeln('Habilidad modificada');
  end
  else
    Writeln('Habilidad no encontrada');
  Close(arch);
end;

procedure ListarHabilidades(var arch: TArchivoHabilidades);
var
  hab: THabilidad;
begin
  Writeln('Lista de habilidades');
  Reset(arch);
  if EOF(arch) then
    Writeln('No hay habilidades registradas')
  else
    while not EOF(arch) do
    begin
      Read(arch, hab);
      Writeln('Codigo: ', hab.codigo, ' | Nombre: ', hab.nombre, ' | Categoria: ', hab.categoria);
      Writeln('--------------------------------------------------');
    end;
  Close(arch);
end;

begin
end.
