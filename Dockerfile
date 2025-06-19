### BUILD PREPARE
FROM gentoo/stage3 AS prepare

RUN mkdir /sources
RUN mkdir /scripts

COPY ./dependencies/dynamips /sources/dynamips
COPY ./dependencies/ubridge /sources/ubridge
COPY ./dependencies/vpcs /sources/vpcs
COPY ./dependencies/openssl-0.9.6.tar.gz /sources/openssl-0.9.6.tar.gz

COPY ./config.ini /config.ini
COPY ./requirements.txt /requirements.txt

COPY ./scripts/write_flags.sh /scripts/write_flags.sh
COPY ./scripts/build_dependencies.sh /scripts/build_dependencies.sh
COPY ./scripts/cleanup.sh /scripts/cleanup.sh
COPY ./scripts/start.sh /start.sh

### EMERGE PREPARE
FROM prepare AS emerge_prepare

ARG IS_PROD=false
ENV IS_PROD=${IS_PROD}

RUN emerge-webrsync

RUN /scripts/write_flags.sh
COPY ./package.use/gns3 /etc/portage/package.use/gns3
COPY ./profile/package.provided /etc/portage/profile/package.provided

RUN emerge -vq --oneshot \
	dev-lang/go-bootstrap \
	net-libs/gnutls

RUN getuto
RUN emerge -gvq dev-build/cmake

### QEMU BUILD
FROM emerge_prepare AS qemu_build

RUN emerge -gvq \
	app-emulation/qemu

### LIBVIRT BUILD
FROM qemu_build AS libvirt_build

RUN emerge -gvq \
	app-emulation/libvirt

### LIBPCAP BUILD
FROM libvirt_build AS libpcap_build

RUN emerge -gvq \
	net-libs/libpcap

### DOCKER BUILD
FROM libpcap_build AS docker_build

RUN emerge -gvq \
	app-containers/docker
  
### GNS DEPENDENCIES BUILD
FROM docker_build AS gns3_dependencies_build

RUN /scripts/build_dependencies.sh

### CLEANUP
FROM gns3_dependencies_build AS cleanup

RUN emerge -vq --depclean
RUN /scripts/cleanup.sh

### FINAL
FROM cleanup AS prod

CMD [ "/start.sh" ]
