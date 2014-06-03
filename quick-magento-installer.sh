#!/bin/sh
#---Config settings--------
MAG_DB_USER="root"
MAG_DB_PASS=""
MAG_DB_NAME="magento_db_test"
MAG_VERSION="magento-ce-1.8.1.0" #Check the latest version at https://github.com/netz98/n98-magerun
MAG_BASE_URL="http://site-name.localserver" #A vhost domain, shoud not be localhost AND do not use '_'
MAG_ADMIN_USER="admin"
MAG_ADMIN_PASSWORD="magento123"

#Should not change if you have no idea
MR_PHAR_URL="https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar"
MR_PHAR_FILE="n98-magerun.phar"
MAG_EXTENSIONS=("MagnetoDebug")
#---END Config settings--------

#Install n98-magerun
echo "Downloading Magerun Phar..."
if [[ ! -f "$MR_PHAR_FILE" ]]; then
    if [ `builtin type -p curl` ]; then 
		curl -o n98-magerun.phar $MR_PHAR_URL;
	elif [ `builtin type -p wget` ]; then 
		wget -o n98-magerun.phar $MR_PHAR_URL; 
	else
		echo "'curl' or 'wget' commands are not available. Please install one of them before going further";
		exit 0
	fi
fi
echo "Download done!!!"

#Install Magento
echo "Magento installing..."
read -p "Are you sure to use config settings in the script? Continue (y/n)?" prompt
if [[ $prompt == "y" || $prompt == "Y" ]]; then
	php n98-magerun.phar install \
		--dbHost="localhost" \
		--dbUser=$MAG_DB_USER \
		--dbPass=$MAG_DB_PASS \
		--dbName=$MAG_DB_NAME \
		--installSampleData=yes \
		--useDefaultConfigParams=yes \
		--magentoVersionByName=$MAG_VERSION \
		--installationFolder="." \
		--baseUrl=$MAG_BASE_URL
	
	php n98-magerun.phar admin:user:change-password $MAG_ADMIN_USER $MAG_ADMIN_PASSWORD #change Admin default password
	
	
	#install extensions
	for i in ${MAG_EXTENSIONS[@]}; do
		mage install http://connect20.magentocommerce.com/community/ $i
	done	
	echo "Done"
else
	echo "Installation is stopped!"
fi