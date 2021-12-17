ARG CROSS_TOOLCHAIN_IMAGE

FROM tttapa/rpi-cross-toolchain:${CROSS_TOOLCHAIN_IMAGE} as cross-toolchain
# FROM tttapa/rpi-cross-native-toolchain:${CROSS_TOOLCHAIN_IMAGE} as cross-native-toolchain

FROM tttapa/rpi-cpp-toolchain-base-ubuntu as build

ARG HOST_ARCH
ARG HOST_TRIPLE
ARG HOST_TRIPLE_NO_VENDOR
ARG HOST_TRIPLE_LIB_DIR
ARG HOST_BITNESS

ENV HOST_ARCH ${HOST_ARCH}
ENV HOST_TRIPLE ${HOST_TRIPLE}
ENV HOST_TRIPLE_NO_VENDOR ${HOST_TRIPLE_NO_VENDOR}
ENV HOST_TRIPLE_LIB_DIR ${HOST_TRIPLE_LIB_DIR}
ENV HOST_BITNESS ${HOST_BITNESS}

ENV TOOLCHAIN_PATH="/home/develop/x-tools/${HOST_TRIPLE}"
ENV PATH="${PATH}:${TOOLCHAIN_PATH}/bin"
ENV DOWNLOADS="/tmp/downloads"

ENV RPI_SYSROOT="/home/develop/RPi-sysroot"
ENV RPI_STAGING="/home/develop/RPi-staging"

# Copy the cross-compilation toolchain
COPY --from=cross-toolchain \
    "/home/develop/x-tools/${HOST_TRIPLE}" \
    "${TOOLCHAIN_PATH}"

# Create a sysroot and staging area for the RPi
WORKDIR /home/develop
RUN mkdir "${RPI_SYSROOT}" "${RPI_STAGING}" && \
    cp -rp "${TOOLCHAIN_PATH}/${HOST_TRIPLE}/sysroot/"* "${RPI_SYSROOT}"/ && \
    chmod -R u+w "${RPI_SYSROOT}"
RUN mkdir -p "${DOWNLOADS}"
RUN mkdir -p ${RPI_STAGING}/usr/local && \
    [ "${HOST_BITNESS}" -eq "64" ] && \
    ln -s lib "${RPI_STAGING}/usr/local/lib64" || \
    true
RUN mkdir -p ${RPI_SYSROOT}/usr/local && \
    [ "${HOST_BITNESS}" -eq "64" ] && \
    ln -s lib "${RPI_SYSROOT}/usr/local/lib64" || \
    true

# Copy the cross-compilation pkg-config wrappers
COPY --chown=develop:develop tools/ ./tools/
ENV PATH="/home/develop/tools:${PATH}"

# Userland, FFmpeg, ...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
# Raspberry Pi Userland (VideoCore)
COPY install-scripts/${HOST_TRIPLE}.userland.cmake .
COPY --chown=develop:develop install-scripts/userland.sh .
RUN chmod +x userland.sh && ./userland.sh

# NumPy, SciPy, OpenCV
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# OpenCV ARM
COPY --chown=develop:develop install-scripts/opencv.sh .
RUN chmod +x opencv.sh && ./opencv.sh

# System libraries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Copy gdbserver to the staging area, as well as the latest C++ and Fortran 
# libraries, OpenMP ...
RUN mkdir -p "${RPI_STAGING}/usr/local/lib/${HOST_TRIPLE_LIB_DIR}/" && \
    cp -a \
        "${RPI_SYSROOT}/lib/libstdc++.so"* \
        "${RPI_STAGING}/usr/local/lib/${HOST_TRIPLE_LIB_DIR}/" && \
    cp -a \
        "${RPI_SYSROOT}/lib/libgomp.so"* \
        "${RPI_STAGING}/usr/local/lib/${HOST_TRIPLE_LIB_DIR}/" && \
    cp -a \
        "${RPI_SYSROOT}/lib/libgfortran.so"* \
        "${RPI_STAGING}/usr/local/lib/${HOST_TRIPLE_LIB_DIR}/" && \
    cp -a \
        "$TOOLCHAIN_PATH/${HOST_TRIPLE}/debug-root/usr/bin/gdbserver" \
        "${RPI_STAGING}/usr/local/bin"

# Development build
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # Copy the GCC toolchain
# COPY --from=cross-native-toolchain \
#     "/home/develop/x-tools/HOST-${HOST_TRIPLE_NO_VENDOR}" \
#     ${RPI_STAGING}/opt
# # Create links to the toolchain executables in /usr/local/bin
# RUN cd "${RPI_STAGING}/usr/local/bin" && \
#     find "../../../opt/${HOST_TRIPLE}/bin" -type f \
#         -name "${HOST_TRIPLE}-*" \
#         -exec ln -s {} . ';'
# # Create links without the target prefix 
# # (e.g. gcc instead of aarch64-rpi3-linux-gnu-gcc)
# COPY --chown=develop:develop dev-tools/strip-toolchain-prefix.sh .
# RUN chmod +x strip-toolchain-prefix.sh \
#  && cd "${RPI_STAGING}/usr/local/bin" \
#  && /home/develop/strip-toolchain-prefix.sh \
#         "${HOST_TRIPLE}" \
#         "../../../opt/${HOST_TRIPLE}/bin" \
#         "${RPI_STAGING}/usr/local/bin"
# # Make links to distcc for gcc and g++
# RUN mkdir -p "${RPI_STAGING}/usr/local/lib/distcc/bin" \
#  && cd "${RPI_STAGING}/usr/local/lib/distcc/bin" \
#  && ln -s "../../../bin/distcc" "${HOST_TRIPLE}-gcc" \
#  && ln -s "../../../bin/distcc" "${HOST_TRIPLE}-g++"
