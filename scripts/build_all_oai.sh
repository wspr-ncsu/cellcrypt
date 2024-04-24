declare -a omec_nfs=("amf" "ausf" "fed" "nrf" "nssf" "nef" "smf" "udm" "udr" "upf-vpp")
base=`pwd`
for NF in $omec_nfs; do
	TARGET="oai-cn5g-$NF"
	TARGET_SCRIPT="./build_$NF"
	if [ $NF == "upf-vpp" ]; then
	    TARGET_SCRIPT="./build_vpp_upf"	
	fi
	command cd $TARGET/build/scripts 
	command yes | $TARGET_SCRIPT "-I"
	command cd $base
done;
