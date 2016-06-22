#!/bin/bash
rm iplist.txt iprepetitions.txt ipsToBan.txt ipsFinal.txt
awk '{print $2}' ACCESS_LOG_CORREGIDO.log | sort | uniq -c -d > iplist.txt
awk '{print $1}' iplist.txt > iprepetitions.txt
touch ipsToBan.txt

while read line; do
	if [ $line -gt 1000 ]; then
		cat iplist.txt | grep "$line" >> ipsToBan.txt
	fi
done < iprepetitions.txt
awk '{print $2}' ipsToBan.txt > ipsFinal.txt
#Accedo a la carpeta de los sites y añado el .htaccess denegando IPs
echo "Order allow,deny
allow from all" > /var/www/html/practicaHost/.htaccess

while read line; do
	echo "deny from "$line"" >> /var/www/html/practicaHost/.htaccess
done < ipsFinal.txt

#Habilitar el uso del .htaccess desde en VirtualHost creado en la practica anterior
sed -i "6i\\\t<Directory /var/www/html/practicaHost>\n\tOptions Indexes FollowSymLinks Multiviews\n\tAllowOverride All\n\t</Directory>" /etc/apache2/sites-available/practicaHost.conf