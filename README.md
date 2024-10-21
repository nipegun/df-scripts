# df-scripts

Los "df-scripts" son scripts en bash que he ido creado para paliar necesidades que han ido surgiendo en el dia a dia de administrar Debian como distribución forense.

Si bien están pensados para ser ejecutados en Debian es probable que puedan ser ejecutados sin errores en derivados como Ubuntu, Mint u otros.

# INSTALACIÓN

Para instalar los df-scripts en la ubicación aconsejada sigue las instrucciones de este artículo: http://hacks4geeks.com/df-scripts

## ACLARACIÓN!!
Los scripts de dentro de las carpetas "PostInst" y "SoftInst" están diseñados (por ahora) para ser ejecutados una ÚNICA vez. Si la ejecución falla o es interrumpida, NO se debería volver a ejecutar el mismo script y habría que recurrir a una revisión manual de lo que pudo haber fallado y de las cosas que podrían haber sido modificadas de forma errónea, para corregirlas. En esos casos aconsejo la re-instalación de Debian, la posterior re-sincronización con este repositorio y la re-ejecución del paquete que pudo haber fallado.
