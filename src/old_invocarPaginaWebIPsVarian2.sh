#!/bin/bash
#OPCION ALTERNATIVA: MENOS ELEGANTE abriendo el navegador tor en si y abriendo la pagina
#Dspues de probar y probar con tor bajo consola (el otro scrip)... imposible... asi que al final no incrementa las visitas como si se hace con tor-browser
#aqui lo que hacemos es abrir el tor-browser con la url

#Veces q repeticmos el for
max=500
#tiempo de espera entre ejecucion y siguiente
wait=60
#url que invocamos
url='https://pisandoconfirmeza.wordpress.com/'


for (( i=0; i<$max; ++i ));
do
 /home/jortri/Escritorio/tor-browser_en-US/Browser/start-tor-browser https://pisandoconfirmeza.wordpress.com/ &
 sleep $wait
 #curiosamente tor es una version de firefox... se cierra al hacer un kill sobre el proceso firefox y sin preguntar... como si pasa si ponemos tor
 killall firefox
 sleep 2
done




