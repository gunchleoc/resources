
if [ ! $# -eq 1 ];
then
	echo "You must give parameter telling which directory you want to use for installing website"
	exit 1
fi
INSTALL_DIR=$1

svn export svn://svn.gna.org/svn/wesnoth/branches/resources/tests.wesnoth.org/ $INSTALL_DIR

cd $INSTALL_DIR

CURRENT_PATH=`dirname $(readlink -f $0)`

# Get addodb lite
wget "http://downloads.sourceforge.net/adodblite/adodb_lite1.42.tar.gz?modtime=1168540426&big_mirror=0"
tar xf adodb_lite1.42.tar.gz
rm adodb_lite1.42.tar.gz

#get smarty
wget "http://www.smarty.net/do_download.php?download_file=Smarty-2.6.20.tar.gz"
tar xf Smarty-2.6.20.tar.gz
mv Smarty-2.6.20/* smarty_workdir/
rm -rf Smarty-2.6.20
rm Smarty-2.6.20.tar.gz


#copy configure from template
cp include/configuration.php.template include/configuration.php
cp include/settup.php.template include/settup.php
# Make files read only
chmod a-w include/configuration.php include/settup.php
chmod o-rx include/configuration.php include/settup.php

#Make svn checkout
svn co svn://svn.gna.org/svn/wesnoth/trunk/ trunk
#Use this instead of previous line if you want to copy existing svn tree
#cp -R /path/to/svntree trunk

#Configure scons build enviroment
cd trunk
scons default_targets=test build=debug extra_flags_debug="-march=native"
cd ..

# install crontab entry
crontab -l > crontab
echo " 16 *   *   *   *    $CURRENT_PATH/autotester/run_unit_tests.sh" >> crontab
crontab - < crontab
rm crontab

echo ""
echo "******* NOTES *****"
echo "You have to still do a few things before test are working"
echo " 1. Add database connection information"
echo "Edit include/settup.php file so that all relevant info to connect"
echo "to mysql server is present there. Remember to make it write-protected."
echo " 2. Configure website functionality"
echo "Edit include/configuration.php way that you want website function."
echo "Remember to make it write-protected."
echo " 3. Configure apache"
echo "edit paths in apache/test_website.conf and copy it to /etc/apache2/conf.d/"
echo " 4. run unit tests to settup database"
echo "autotester/run_unit_tests.sh"
