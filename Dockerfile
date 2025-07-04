### BUILD PREPARE
FROM gentoo/stage3 AS prepare

RUN mkdir /sources
RUN mkdir /scripts

COPY ./dependencies/dynamips /sources/dynamips
COPY ./dependencies/ubridge /sources/ubridge
COPY ./dependencies/vpcs /sources/vpcs
COPY ./dependencies/libcrypto.so.3 /libcrypto.so.3

COPY ./config.ini /config.ini
COPY ./requirements.txt /requirements.txt

COPY ./scripts/write_makeopts.sh /scripts/write_makeopts.sh
COPY ./scripts/build_dependencies.sh /scripts/build_dependencies.sh
COPY ./scripts/cleanup.sh /scripts/cleanup.sh
COPY ./CiscoKeyGen.py /CiscoKeyGen.py
COPY ./scripts/start.sh /start.sh

### EMERGE PREPARE
FROM prepare AS emerge_prepare

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

RUN emerge-webrsync

RUN rm -rf /etc/portage/make.conf
COPY ./portage/make.conf /etc/portage/make.conf
RUN /scripts/write_makeopts.sh

COPY ./portage/package.use/gns3 /etc/portage/package.use/gns3
COPY ./profile/package.provided /etc/portage/profile/package.provided

RUN <<-EOF
	set -e

	TARGET="/etc/portage/make.conf"
	ARCH=$(uname -m)

	case "$ARCH" in
		x86_64) 
			echo 'PORTAGE_BINHOST="https://joepasss.github.io/gentoo-bin/packages/amd64"' >> "$TARGET"
			;;
		arm64) 
			echo 'PORTAGE_BINHOST="https://joepasss.github.io/gentoo-bin/packages/aarch64"' >> "$TARGET"
			;;
		aarch64) 
			echo 'PORTAGE_BINHOST="https://joepasss.github.io/gentoo-bin/packages/aarch64"' >> "$TARGET"
			;;
		*) 
			echo "Unsupported architecture: $ARCH"
			exit 1 
			;;
	esac
EOF

RUN mkdir -p /run/lock
RUN getuto

### BUILD
FROM emerge_prepare AS deps

RUN emerge -gvq --oneshot \
	dev-build/cmake \
	dev-build/meson \
	dev-build/ninja

FROM deps AS build

RUN emerge -gvq \
	app-emulation/qemu \
	app-emulation/libvirt \
	net-libs/libpcap \
	app-containers/docker \
	net-misc/bridge-utils

WORKDIR /sources

RUN /scripts/build_dependencies.sh
RUN ln -s /libcrypto.so.3 /usr/lib/libcrypto.so.4

### CLEANUP
WORKDIR /data
RUN emerge -v --depclean
RUN /scripts/cleanup.sh

FROM build AS prod

CMD [ "/start.sh" ]
