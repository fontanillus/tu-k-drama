-- ============================================================
-- EJERCICIOS SELECT
-- ============================================================


-- ============================================================
-- CONSULTAS SIMPLES
-- ============================================================

-- 1. Lista el nombre de todos los empleados que hay en la tabla empleado.
SELECT nombre
FROM empleado;

-- 2. Lista los nombres y los sueldos de todos los empleados de la tabla empleado.
SELECT nombre, sueldo
FROM empleado;

-- 3. Lista todas las columnas de la tabla empleado.
SELECT *
FROM empleado;

-- 4. Lista el nombre + apellido de todos los empleados,
-- su fecha de nacimiento y su fecha de contrato.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    fecha_nacimiento,
    fecha_contrato
FROM empleado;

-- 5. Lista el nombre de los empleados, su apellido, el sexo e hijos.
SELECT nombre, apellido, sexo, hijos
FROM empleado;

-- 6. Utiliza los siguientes alias para las columnas:
-- nombre del empleado, apellido del empleado, sexo, número de hijos.
SELECT
    nombre AS "nombre del empleado",
    apellido AS "apellido del empleado",
    sexo AS "sexo",
    hijos AS "número de hijos"
FROM empleado;

-- 7. Lista los nombres + apellidos y el sueldo de todos los empleados,
-- mostrando los apellidos en mayúsculas.
SELECT
    (nombre || ' ' || UPPER(apellido)) AS "nombre completo",
    sueldo
FROM empleado;

-- 8. Lista los nombres + apellidos y estado civil de todos los empleados,
-- mostrando el estado civil en minúscula.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    LOWER(estado_civil::text) AS "estado civil"
FROM empleado;

-- 9. Lista los nombres + apellidos de todos los empleados y calcula
-- las iniciales de los mismos.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    (LEFT(nombre, 1) || '.' || LEFT(apellido, 1) || '.') AS "iniciales"
FROM empleado;

-- 10. Lista nombre + apellido y calcula su edad
-- a partir de la fecha de nacimiento.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento))::int AS "edad"
FROM empleado;

-- 11. Lista los nombres + apellidos de todos los empleados
-- y calcula su antigüedad a partir de la fecha del contrato.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    AGE(CURRENT_DATE, fecha_contrato) AS "antigüedad"
FROM empleado;

-- 12. Lista sin repetir el código de los cargos (fk_cargo)
-- de la tabla empleado.
SELECT DISTINCT fk_cargo
FROM empleado;

-- 13. Lista la tabla empleado ordenada de forma ascendente
-- por apellido y nombre.
SELECT *
FROM empleado
ORDER BY apellido ASC, nombre ASC;

-- 14. Lista la tabla empleado ordenada de forma descendente por sueldo.
SELECT *
FROM empleado
ORDER BY sueldo DESC;

-- 15. Lista los empleados ordenados en primer lugar por el estado civil
-- de forma ascendente y en segundo lugar el sueldo de forma descendente.
SELECT nombre, apellido, estado_civil, sueldo
FROM empleado
ORDER BY estado_civil ASC, sueldo DESC;

-- 16. Devuelve una lista con las 3 primeras filas de la tabla cargo.
SELECT *
FROM cargo
LIMIT 3;

-- 17. Devuelve una lista con 2 filas a partir de la cuarta fila
-- de la tabla departamento. La cuarta fila también se debe incluir.
SELECT *
FROM departamento
LIMIT 2 OFFSET 3;

-- 18. Lista nombre + apellido y sueldo del empleado que menos cobra.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    sueldo
FROM empleado
ORDER BY sueldo ASC
LIMIT 1;

-- 19. Lista el nombre + apellido y la fecha de nacimiento
-- del empleado de mayor edad.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    fecha_nacimiento
FROM empleado
ORDER BY fecha_nacimiento ASC
LIMIT 1;

-- 20. Lista el nombre de todos los empleados
-- cuyo fk_departamento es igual a 2.
SELECT nombre
FROM empleado
WHERE fk_departamento = 2;

-- 21. Lista nombre + apellido de los empleados
-- que tienen un sueldo menor o igual a 15.000€.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE sueldo <= 15000;

-- 22. Lista nombre + apellido de los empleados
-- que tienen un sueldo mayor o igual a 40.000€.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE sueldo >= 40000;

-- 23. Lista nombre + apellido de los empleados
-- que no tienen un sueldo mayor o igual a 14.000€.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE NOT sueldo >= 14000;

-- 24. Lista todos los empleados que tengan un sueldo entre
-- 18.000€ y 25.000€. Sin utilizar el operador BETWEEN.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE sueldo >= 18000 AND sueldo <= 25000;

-- 25. Lista todos los empleados que tengan un sueldo entre
-- 16.000€ y 20.000€. Utilizando el operador BETWEEN.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE sueldo BETWEEN 16000 AND 20000;

-- 26. Lista los empleados que tengan un sueldo mayor que 15.000€
-- y que el fk_departamento sea igual a 6.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE sueldo > 15000 AND fk_departamento = 6;

-- 27. Lista los empleados donde el fk_cargo sea 1, 3 o 5.
-- Sin utilizar el operador IN.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE fk_cargo = 1
   OR fk_cargo = 3
   OR fk_cargo = 5;

-- 28. Lista todos los empleados donde el fk_cargo sea 1, 3 o 5.
-- Utilizando el operador IN.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE fk_cargo IN (1, 3, 5);

-- 29. Lista el nombre + apellido de los empleados y su mes de nacimiento.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    EXTRACT(MONTH FROM fecha_nacimiento) AS "mes nacimiento"
FROM empleado;

-- 30. Lista los empleados cuyo nombre empiece por la letra S.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE nombre LIKE 'S%';

-- 31. Lista los empleados cuyo nombre termine por la vocal e.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE nombre LIKE '%e';

-- 32. Lista los cargos que contengan el carácter r.
SELECT cargo
FROM cargo
WHERE cargo LIKE '%r%';

-- 33. Devuelve una lista de todos los empleados
-- que contienen la cadena ana en el nombre.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE nombre LIKE '%ana%';

-- 34. Haz una lista de todos los empleados que contienen la cadena ez
-- en el apellido y tienen un sueldo inferior a 21.500€.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE apellido LIKE '%ez%' AND sueldo < 21500;

-- 35. Lista los apellidos cuya longitud sea igual a 4 caracteres.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo"
FROM empleado
WHERE LENGTH(apellido) = 4;

-- 36. Lista el nombre y el sueldo de todos los empleados que tengan
-- un sueldo mayor o igual a 18.000€.
-- Ordena primero por sueldo descendente y después por apellido ascendente.
SELECT
    (nombre || ' ' || apellido) AS "nombre completo",
    sueldo
FROM empleado
WHERE sueldo >= 18000
ORDER BY sueldo DESC, apellido ASC;


-- ============================================================
-- CONSULTAS MULTITABLA
-- ============================================================

-- COMPOSICIÓN INTERNA (INNER JOIN)

-- 1. Lista el nombre y apellido de los empleados, su sueldo
-- y el nombre del departamento donde trabaja.
SELECT empleado.nombre,
       empleado.apellido,
       empleado.sueldo,
       departamento.departamento
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento;

-- 2. Lista el nombre y apellido de los empleados, su fecha de contrato
-- y el nombre del cargo. Ordena el resultado por la fecha de contrato.
SELECT empleado.nombre,
       empleado.apellido,
       fecha_contrato,
       cargo.cargo
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
ORDER BY fecha_contrato ASC;

-- 3. Lista el código del empleado, su nombre y apellido,
-- el código del departamento y el nombre del departamento
-- de los empleados que ganen más de 2000€.
SELECT pk_empleado,
       empleado.nombre,
       empleado.apellido,
       fk_departamento,
       departamento.departamento
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE sueldo > 2000;

-- 4. Indica el nombre, apellido y nombre del cargo
-- del empleado más joven.
SELECT empleado.nombre,
       empleado.apellido,
       cargo.cargo
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
ORDER BY fecha_nacimiento DESC
LIMIT 1;

-- 5. Indica el nombre, apellido y nombre del departamento
-- de los empleados que tengan hijos.
SELECT empleado.nombre,
       empleado.apellido,
       departamento.departamento
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE hijos > 0;

-- 6. Lista todos los datos de los empleados de Contabilidad.
SELECT *
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE departamento = 'Contabilidad';

-- 7. Lista el nombre y apellido del empleado, el nombre del cargo
-- y el departamento de los empleados solteros sin hijos.
SELECT empleado.nombre,
       empleado.apellido,
       cargo.cargo,
       departamento.departamento
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE estado_civil = 'Soltero'
AND hijos < 1;

-- 8. Lista los empleados de los departamentos de Compras y Ventas
-- sin utilizar el operador IN.
SELECT empleado.nombre,
       empleado.apellido,
       departamento.departamento
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE departamento = 'Compras'
OR departamento = 'Ventas';

-- 9. Lista los empleados de los departamentos de Compras y Ventas
-- utilizando el operador IN.
SELECT empleado.nombre,
       empleado.apellido,
       departamento.departamento
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE departamento IN ('Compras', 'Ventas');

-- 10. Lista el nombre y apellido del empleado, el nombre del cargo
-- y del departamento de aquellas personas que tienen más de 20 años
-- en la empresa. Ordena primero por departamento ascendente y después
-- por el tiempo trabajado descendente.
SELECT empleado.nombre,
       empleado.apellido,
       cargo.cargo,
       departamento.departamento
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_contrato)) > 20
ORDER BY departamento.departamento ASC,
         AGE(CURRENT_DATE, fecha_contrato) DESC;

-- 11. Lista nombre y apellido, edad, nombre del cargo y nombre
-- del departamento de los empleados Solteros, Divorciados o Viudos
-- que tengan más de un hijo.
SELECT empleado.nombre,
       empleado.apellido,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento)) AS edad,
       cargo.cargo,
       departamento.departamento
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
WHERE estado_civil IN ('Soltero', 'Divorciado', 'Viudo')
AND hijos > 1;


-- COMPOSICIÓN EXTERNA (LEFT JOIN, RIGHT JOIN)

-- 12. Lista todos los departamentos registrados junto con el código,
-- nombre y apellido del empleado que tiene cada uno de ellos.
-- Debe mostrar también los departamentos que no tienen empleados asociados.
SELECT departamento.departamento,
       pk_empleado,
       empleado.nombre,
       empleado.apellido
FROM departamento
LEFT JOIN empleado
    ON departamento.pk_departamento = empleado.fk_departamento;

-- 13. Lista todos los cargos registrados junto con el nombre y apellido
-- del empleado, la edad y el estado civil.
-- Debe mostrar también los cargos que no tienen empleados asociados.
SELECT cargo.cargo,
       empleado.nombre,
       empleado.apellido,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento)) AS edad,
       estado_civil
FROM cargo
LEFT JOIN empleado
    ON cargo.pk_cargo = empleado.fk_cargo;

-- 14. Lista los departamentos sin empleados asociados.
SELECT departamento.departamento
FROM departamento
LEFT JOIN empleado
    ON departamento.pk_departamento = empleado.fk_departamento
WHERE pk_empleado IS NULL;

-- 15. ¿Se puede asignar a un empleado un cargo que no esté registrado
-- en la tabla de cargos? Justifica tu respuesta.
-- No. Si el cargo no existe en la tabla cargo, no se puede relacionar
-- con el empleado, ya que fk_cargo debe hacer referencia a un pk_cargo
-- existente. Primero se deberá registrar el nuevo cargo en la tabla cargo
-- y después asignarlo al empleado mediante su clave foránea.


-- ============================================================
-- CONSULTAS AGRUPADAS
-- ============================================================

-- 1. Calcula el número total de empleados que hay en la tabla empleado.
SELECT COUNT(pk_empleado)
FROM empleado;

-- 2. Calcula el número total de departamentos que hay
-- en la tabla departamento.
SELECT COUNT(pk_departamento)
FROM departamento;

-- 3. Calcula la media de sueldo de todos los empleados.
SELECT AVG(sueldo)
FROM empleado;

-- 4. Indica quién es el empleado más joven.
SELECT nombre, apellido
FROM empleado
WHERE fecha_nacimiento = (
    SELECT MAX(fecha_nacimiento)
    FROM empleado
);

-- 5. Indica quién es el empleado menos joven.
SELECT nombre, apellido
FROM empleado
WHERE fecha_nacimiento = (
    SELECT MIN(fecha_nacimiento)
    FROM empleado
);

-- 6. Calcula el número total de empleados por estado civil.
SELECT COUNT(pk_empleado), estado_civil
FROM empleado
GROUP BY estado_civil;

-- 7. Muestra el número de empleados que han ingresado
-- cada año a la empresa.
SELECT COUNT(pk_empleado),
       EXTRACT(YEAR FROM fecha_contrato)
FROM empleado
GROUP BY EXTRACT(YEAR FROM fecha_contrato);

-- 8. Lista el nombre y el precio del producto más caro.
-- No se puede realizar esta consulta con la base de datos actual,
-- ya que no contiene información sobre productos ni precios.

-- 9. Calcula la suma de los salarios de los empleados por departamento.
SELECT departamento.departamento,
       SUM(empleado.sueldo)
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
GROUP BY departamento.departamento;

-- 10. Calcula la suma de los salarios de los empleados por sexo.
SELECT sexo, SUM(sueldo)
FROM empleado
GROUP BY sexo;

-- 11. Calcula el número de empleados que son Asistentes.
SELECT COUNT(pk_empleado)
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
WHERE cargo.cargo = 'Asistente';

-- 12. Calcula la media de hijos de los empleados
-- por sexo y estado civil.
-- NOTA: El resultado muestra 9 combinaciones y no 10 porque no existe
-- ningún empleado para una de las combinaciones posibles.
SELECT sexo,
       estado_civil,
       AVG(hijos)
FROM empleado
GROUP BY sexo, estado_civil;

-- 13. Calcula el sueldo más bajo de los Analistas.
SELECT MIN(sueldo)
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
WHERE cargo.cargo = 'Analista';

-- 14. Calcula el sueldo más alto de los Analistas.
SELECT MAX(sueldo)
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
WHERE cargo.cargo = 'Analista';

-- 15. Muestra el sueldo máximo, sueldo mínimo, sueldo promedio
-- y el número total de empleados por cargo.
SELECT MAX(sueldo),
       MIN(sueldo),
       AVG(sueldo),
       COUNT(pk_empleado),
       cargo.cargo
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
GROUP BY cargo.cargo;

-- 16. Muestra el sueldo máximo, sueldo mínimo, sueldo promedio
-- y el número total de empleados por departamento,
-- ordenando de forma descendente por el sueldo promedio.
SELECT departamento.departamento,
       MAX(sueldo),
       MIN(sueldo),
       AVG(sueldo),
       COUNT(pk_empleado)
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
GROUP BY departamento.departamento
ORDER BY AVG(sueldo) DESC;

-- 17. Muestra la edad máxima, edad mínima, edad promedio
-- y el número total de empleados de los departamentos
-- que tienen una edad promedio superior a los 45 años.
SELECT departamento.departamento,
       MAX(EXTRACT(YEAR FROM AGE(fecha_nacimiento))),
       MIN(EXTRACT(YEAR FROM AGE(fecha_nacimiento))),
       AVG(EXTRACT(YEAR FROM AGE(fecha_nacimiento))),
       COUNT(pk_empleado)
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
GROUP BY departamento.departamento
HAVING AVG(EXTRACT(YEAR FROM AGE(fecha_nacimiento))) > 45;

-- 18. Calcula el número de empleados
-- que tienen un sueldo mayor o igual a 1800€.
SELECT COUNT(pk_empleado)
FROM empleado
WHERE sueldo >= 1800;

-- 19. Calcula el número de empleados
-- que tienen una edad menor o igual a 28 años.
SELECT COUNT(pk_empleado)
FROM empleado
WHERE EXTRACT(YEAR FROM AGE(fecha_nacimiento)) <= 28;

-- 20. Lista los nombres de los departamentos cuyos empleados
-- tienen una edad promedio mayor o igual a 35 años.
SELECT departamento.departamento,
       AVG(EXTRACT(YEAR FROM AGE(fecha_nacimiento)))
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
GROUP BY departamento.departamento
HAVING AVG(EXTRACT(YEAR FROM AGE(fecha_nacimiento))) >= 35;

-- 21. Devuelve un listado con los nombres de los cargos
-- que tienen 5 o más empleados.
SELECT cargo.cargo
FROM empleado
INNER JOIN cargo
    ON empleado.fk_cargo = cargo.pk_cargo
GROUP BY cargo.cargo
HAVING COUNT(pk_empleado) >= 5;

-- 22. Devuelve un listado con los nombres de los departamentos
-- donde el promedio de edad sea superior a 40 años.
SELECT departamento.departamento,
       AVG(EXTRACT(YEAR FROM AGE(fecha_nacimiento)))
FROM empleado
INNER JOIN departamento
    ON empleado.fk_departamento = departamento.pk_departamento
GROUP BY departamento.departamento
HAVING AVG(EXTRACT(YEAR FROM AGE(fecha_nacimiento))) > 40;

-- 23. Muestra el número total de empleados que tiene cada departamento.
-- Debe incluir también los departamentos que no tienen ningún empleado.
-- Ordena el resultado descendentemente por el número de empleados.
SELECT d.departamento,
       COUNT(e.pk_empleado) AS numero_empleados
FROM departamento AS d
LEFT JOIN empleado AS e
    ON e.fk_departamento = d.pk_departamento
GROUP BY d.pk_departamento, d.departamento
ORDER BY numero_empleados DESC;

-- 24. Explica las diferencias entre las cláusulas WHERE y HAVING,
-- y cuándo utilizar cada una de ellas.
--
-- WHERE se utiliza para filtrar filas individuales antes de realizar
-- una agrupación. Se aplica a condiciones sobre los datos de las columnas.
--
-- HAVING se utiliza para filtrar los resultados obtenidos después
-- de agrupar los datos con GROUP BY. Se usa especialmente con funciones
-- de agregación como COUNT(), AVG(), SUM(), MAX() o MIN().
--
-- En resumen: WHERE filtra filas antes de agrupar y HAVING filtra
-- grupos después de agrupar.