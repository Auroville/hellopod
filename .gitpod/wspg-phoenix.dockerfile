FROM gitpod/workspace-postgres

# this is the base erlang / elixir image. the project dockerfile references this in the FROM declaration

# set the version numbers by hand, and then name the resulting namespace as "wspg-phoenix:elixir-{$ELIXIR_VERSION}-OTP-{$OTP_VERSION}"

ENV OTP_VERSION="24.1" \
    REBAR3_VERSION="3.17.0"

LABEL org.opencontainers.image.version=$OTP_VERSION

USER gitpod

# We'll install the build dependencies for erlang-odbc along with the erlang
# build process:
RUN set -xe \
	&& OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
	&& OTP_DOWNLOAD_SHA256="63da2a7786bf49cf672f5008309ffc55d8827b9927a91a88d95328c445dd9d04" \
	&& runtimeDeps='libodbc1 \
			libsctp1 \
			libwxgtk3.0' \
	&& buildDeps='unixodbc-dev \
			libsctp-dev \
			libwxgtk3.0-gtk3-dev' \
	&& sudo apt-get update \
	&& sudo apt-get install -y --no-install-recommends $runtimeDeps \
	&& sudo apt-get install -y --no-install-recommends $buildDeps \
	&& sudo curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
	&& export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& sudo mkdir -vp $ERL_TOP \
	&& sudo tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
	&& sudo rm otp-src.tar.gz \
	&& ( cd $ERL_TOP \
	  && sudo ./otp_build autoconf \
	  && gnuArch="$(dpkg-architecture --query DEB_HOST_GNU_TYPE)" \
	  && sudo ./configure --build="$gnuArch" \
	  && sudo make -j$(nproc) \
	  && sudo make -j$(nproc) docs DOC_TARGETS=chunks \
	  && sudo make install install-docs DOC_TARGETS=chunks ) \
	&& sudo find /usr/local -name examples | sudo xargs rm -rf \
	&& sudo apt-get purge -y --auto-remove $buildDeps \
	&& sudo rm -rf $ERL_TOP /var/lib/apt/lists/*


# extra useful tools here: rebar & rebar3

ENV REBAR_VERSION="2.6.4"

RUN set -xe \
	&& REBAR_DOWNLOAD_URL="https://github.com/rebar/rebar/archive/${REBAR_VERSION}.tar.gz" \
	&& REBAR_DOWNLOAD_SHA256="577246bafa2eb2b2c3f1d0c157408650446884555bf87901508ce71d5cc0bd07" \
	&& sudo mkdir -p /usr/src/rebar-src \
	&& sudo curl -fSL -o rebar-src.tar.gz "$REBAR_DOWNLOAD_URL" \
	&& echo "$REBAR_DOWNLOAD_SHA256 rebar-src.tar.gz" | sha256sum -c - \
	&& sudo tar -xzf rebar-src.tar.gz -C /usr/src/rebar-src --strip-components=1 \
	&& sudo rm rebar-src.tar.gz \
	&& cd /usr/src/rebar-src \
	&& sudo ./bootstrap \
	&& sudo install -v ./rebar /usr/local/bin/ \
	&& sudo rm -rf /usr/src/rebar-src

RUN set -xe \
	&& REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" \
	&& REBAR3_DOWNLOAD_SHA256="4c7f33a342bcab498f9bf53cc0ee5b698d9598b8fa9ef6a14bcdf44d21945c27" \
	&& sudo mkdir -p /usr/src/rebar3-src \
	&& sudo curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
	&& sudo echo "$REBAR3_DOWNLOAD_SHA256 rebar3-src.tar.gz" | sha256sum -c - \
	&& sudo tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
	&& sudo rm rebar3-src.tar.gz \
	&& cd /usr/src/rebar3-src \
	&& sudo HOME=$PWD ./bootstrap \
	&& sudo install -v ./rebar3 /usr/local/bin/ \
	&& sudo rm -rf /usr/src/rebar3-src

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.12.3" \
	LANG=C.UTF-8

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="c5affa97defafa1fd89c81656464d61da8f76ccfec2ea80c8a528decd5cb04ad" \
	&& sudo curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& sudo mkdir -p /usr/local/src/elixir \
	&& sudo tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& sudo rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& sudo make install clean \
	&& sudo find /usr/local/src/elixir/ -type f -not -regex "/usr/local/src/elixir/lib/[^\/]*/lib.*" -exec rm -rf {} + \
	&& sudo find /usr/local/src/elixir/ -type d -depth -empty -delete

RUN sudo apt-get update && \
    sudo apt-get install -y postgresql-client && \
    sudo apt-get install -y inotify-tools && \
    sudo apt-get install -y nodejs && \
    sudo apt-get install -y curl && \
    sudo curl -L https://npmjs.org/install.sh | sudo sh && \
    sudo mix local.hex --force && \
    sudo mix archive.install hex phx_new --force && \
    sudo mix local.rebar --force

ONBUILD RUN mix do local.hex --force, local.rebar --force
