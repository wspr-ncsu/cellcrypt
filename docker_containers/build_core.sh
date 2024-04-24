set_ngic_env(){
NG_CORE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
RTE_SDK=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/dpdk
HYPERSCAN_DIR="$(pwd)/hyperscan-4.1.0"

export NG_CORE=$NG_CORE
export RTE_SDK=$RTE_SDK
export RTE_TARGET=x86_64-native-linuxapp-gcc

if [[ -d "$HYPERSCAN_DIR" ]]; then
  export HYPERSCANDIR=$HYPERSCAN_DIR
fi

# export HYPERSCANDIR=/home/ngic-rtc-tmopl/hyperscan-4.1.0
}


cd /c3po
chmod 777 install_builddeps.sh
./install_builddeps.sh
make clean
make -j `nproc`

cd /openmme
chmod 777 install_builddeps.sh
./install_builddeps.sh
make -C src/cmn && \
    make -C src/common && \
    make -C src/gtpV2Codec && \
    make -C src/stateMachineFwk && \
    make -C src/mmeGrpcProtos && \
    make -C src/mmeGrpcClient && \
    make -C src/cmn && \
    make -C src/mme-app && \
    make -C src/s1ap/s1apContextManager && \
    make -C src/s1ap && \
    make -C src/s11/cpp_utils/  && \
	make -C	src/s11 && \
	make -C	src/s6a



# export RTE_SDK=/ngic-rtc/dpdk
# export RTE_TARGET=x86_64-native-linuxapp-gcc




cd /ngic-rtc
# set_ngic_env
chmod 777 install_builddeps.sh
./install_builddeps.sh
chmod 777 setenv.sh
./setenv.sh
make -j `nproc`
