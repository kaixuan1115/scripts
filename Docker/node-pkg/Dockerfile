FROM daocloud.io/library/node:8.4.0-alpine

RUN mkdir /workdir && npm i -g pkg \
    && echo -e '#!/bin/sh\n[ ! -e node_modules -a -f package.json ] && npm i\nexec pkg "$@"' >/entrypoint.sh \
    && chmod a+x /entrypoint.sh

VOLUME ["/workdir"]

WORKDIR /workdir

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
