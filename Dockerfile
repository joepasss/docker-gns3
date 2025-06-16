FROM gentoo/stage3 AS deps

RUN mkdir /sources
RUN mkdir /scripts

COPY ./dependencies/dynamips /sources/dynamips
COPY ./dependencies/ubridge /sources/ubridge
COPY ./dependencies/vpcs /sources/vpcs

COPY ./config.ini /config.ini
COPY ./requirements.txt /requirements.txt

COPY ./scripts/write_flags.sh /scripts/write_flags.sh
COPY ./scripts/build_dependencies.sh /scripts/build_dependencies.sh
COPY ./scripts/cleanup.sh /scripts/cleanup.sh
COPY ./scripts/start.sh /start.sh

RUN emerge-webrsync

RUN /scripts/write_flags.sh
COPY ./package.use/gns3 /etc/portage/package.use/gns3
COPY ./profile/package.provided /etc/portage/profile/package.provided

RUN emerge -vq --oneshot dev-lang/go-bootstrap
RUN emerge -vq \
	app-emulation/qemu \
	app-emulation/libvirt \
	app-containers/docker \
	net-libs/libpcap

RUN emerge -vq --depclean

RUN /scripts/build_dependencies.sh
RUN /scripts/cleanup.sh

CMD [ "/bin/bash" ]
