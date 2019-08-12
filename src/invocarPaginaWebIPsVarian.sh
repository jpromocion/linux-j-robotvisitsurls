#!/bin/bash
 ################################
 # Autor: jpromocion (https://github.com/jpromocion/linux-j-robotvisitsurls)
 # License: GNU General Public License v3.0
 # invocarPaginaWebIPsVarian.sh
 #
#Basado en tor privoxy
#https://medium.com/the-sysadmin/using-tor-for-your-shell-script-fee9d8bdef5c  
#https://tor.stackexchange.com/questions/10330/failed-to-curl-https-url-from-privoxy-over-tor  
#http://tuxdiary.com/2015/04/10/tor-privoxy/
#
#Requiere:
#  -Tener instalado tor
#  -Tener instalado PhantomJs
#
#Previamente debe:
#  1) Si esta arracando el servicio de tor (puerto estandar 9050) pararlo -> sudos service tor stop
#  2) Debe arrancarse en otra consola el servidor tor con "tor -f my-torrc" donde my-torrc es el fichero config q esta en esta ruta. Y dejarse abierto esto ejecutandose. 
#   Abre el servicio tor en 9051 y con la configuracion que indica el refresco de las ip. cada poco. El hash es para la pass 1234, se obtiene con "tor --hash-password 1234"
#   Se utiliza el tor como si fuera el navegador, para pasar las invocaciones URL de la pagina...pero abierto como un proxy por detras en localhost puerto 9051... sin necesidad de abriri el navegador web
#  3) En otra consola ejecutamos este script
#
# CAMBIAR:
#   -url: deben configurarse con la ruta base de la pagina sobre la que visitar paginas
#   -subdominio: subdominio con subrutas a paginas distintas de ese domicio preparado para que cada vez visite algo distinto de ese mismo dominio aleatoriamente.
#
#FALLIDO LA PRIMARA VEX (con curl o wget): Aunque hace lo que debe.... el contador de visitas no se incrementa... y si entramos con tor como navegador... si que lo hace... no he conseguido saber porque
#¿POR QUE? http://stackoverflow.com/questions/33321702/how-to-visit-not-download-a-page-using-curl-or-wget
#Como ai dice curl o wget... obtiene la pagina, pero no renderizan la html y por tanto no ejecutan javascript de la pagina....si el incrementar el contador
#esta hecho con javascript... por eso no funciona (poruqe la IP si está variando) -> solucion invocarla como hay dice con PhantomJs... que si renderiza
#esa invocacuin en script
#https://github.com/ariya/phantomjs/issues/13840
#ESTO SI FUNCIONA!!!!! -> se necesita instalar PhantomJs
 ################################




#Veces q repeticmos el for
max=1000
#tiempo de espera base entre ejecucion y siguiente
wait=3
#url que invocamos
url='https://pisandoconfirmeza.wordpress.com/'

#Array de subdominios
subdominio[0]=""
subdominio[1]="2017/05/19/que-me-pongo-para-un-evento/"
subdominio[2]="2017/04/02/temporada-de-bailarinas/"
subdominio[3]="2017/03/21/metalizados/"
subdominio[4]="2017/01/20/tendencias-primaverales/"
subdominio[5]="2016/12/28/fin-de-ano-2016-nos-vamos-de-fiesta/"
subdominio[6]="2016/12/09/botas-calcetin/"
subdominio[7]="2016/11/06/melissa/"
subdominio[8]="2016/10/12/estilo-militar/"
subdominio[9]="2016/10/02/de-compras-por-zara/"
subdominio[10]="2017/06/04/zapatillas-camping/"



for (( i=0; i<$max; ++i ));
do
 #Primero establecemos conexion a tor -> indicando asigne como una nueva sesion de navegacion
 (echo authenticate '"1234"'; echo signal newnym; echo quit) | nc 127.0.0.1 9151
 
 #Esto es para mostrar la IP que tenemos utilizando la web vermiip y ver como va cambiando
 IP=`curl -s --socks5-hostname 127.0.0.1:9050 http://www.vermiip.es/|grep "Tu IP p&uacute;blica es:"|awk -F" " '{print $5}'|awk -F"<" '{print $1}'`
 echo "Your new IP address is: $IP" 
 #Tambien podriamos hacerlo en phantomjs para ver la ip... aunq en este caso no se puede hacer en una sola fila
 #phantomjs --proxy=127.0.0.1:9050 --proxy-type=socks5 vistarPaginaWeb.js http://www.vermiip.es/ > pagina.html
 #cat pagina.html|grep "Tu IP pública es:"|awk -F" " '{print $5}'|awk -F"<" '{print $1}'
 
 #Utilizaremos subdominios aleatoriamente
 valores=${#subdominio[*]}
 valorMaxIndi=$((valores - 1))
 subdomiAleato=`echo $(($RANDOM%$valorMaxIndi))`
 nombresubdomiAleato=${subdominio[$subdomiAleato]}
 urlFinal="$url$nombresubdomiAleato"
 echo "Url: $urlFinal"
 
 #Visitar la pagina renderizandola con phantomjs -> aunq aparezca un error por pantalla se debe a que alga de la pagina no se pudo cargar... pero la visita se realizo
 #Es necesario ejecutarlo pasandolo pro el proxy 9050 en localhost donde hemos levantado el server tor
 phantomjs --proxy=127.0.0.1:9050 --proxy-type=socks5 vistarPaginaWeb.js "$urlFinal" >/dev/null 2>/dev/null
 echo "Web visitada"
  
 #No funcionan porque no ejecutan Jscript
 #curl --socks5-hostname 127.0.0.1:9050 "$url" >/dev/null 2>&1
 #curl --socks5-hostname 127.0.0.1:9050 "$url"
 #wget -O - https://pisandoconfirmeza.wordpress.com/
 
 #Esperamos un tiempo variable
 esperaAleato=`echo $(($RANDOM%10))`
 esperafinal=$((wait + esperaAleato))
 #NOTA: reiniciar el servicio de tor, puede funcionar para utilizar el tor normal del 9050, y forzar a lo bestia
 #que coga una ip nueva en cada intento, dado que al reiniciarlo refresca el circuito.
 #En principio no es necesario, se deja comentado
 #sudo service tor restart
 sleep $esperafinal

done






