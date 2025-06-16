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

COPY ./gentoo-20250615.tar.xz /var/db/repos/gentoo.tar.xz
RUN mkdir -p /var/db/repos/gentoo && \
	tar -xpf /var/db/repos/gentoo.tar.xz -C /var/db/repos/gentoo --strip-components=1 && \
	rm /var/db/repos/gentoo.tar.xz

RUN /scripts/write_flags.sh

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
