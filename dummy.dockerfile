FROM ubuntu:20.04

WORKDIR /app
COPY dummy.sh .

RUN apt-get update && apt-get install zip -y
RUN /bin/bash dummy.sh

CMD         ["--version"]
ENTRYPOINT  ["/bin/bash"]