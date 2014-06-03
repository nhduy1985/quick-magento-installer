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
		curl -o $MR_PHAR_FILE $MR_PHAR_URL;
	elif [ `builtin type -p wget` ]; then 
		wget -o $MR_PHAR_FILE $MR_PHAR_URL; 
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
	php $MR_PHAR_FILE install \
		--dbHost="localhost" \
		--dbUser=$MAG_DB_USER \
		--dbPass=$MAG_DB_PASS \
		--dbName=$MAG_DB_NAME \
		--installSampleData=yes \
		--useDefaultConfigParams=yes \
		--magentoVersionByName=$MAG_VERSION \
		--installationFolder="." \
		--baseUrl=$MAG_BASE_URL			
	
	#install extensions
	echo "Install extensions..." 
	for i in ${MAG_EXTENSIONS[@]}; do
		mage install http://connect20.magentocommerce.com/community/ $i
	done		
	
	#Post-install
	echo "Post install setup"
	php $MR_PHAR_FILE admin:user:change-password $MAG_ADMIN_USER $MAG_ADMIN_PASSWORD #change Admin default password
	php $MR_PHAR_FILE cache:disable #disable cache for development
	php $MR_PHAR_FILE dev:log --on --global #turn on log
	php $MR_PHAR_FILE dev:log:db --on #turn on db log
	
	echo "Installation completed !!!"
else
	echo "Installation is stopped!"
fi