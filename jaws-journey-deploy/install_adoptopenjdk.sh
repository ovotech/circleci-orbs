wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz -O /tmp/openjdk-11.tar.gz
sudo mkdir -p /usr/lib/jvm
sudo tar xfvz /tmp/openjdk-11.tar.gz --directory /usr/lib/jvm
rm -f /tmp/openjdk-11.tar.gz
sudo sh -c 'for bin in /usr/lib/jvm/jdk-11.0.6+10/bin/*; do update-alternatives --install /usr/bin/$(basename $bin) $(basename $bin) $bin 100; done'
sudo sh -c 'for bin in /usr/lib/jvm/jdk-11.0.6+10/bin/*; do update-alternatives --set $(basename $bin) $bin; done'