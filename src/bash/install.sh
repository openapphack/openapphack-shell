#!/bin/bash

# Global variables
#OAH_INSTALLER_SERVICE=https://openapphack.github.io/oah-installer/
OAH_INSTALLER_SERVICE="@OAH_INSTALLER_SERVICE@"
OAH_ENV_META_DATA_SERVICE="@OAH_ENV_META_DATA_SERVICE@"
#OAH_VERSION=0.0.1
OAH_VERSION="@OAH_VERSION@"
OAH_DIR="$HOME/.oah"

# Local variables
oah_bin_folder="${OAH_DIR}/bin"
oah_src_folder="${OAH_DIR}/src"
oah_tmp_folder="${OAH_DIR}/tmp"
oah_stage_folder="${oah_tmp_folder}/stage"
oah_zip_file="${oah_tmp_folder}/res-${OAH_VERSION}.zip"
oah_etc_folder="${OAH_DIR}/etc"
oah_var_folder="${OAH_DIR}/var"
oah_vm_folder="${OAH_DIR}/data/vm"
oah_dotvms_folder="${OAH_DIR}/.vms"
oah_config_file="${oah_etc_folder}/config"
oah_bash_profile="${HOME}/.bash_profile"
oah_profile="${HOME}/.profile"
oah_bashrc="${HOME}/.bashrc"
oah_zshrc="${HOME}/.zshrc"
oah_platform=$(uname)

oah_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR OAH TO WORK!!!
export OAH_DIR="$HOME/.oah"
[[ -s "${OAH_DIR}/bin/oah-init.sh" ]] && source "${OAH_DIR}/bin/oah-init.sh"
EOF
)

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
solaris=false;
freebsd=false;
case "$(uname)" in
    CYGWIN*)
        cygwin=true
        ;;
    Darwin*)
        darwin=true
        ;;
    SunOS*)
        solaris=true
        ;;
    FreeBSD*)
        freebsd=true
esac

echo '                                                                     '
echo 'Thanks for using     OpenAppHack Cli                                 '
echo '                                                                     '
echo '                                                                     '
echo '                                       Will now attempt installing...'
echo '                                                                     '


# Sanity checks

echo "Looking for a previous installation of OAH..."
if [ -d "${OAH_DIR}" ]; then
	echo "OAH found."
	echo ""
	echo "======================================================================================================"
	echo " You already have OAH installed."
	echo " OAH was found at:"
	echo ""
	echo "    ${OAH_DIR}"
	echo ""
	echo " Please consider running the following if you need to upgrade."
	echo ""
	echo "    $ app selfupdate"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for git..."
if [ -z $(which git) ]; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install git on your system using your favourite package manager."
	echo ""
	echo " Restart after installing git."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for vagrant..."
if [ -z $(which vagrant) ]; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install vagrant on your system ."
	echo ""
	echo " OAH uses vagrant extensively."
	echo ""
	echo " Restart after installing vagrant."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for unzip..."
if [ -z $(which unzip) ]; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install unzip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing unzip."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for curl..."
if [ -z $(which curl) ]; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " OAH uses curl for crucial interactions with it's backend server."
	echo ""
	echo " Restart after installing curl."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for sed..."
if [ -z $(which sed) ]; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install sed on your system using your favourite package manager."
	echo ""
	echo " OAH uses sed extensively."
	echo ""
	echo " Restart after installing sed."
	echo "======================================================================================================"
	echo ""
	exit 0
fi




echo "Installing oah scripts..."


# Create directory structure

echo "Create distribution directories..."
mkdir -p "${oah_bin_folder}"
mkdir -p "${oah_src_folder}"
mkdir -p "${oah_tmp_folder}"
mkdir -p "${oah_stage_folder}"
mkdir -p "${oah_ext_folder}"
mkdir -p "${oah_etc_folder}"
mkdir -p "${oah_var_folder}"
mkdir -p "${oah_vm_folder}"
mkdir -p "${oah_dotvms_folder}"

echo "Create candidate directories..."

OAH_CANDIDATES_CSV=$(curl -s "${OAH_INSTALLER_SERVICE}/candidates")
echo "$OAH_CANDIDATES_CSV" > "${OAH_DIR}/var/candidates"

echo "$OAH_VERSION" > "${OAH_DIR}/var/version"

# convert csv to array
OLD_IFS="$IFS"
IFS=","
OAH_CANDIDATES=(${OAH_CANDIDATES_CSV})
IFS="$OLD_IFS"

for (( i=0; i <= ${#OAH_CANDIDATES}; i++ )); do
	# Eliminate empty entries due to incompatibility
	if [[ -n ${OAH_CANDIDATES[${i}]} ]]; then
		CANDIDATE_NAME="${OAH_CANDIDATES[${i}]}"
		mkdir -p "${OAH_DIR}/.vms/${CANDIDATE_NAME}"
		echo "Created for ${CANDIDATE_NAME}: ${OAH_DIR}/.vms/${CANDIDATE_NAME}"
		unset CANDIDATE_NAME
	fi
done

echo "Prime the config file..."
touch "${oah_config_file}"
echo "oah_auto_answer=false" >> "${oah_config_file}"
echo "oah_auto_selfupdate=false" >> "${oah_config_file}"
echo "oah_insecure_ssl=false" >> "${oah_config_file}"

echo "Download script archive..."
#https://github.com/WiproOpenSourcePractice/oah/raw/gh-pages/
curl -s "${OAH_INSTALLER_SERVICE}/res/oah-cli-scripts.zip" > "${oah_zip_file}"



echo "Extract script archive..."
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	oah_zip_file=$(cygpath -w "${oah_zip_file}")
	oah_stage_folder=$(cygpath -w "${oah_stage_folder}")
fi
unzip -qo "${oah_zip_file}" -d "${oah_stage_folder}"

echo "Install scripts..."
mv "${oah_stage_folder}/oah-init.sh" "${oah_bin_folder}"
mv "${oah_stage_folder}"/oah-* "${oah_src_folder}"

echo "Attempt update of bash profiles..."
if [ ! -f "${oah_bash_profile}" -a ! -f "${oah_profile}" ]; then
	echo "#!/bin/bash" > "${oah_bash_profile}"
	echo "${oah_init_snippet}" >> "${oah_bash_profile}"
	echo "Created and initialised ${oah_bash_profile}"
else
	if [ -f "${oah_bash_profile}" ]; then
		if [[ -z `grep 'oah-init.sh' "${oah_bash_profile}"` ]]; then
			echo -e "\n${oah_init_snippet}" >> "${oah_bash_profile}"
			echo "Updated existing ${oah_bash_profile}"
		fi
	fi

	if [ -f "${oah_profile}" ]; then
		if [[ -z `grep 'oah-init.sh' "${oah_profile}"` ]]; then
			echo -e "\n${oah_init_snippet}" >> "${oah_profile}"
			echo "Updated existing ${oah_profile}"
		fi
	fi
fi

if [ ! -f "${oah_bashrc}" ]; then
	echo "#!/bin/bash" > "${oah_bashrc}"
	echo "${oah_init_snippet}" >> "${oah_bashrc}"
	echo "Created and initialised ${oah_bashrc}"
else
	if [[ -z `grep 'oah-init.sh' "${oah_bashrc}"` ]]; then
		echo -e "\n${oah_init_snippet}" >> "${oah_bashrc}"
		echo "Updated existing ${oah_bashrc}"
	fi
fi


echo -e "\n\n\nAll done!\n\n"

echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${OAH_DIR}/bin/oah-init.sh\""
echo ""
echo "Then issue the following command:"
echo ""
echo "    oah help"
echo ""
echo "Enjoy!!!"
