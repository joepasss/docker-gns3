FROM gentoo/stage3 AS prepare

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

FROM prepare AS emerge_prepare

RUN emerge-webrsync

RUN /scripts/write_flags.sh
COPY ./package.use/gns3 /etc/portage/package.use/gns3
COPY ./profile/package.provided /etc/portage/profile/package.provided

RUN emerge -vq --oneshot dev-lang/go-bootstrap

FROM emerge_prepare AS qemu_build

RUN emerge -vq \
	app-emulation/qemu \
	app-emulation/libvirt

FROM qemu_build AS docker_build

RUN emerge -vq \
	app-containers/docker \
	net-libs/libpcap

FROM qemu_build AS gns3_dependencies_build

RUN /scripts/build_dependencies.sh

FROM gns3_dependencies_build AS cleanup

RUN emerge -vq --depclean
RUN /scripts/cleanup.sh

FROM cleanup AS prod

CMD [ "/start.sh" ]
