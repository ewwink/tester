FROM ubuntu:20.04

WORKDIR /app
COPY dummy.sh .

RUN apt update && apt intall zip
RUN /bin/bash dummy.sh

CMD         ["-h"]
ENTRYPOINT  ["/usr/bin/bash"]