FROM debian:bookworm

ARG herdr_app_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG HERDR_APP_RELEASE

RUN mkdir -p /output/DEBIAN /output/usr/bin /output/usr/share/doc/herdr-app \
    /output/usr/share/applications /output/usr/share/icons/hicolor/scalable/apps

# Upstream's tarball, extracted by build_debian.sh. The binary goes alone into
# /usr/bin: herdr-app updates itself only when its icon sits next to it (an
# install from upstream's script), so apt stays in charge of updates.
COPY ${HERDR_APP_RELEASE}/herdr-app /output/usr/bin/herdr-app
RUN chmod 755 /output/usr/bin/herdr-app
COPY ${HERDR_APP_RELEASE}/herdr-app.svg /output/usr/share/icons/hicolor/scalable/apps/herdr-app.svg
COPY ${HERDR_APP_RELEASE}/THIRD-PARTY-NOTICES /output/usr/share/doc/herdr-app/
RUN gzip -9n /output/usr/share/doc/herdr-app/THIRD-PARTY-NOTICES
# The launcher upstream's install script writes, pointing at /usr/bin
COPY output/herdr-app.desktop /output/usr/share/applications/

COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/postinst
COPY output/copyright /output/usr/share/doc/herdr-app/
COPY output/changelog.Debian /output/usr/share/doc/herdr-app/
COPY output/README.md /output/usr/share/doc/herdr-app/

RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/herdr-app/changelog.Debian
RUN sed -i "s/herdr_app_VERSION/$herdr_app_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

RUN dpkg-deb -Zxz --build /output /herdr-app_${FULL_VERSION}.deb
