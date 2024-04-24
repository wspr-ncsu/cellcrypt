# free5GC
git clone --recursive https://github.com/free5gc/free5gc.git

# Magma
git clone --recursive https://github.com/magma/magma.git

# Open5gs
git clone --recursive https://github.com/open5gs/open5gs.git


# SD-Core
declare -a omec_nfs=("amf" "ausf" "c3po" "nrf" "nssf" "pcf" "pfcp" "sctplb" "smf" "spgw" "udm" "udr" "upf")
mkdir sd-core
cd sd-core
for nf in ${omec_nfs[@]}; do
	git clone --recursive https://github.com/omec-project/${nf}.git
done
cd ..
# OAI

declare -a oai_nfs=("amf" "ausf" "fed" "nef" "nrf" "nssf" "smf" "udm" "udr" "upf-vpp")


mkdir OAI 
cd OAI
for nf in ${oai_nfs[@]}; do
	git clone --recursive https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-${nf}.git
done
cd ..
