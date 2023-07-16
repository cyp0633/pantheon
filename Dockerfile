# Start from Ubuntu 18.04 base image
FROM ubuntu:18.04

ARG DEBIAN_FRONTEND noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN true

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    git \
    python2.7 \
    python-pip \
    sudo \
    tzdata \
    keyboard-configuration 

# Create test user, switch to it and set up sudo
RUN useradd -m test && echo "test:test" | chpasswd && adduser test sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER test
WORKDIR /home/test

# Update pip
RUN python -m pip install --upgrade pip

# Clone Pantheon repository
RUN git clone https://github.com/cyp0633/pantheon.git
WORKDIR /home/test/pantheon

RUN git submodule update --init --recursive

# Install Pantheon dependencies
RUN DEBIAN_FRONTEND=noninteractive ./tools/install_deps.sh
RUN DEBIAN_FRONTEND=noninteractive ./src/experiments/setup.py --install-deps --schemes "cubic vegas bbr ledbat pcc verus sprout quic scream vivace pcc_experimental fillp indigo fillp_sheep"

# Set up Pantheon 
RUN src/experiments/setup.py --setup --schemes "cubic vegas bbr ledbat pcc verus sprout quic scream vivace pcc_experimental fillp indigo fillp_sheep proteus_s proteus_p"

# Expose port for running tests
EXPOSE 5000

CMD ["src/experiments/test.py", "local","--schemes", "cubic vegas bbr ledbat pcc verus sprout quic scream vivace pcc_experimental fillp indigo fillp_sheep proteus_s proteus_p"]