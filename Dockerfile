# ------------------------------------------------------------------------------
# Pull base image
FROM fullaxx/ubuntu-desktop
MAINTAINER Brett Kuskie <fullaxx@gmail.com>

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C
ENV TZ Etc/Zulu
ENV CHROMEURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
ENV CHROMEDEB "/tmp/chrome.deb"
ENV CYBCHEF_VERS "v10.5.2"
ENV CYBCHEF_URL "https://github.com/gchq/CyberChef/releases/download/${CYBCHEF_VERS}/CyberChef_${CYBCHEF_VERS}.zip"

# ------------------------------------------------------------------------------
# Update apt
RUN apt-get update

# ------------------------------------------------------------------------------
# Install basic tools
RUN apt-get install -y apcalc apt-transport-https bash-completion build-essential \
bridge-utils brasero ca-certificates caja cdw cgdb cmake colordiff colortail curl \
dos2unix diffstat evince file galculator gdb gedit gimp git gkrellm gnupg2 htop \
hexcompare hexcurse hexdiff hexedit hexer iftop iperf kmod less lsof \
man mc most nano nedit netcat nload nmon patch parallel psmisc \
rsync software-properties-common sudo tree tzdata wget unzip xfe xterm

# ------------------------------------------------------------------------------
# Install Docker
RUN wget -q -O- https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# ------------------------------------------------------------------------------
# Install Chrome
RUN wget ${CHROMEURL} -O ${CHROMEDEB} && \
dpkg -i ${CHROMEDEB} || (set -e; apt-get update; apt-get install -f -y) && \
rm ${CHROMEDEB}

# ------------------------------------------------------------------------------
# Install VSCode
RUN wget -q -O- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && \
apt-get update && apt-get install -y code libasound2

# Install VSCode extensions
COPY conf/install_vscode_extensions.sh /tmp/
RUN /tmp/install_vscode_extensions.sh  
RUN echo "alias code='code --no-sandbox --user-data-dir ~/vscode'" >> ~/.bashrc

# ------------------------------------------------------------------------------
# Install platform tools
RUN apt-get install -y firefox gnuradio jupyter-notebook libreoffice \
maven octave openjdk-11-jdk redis

# ------------------------------------------------------------------------------
# Install dev tools
RUN apt-get install -y golang-go bluefish chaosreader cmake universal-ctags doxygen emacs geany \
libcurl4 libczmq4 libmicrohttpd12 libpcap0.8 libssl3 libxml2 libzmq5 \
nmap screen sqlite3 subversion terminator tmux tcpdump \
valgrind vim vim-gtk3 wireshark termshark jq 

# ------------------------------------------------------------------------------
# Install dev libraries
RUN apt-get install -y gnuradio-dev libzmq-java \
libcurl4-openssl-dev libczmq-dev libhiredis-dev libmicrohttpd-dev libpcap-dev \
libsqlite3-dev libssl-dev libxml2-dev libzmq3-dev

# ------------------------------------------------------------------------------
# Install python libraries
RUN apt-get install -y cython3 \
python3-hiredis python3-redis \
python3-pip python3-virtualenv python3-zmq

# ------------------------------------------------------------------------------
# Install Cyberchef
RUN wget ${CYBCHEF_URL} -O /tmp/CyberChef_${CYBCHEF_VERS}.zip
RUN unzip /tmp/CyberChef_${CYBCHEF_VERS}.zip -d /opt/CyberChef_${CYBCHEF_VERS}
RUN echo "alias cyberchef='google-chrome-stable --no-sandbox /opt/CyberChef_${CYBCHEF_VERS}/CyberChef_${CYBCHEF_VERS}.html'" >> ~/.bashrc

# ------------------------------------------------------------------------------
# Install extraneous 
RUN wget https://github.com/AlpineGrizzly/go-maze-gen/archive/refs/heads/main.zip -O /tmp/gomaze.zip
RUN unzip /tmp/gomaze.zip -d /opt/
WORKDIR /opt/go-maze-gen-main/src/
RUN ./build.sh
RUN echo "alias amazeme='/opt/go-maze-gen-main/src/maze-gen'" >> ~/.bashrc
 
# ------------------------------------------------------------------------------
# Install Kaitai compiler and visualizer
RUN apt-get update && apt-get install -y --no-install-recommends ruby openjdk-8-jre-headless && \
    wget https://github.com/kaitai-io/kaitai_struct_compiler/releases/download/0.10/kaitai-struct-compiler_0.10_all.deb && \
    dpkg -i kaitai-struct-compiler_0.10_all.deb && \
    rm kaitai-struct-compiler_0.10_all.deb && \
    gem install kaitai-struct-visualizer && \
    pip install kaitaistruct && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Install wallpaper scripts and configuration files
COPY bg/rain_forest.jpg /usr/share/backgrounds/
COPY conf/menu.xml /usr/share/ubuntu-desktop/openbox/

# ------------------------------------------------------------------------------
# Adjust autostart
# RUN echo "\nhsetroot -center /usr/share/backgrounds/hardy_wallpaper_uhd.png" >>/usr/share/ubuntu-desktop/openbox/autostart
RUN echo "\nhsetroot -center /usr/share/backgrounds/rain_forest.jpg" >>/usr/share/ubuntu-desktop/openbox/autostart
RUN echo "\n# Set Keyboard Rate\nxset r rate 195 35" >>/usr/share/ubuntu-desktop/openbox/autostart

# ------------------------------------------------------------------------------
# Adjust bash prompt
COPY conf/dot_bashrc /usr/share/ubuntu-desktop/
RUN cat /usr/share/ubuntu-desktop/dot_bashrc >>/root/.bashrc

# ------------------------------------------------------------------------------
# Add configuration files for bluefish, geany, terminology
ADD personalization.tar /root/

# ------------------------------------------------------------------------------
# Install scripts and configuration files
# COPY conf/menu.xml /usr/share/ubuntu-desktop/openbox/

# ------------------------------------------------------------------------------
# Expose ports
EXPOSE 5901

# ------------------------------------------------------------------------------
# Define default command
CMD ["/app/app.sh"]
