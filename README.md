#READ ME

Requisitos previos para la compilación:

    # Se debe tener instalado "bison" (yacc).
    # Se debe tener instalado "flex".
    # Se debe tener instalado "clang".

Compilación:

    $ bash com.sh <file.rdk>

    En caso de no querer que se borre el archivo .c generado por nuestro compilador, esto se puede hacer agregando el flag "-c" al final. Por ejemplo: $ bash com.sh <file.rdk> -c

    file.rdk es el archivo con el lenguaje "rdk" para el proyecto y debe ser del tipo "rdk".

Ejecución:

    $ ./out

    Los programas creados con el lenguaje "rdk" no aceptan parametros. 

Limpieza de archivos generados:

    $ make clean

    Este comando borrara el archivo ejecutable generado, y ademas el .c en caso de haber compilado con el flag "-c".