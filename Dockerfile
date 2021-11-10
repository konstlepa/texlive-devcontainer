ARG VARIANT=3.14

FROM assignuser/chktex-alpine:v0.1.1 AS chktex

FROM alpine:${VARIANT} AS texlive

COPY texlive-profile.txt /tmp/

RUN apk update
RUN apk add --no-cache xz curl perl tar fontconfig-dev
RUN curl -L -O http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN mkdir /tmp/install-tl
RUN tar -xzf install-tl-unx.tar.gz -C /tmp/install-tl --strip-components=1
RUN /tmp/install-tl/install-tl --profile=/tmp/texlive-profile.txt

FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-${VARIANT} AS base_image

ENV PATH=/usr/local/texlive/bin/x86_64-linuxmusl:/usr/local/bin:$PATH

COPY --from=chktex  /usr/bin/chktex /usr/local/bin/
COPY --from=texlive /usr/local/texlive/ /usr/local/texlive/

RUN apk update \
	&& apk add --no-cache perl-utils make \
		perl-app-cpanminus \
		perl-log-dispatch \
		perl-namespace-autoclean \
		perl-specio \
		perl-unicode-linebreak \
	&& cpanm -n App::cpanminus \
	&& cpanm -n File::HomeDir \
	&& cpanm -n Params::ValidationCompiler \
	&& cpanm -n YAML::Tiny \
	&& cpanm -n Unicode::GCString \
	&& apk del make \
	&& tlmgr update --self \
	&& tlmgr install \
		latexindent \
		latex-bin \
		latexmk \
		amscls \
		amsmath \
		kvoptions \
		ltxcmds \
		kvsetkeys \
		infwarerr \
		kvdefinekeys \
		pdftexcmds \
		etexcmds \
		auxhook \
		babel-english \
	&& texhash