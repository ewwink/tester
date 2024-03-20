docker pull ubuntu:20.04
docker build -t nano:test -f test.dockerfile .

docker build -t ubuntu_dev:20.04 -f ubuntu_dev.dockerfile .
# --rm auto exit delete
docker run --rm  ubuntu_dev:20.04
docker run --rm --entrypoint node titasik/ubuntu_dev:20.04 --version

# -it interactive 
docker run -it--entrypoint bash titasik/ubuntu_dev:20.04 

# exit clean
docker rm -v -f $(docker ps -qa)
echo y | docker container prune


#run unbuntu 20.04
docker run -it 3cff1c6ff37e bash
docker run --name ubuntu_dev -it 3cff1c6ff37e bash

docker run --rm nano:test -buildconf

# clean junk file from image
apt-get clean;  apt autoremove; apt autoclean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# copy file from container to host
docker cp $(docker create --name copyOutput nano:test):/usr/local/bin/nano ./ && docker rm copyOutput
