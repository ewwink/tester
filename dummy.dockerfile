FROM ubuntu:20.04

WORKDIR /app
COPY dummy.sh .

RUN apt-get update  > /dev/null
RUN apt-get install zip -y > /dev/null
RUN /bin/bash dummy.sh

CMD         ["--version"]
ENTRYPOINT  ["/bin/bash"]