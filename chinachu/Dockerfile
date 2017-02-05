FROM ubuntu
#FROM alpine:3.5
MAINTAINER h-mineta <h-mineta@0nyx.net>

ARG REPOSITORY="git://github.com/Chinachu/Chinachu.git"
ARG BRANCH="master"

COPY ffmpeg_build.sh /usr/local/bin
#RUN echo 'Acquire::http { Proxy "http://localhost:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		bash \
		nodejs \
		coreutils \
		curl \
		procps \
		ca-certificates \
	\
    	&& curl -qsL https://deb.nodesource.com/setup_6.x | bash - \
	&& apt-get install -y \
		git \
		make \
		gcc \
		g++ \
		autoconf \
		automake \
		wget \
		sudo \
		tar \
		xz-utils \
		libc-dev \
		musl-dev \
#		eudev-dev \
		libevent-dev \
		# ffmpeg deps
		build-essential \
		cmake \
		git \
		libass-dev \
		libfreetype6-dev \
		libgpac-dev \
		libsdl1.2-dev \
		libtheora-dev \
   		libtool \
		libva-dev \
		libvdpau-dev \
		libvorbis-dev \
		libxcb1-dev \
		libxcb-shm0-dev \
		libxcb-xfixes0-dev \
		mercurial \
		pkg-config \
		texi2html \
		zlib1g-dev
RUN set -x \
	&& adduser --no-create-home --disabled-password --disabled-login --uid 99 --home /usr/local/chinachu chinachu \
	&& mkdir -p /usr/local/chinachu \
	&& git clone ${REPOSITORY} /usr/local/chinachu \
	&& chown -R chinachu:chinachu /usr/local/chinachu \
	&& cd /usr/local/chinachu \
	&& git checkout ${BRANCH} \
	&& echo 1 | sudo -u chinachu ./chinachu installer \
	&& ./chinachu service operator initscript | sudo -u chinachu tee /tmp/chinachu-operator \
	&& ./chinachu service wui initscript | sudo -u chinachu tee /tmp/chinachu-wui \
	&& sudo -u chinachu mkdir log \
	\
	# installation of ffmpeg (w/libx265)
	&& /usr/local/bin/ffmpeg_build.sh \
	\
	&& chown root. /tmp/chinachu-operator /tmp/chinachu-wui \
	&& chmod u+x /tmp/chinachu-operator /tmp/chinachu-wui \
	&& mv /tmp/chinachu-operator /etc/init.d/ \
	&& mv /tmp/chinachu-wui /etc/init.d/ \
	\
	# cleaning
	&& cd / \
#	&& apk del --purge .build-deps \
	&& rm -rf /tmp/* \
	&& rm -rf /var/cache/apk/*

	# forward request and error logs to docker log collector
	#&& ln -sf /dev/stdout /usr/local/chinachu/log/operator \
	#&& ln -sf /dev/stdout /usr/local/chinachu/log/scheduler \
	#&& ln -sf /dev/stdout /usr/local/chinachu/log/wui


WORKDIR /usr/local/chinachu
COPY services.sh /usr/local/bin
COPY config.sample.json /usr/local/chinachu/config.sample.json
COPY recCheck.js /usr/local/bin
COPY recCheck.sh /usr/local/bin
COPY slack_notification.sh /usr/local/bin

CMD ["/usr/local/bin/services.sh"]
EXPOSE 10772 20772 5353