FROM frolvlad/alpine-python3

RUN apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran file binutils \
        musl-dev python3-dev openblas-dev && \
    apk add libstdc++ openblas && \
    \
    ln -s locale.h /usr/include/xlocale.h && \
    \
    pip install --upgrade pip && \
    pip install numpy==1.16.3 && \
    pip install pandas==0.24.2 && \
    pip install scipy==1.2.1 && \
    pip install cython==0.29.7 && \
    pip install scikit-learn==0.21.1 && \
    \
    rm -r /root/.cache && \
    find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    \
    rm /usr/include/xlocale.h && \
    \
    apk del .build-dependencies

# Add pycddlib and cvxopt with GLPK
RUN cd /tmp && \
    apk add --no-cache \
        --virtual=.build-dependencies \
        gcc make file binutils \
        musl-dev python3-dev gmp-dev suitesparse-dev openblas-dev && \
    apk add gmp suitesparse && \
    \
    pip install pycddlib==2.1.0 && \
    # pip uninstall --yes cython && \
    \
    wget "ftp://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz" && \
    tar xzf "glpk-4.65.tar.gz" && \
    cd "glpk-4.65" && \
    ./configure --disable-static && \
    make -j4 && \
    make install-strip && \
    CVXOPT_BLAS_LIB=openblas CVXOPT_LAPACK_LIB=openblas CVXOPT_BUILD_GLPK=1 pip install --global-option=build_ext --global-option="-I/usr/include/suitesparse" cvxopt && \
    \
    rm -r /root/.cache && \
    find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    \
    apk del .build-dependencies && \
    rm -rf /tmp/*
