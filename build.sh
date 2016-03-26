#!/bin/sh

# required: dev-embedded/linaro-toolchain-arm-linux-gnueabi-bin
TCDIR=/opt/linaro-toolchain-arm-linux-gnueabi-bin-5.3-2016.02/bin
TCPRF=arm-linux-gnueabi-
# required: dev-embedded/sourcery-codebench-lite-arm_linux-gnueabi-bin
#TCDIR=/opt/sourcery-codebench-lite-arm_linux-gnueabi-bin-r2795/bin
#TCPRF=arm-none-linux-gnueabi-

# cannot use neither AOSP nor Linaro tool-chain as they do not include libc due to error: ld: cannot find {crt0.o,crtbegin_dynamic.o,crtend_android.o}
# required: dev-embedded/aosp-android-toolchain-arm-eabi-bin
#TCDIR=/opt/aosp-android-toolchain-arm-eabi-bin-4.8/bin
#TCPRF=arm-eabi-
# required: dev-embedded/linaro-android-toolchain-eabi-bin
#TCDIR=/opt/linaro-android-toolchain-eabi-bin-4.9-2015.06/bin
#TCPRF=arm-eabi-
# required: dev-embedded/linaro-android-toolchain-armv7-bin
#TCDIR=/opt/linaro-android-toolchain-armv7-bin-5.2-2015.10/bin
#TCPRF=arm-linux-androideabi-

NUMCPUS=$(grep -c '^processor\s' /proc/cpuinfo)

export PATH="${PATH}:${TCDIR}"

[[ -e ./configure ]] || autoconf
[[ -e ./config.h.in ]] || autoheader

./configure \
	--build=x86_64-unknown-linux-gnu \
	--host=arm-eabi \
	--disable-zlib \
	--disable-largefile \
	--disable-loginfunc \
	--disable-shadow \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-pututline \
	--disable-pututxline \
	--disable-lastlog \
	"CC=${TCPRF}gcc" \
	"CFLAGS=-DANDROID -D__ANDROID__ -DSK_RELEASE -march=armv7-a -msoft-float -mfloat-abi=softfp -mfpu=neon -mthumb -mthumb-interwork -fpic -fno-short-enums -fgcse-after-reload -frename-registers -fuse-ld=bfd -DHAVE_BASENAME" \
	"LDFLAGS=-Xlinker -z -Xlinker muldefs -Bdynamic -Xlinker -dynamic-linker -Xlinker /system/bin/linker -Xlinker -z -Xlinker nocopyreloc -Xlinker --no-undefined" \
|| exit 1

make \
	"--jobs=${NUMCPUS}" "--load-average=${NUMCPUS}" \
	STATIC=1 \
	MULTI=1 \
	SCPPROGRESS=0 \
	PROGRAMS="dropbear dropbearkey scp dbclient" \
	"CC=${TCPRF}gcc" \
	"STRIP=${TCPRF}strip" \
	strip \
|| exit 2

exec \
file \
	dropbearmulti
